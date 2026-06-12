#!/bin/bash
set -euo pipefail

# =============================
# UBUNTU VM FILE
# CREDIT: quanvm0501 (BlackCatOfficial), BiraloGaming
# =============================

# =============================
# CONFIG
# =============================
VM_DIR="$(pwd)/vm"
IMG_URL="https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
IMG_FILE="$VM_DIR/ubuntu-image.img"
UBUNTU_PERSISTENT_DISK="$VM_DIR/persistent.qcow2"
SEED_FILE="$VM_DIR/seed.iso"
MEMORY=16G
CPUS=4
SSH_PORT=2222
DISK_SIZE=80G
IMG_SIZE=20G
HOSTNAME="ubuntu"
USERNAME="ubuntu"
PASSWORD="ubuntu"

# use this if you are using tcg
# if not, set it to 0G
SWAP_SIZE=4G
mkdir -p "$VM_DIR"
cd "$VM_DIR"

# =============================
# QEMU AUTO-INSTALL
# =============================
# Detect host architecture and install QEMU system binaries if missing.

ARCH="$(uname -m)"
case "$ARCH" in
    x86_64|amd64)  HOST_ARCH="x86_64"; QEMU_SYS="qemu-system-x86_64"; QEMU_IMG="qemu-img"; CLOUD_LOCALDS="cloud-localds";;
    aarch64|arm64) HOST_ARCH="aarch64"; QEMU_SYS="qemu-system-aarch64"; QEMU_IMG="qemu-img"; CLOUD_LOCALDS="cloud-localds";;
    armv7l|armhf)  HOST_ARCH="armhf"; QEMU_SYS="qemu-system-arm"; QEMU_IMG="qemu-img"; CLOUD_LOCALDS="cloud-localds";;
    riscv64)       HOST_ARCH="riscv64"; QEMU_SYS="qemu-system-riscv64"; QEMU_IMG="qemu-img"; CLOUD_LOCALDS="cloud-localds";;
    *)             HOST_ARCH="$ARCH"; QEMU_SYS="qemu-system-$ARCH"; QEMU_IMG="qemu-img"; CLOUD_LOCALDS="cloud-localds";;
esac

cmd_exists() { command -v "$1" &>/dev/null; }

download_file() {
    local url="$1" dest="$2"
    echo "[QEMU-INSTALL] Downloading $url"
    if cmd_exists wget; then
        wget -q --show-progress -O "$dest" "$url"
    elif cmd_exists curl; then
        curl -fSL -o "$dest" "$url"
    else
        echo "[ERROR] Neither wget nor curl found."
        return 1
    fi
}

# ===================================================
# FALLBACK: CLONE & COMPILE FROM SOURCE
# ===================================================
build_qemu_from_source() {
    echo "[FALLBACK] Cloning and compiling QEMU from GitLab..."
    # Create a temporary source directory in /tmp because the active filesystem (e.g. HopsFS) may not support symlinks.
    local src_dir
    src_dir=$(mktemp -d -t qemu-src-XXXXXX)
    local dl_dir="$VM_DIR/qemu-binaries"
    
    if ! cmd_exists git; then
        echo "[ERROR] 'git' is required to clone QEMU source code. Please install 'git' first."
        rm -rf "$src_dir"
        return 1
    fi
    
    echo "[BUILD] Cloning QEMU source into $src_dir..."
    git clone --depth 1 https://gitlab.com/qemu-project/qemu.git "$src_dir"
    cd "$src_dir"

    # Map target list based on detected host architecture
    local TARGET=""
    case "$HOST_ARCH" in
        x86_64)  TARGET="x86_64-softmmu" ;;
        aarch64) TARGET="aarch64-softmmu" ;;
        armhf)   TARGET="arm-softmmu" ;;
        riscv64) TARGET="riscv64-softmmu" ;;
        *)       TARGET="${HOST_ARCH}-softmmu" ;;
    esac

    # Attempt to install building dependencies if running as root
    if [ "$(id -u)" -eq 0 ]; then
        echo "[BUILD] Installing compiling dependencies..."
        if cmd_exists apt; then
            apt update -qq && apt install -y -qq build-essential ninja-build python3-pip libglib2.0-dev libpixman-1-dev pkg-config libaio-dev
        elif cmd_exists apt-get; then
            apt-get update -qq && apt-get install -y -qq build-essential ninja-build python3-pip libglib2.0-dev libpixman-1-dev pkg-config libaio-dev
        elif cmd_exists pacman; then
            pacman -Sy --noconfirm --needed base-devel ninja python glib2 pixman pkgconf libaio
        elif cmd_exists dnf; then
            dnf groupinstall -y "Development Tools"
            dnf install -y ninja-build python3 glib2-devel pixman-devel pkgconfig libaio-devel
        elif cmd_exists zypper; then
            zypper install -y -t pattern devel_basis
            zypper install -y ninja python3-devel glib2-devel pixman-devel pkg-config libaio-devel
        fi
    else
        echo "[INFO] Not running as root; skipping package dependency installation."
        echo "[INFO] Please ensure build tools, 'ninja', 'glib', 'pixman', and 'pkg-config' are preinstalled on your host."
    fi

    echo "[BUILD] Configuring QEMU for $TARGET..."
    ./configure --target-list="$TARGET"

    echo "[BUILD] Compiling QEMU..."
    make -j "$(nproc)"

    mkdir -p "$dl_dir"
    
    # Locate and copy built binaries
    local sys_bin="qemu-system-${HOST_ARCH}"
    [ "$HOST_ARCH" = "armhf" ] && sys_bin="qemu-system-arm"
    
    local build_success=0
    if [ -f "build/$sys_bin" ]; then
        cp "build/$sys_bin" "$dl_dir/"
        build_success=1
    elif [ -f "build/$TARGET/$sys_bin" ]; then
        cp "build/$TARGET/$sys_bin" "$dl_dir/"
        build_success=1
    fi

    if [ -f "build/qemu-img" ]; then
        cp "build/qemu-img" "$dl_dir/"
    elif [ -f "qemu-img" ]; then
        cp "qemu-img" "$dl_dir/"
    fi

    cd "$VM_DIR"
    rm -rf "$src_dir" # Clean up temp directory immediately

    if [ "$build_success" -eq 1 ] && [ -f "$dl_dir/$QEMU_SYS" ] && [ -f "$dl_dir/$QEMU_IMG" ]; then
        chmod +x "$dl_dir"/*
        echo "[BUILD] QEMU successfully compiled and ready in $dl_dir"
        return 0
    fi
    
    echo "[ERROR] Compilation finished, but target binaries were not found."
    return 1
}

# ===================================================
# MAIN AUTO-INSTALL FUNCTION
# ===================================================
install_qemu_auto() {
    local dl_dir="$VM_DIR/qemu-binaries"
    mkdir -p "$dl_dir"
    
    # Prepend our binaries folder to the path and dynamic library path
    export PATH="$dl_dir:$PATH"
    export LD_LIBRARY_PATH="$dl_dir${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

    local missing=()
    (cmd_exists "$QEMU_SYS" && "$QEMU_SYS" --version &>/dev/null) || missing+=("$QEMU_SYS")
    (cmd_exists "$QEMU_IMG" && "$QEMU_IMG" --version &>/dev/null) || missing+=("$QEMU_IMG")
    
    if [ ${#missing[@]} -eq 0 ]; then
        echo "[INFO] QEMU binaries ($QEMU_SYS, $QEMU_IMG) are available and fully functional."
    else
        echo "[INFO] Host architecture: $HOST_ARCH"
        echo "[INFO] Missing or dysfunctional tools: ${missing[*]}"
        local success=1

        # 1. TRY DIRECT DOWNLOAD OF THE SPECIFIED BINARIES
        echo "[INSTALL] Attempting direct binary downloads..."
        local base_url="https://github.com/BlackCatOfficialytb/bcofilesrepo/releases/download/qemu-files-full-bin-v11.0.1-20261006"
        local bins=(
            "qemu-bridge-helper"
            "qemu-edid"
            "qemu-img"
            "qemu-io"
            "qemu-nbd"
            "qemu-pr-helper"
            "qemu-system-aarch64"
            "qemu-system-x86_64"
            "qemu-vmsr-helper"
        )

        # Clear existing non-functional binaries to ensure a clean state
        for bin in "${bins[@]}"; do
            rm -f "$dl_dir/$bin"
        done

        for bin in "${bins[@]}"; do
            if ! download_file "$base_url/$bin" "$dl_dir/$bin"; then
                echo "[WARNING] Failed to download $bin"
                success=0
            else
                chmod +x "$dl_dir/$bin"
            fi
        done

        # Verify critical binaries are successfully present and working on this host
        if [ "$success" -eq 1 ] && [ -f "$dl_dir/$QEMU_SYS" ] && [ -f "$dl_dir/$QEMU_IMG" ]; then
            echo "[INFO] Testing downloaded binaries for compatibility and missing shared libraries..."
            if "$dl_dir/$QEMU_IMG" --version &>/dev/null && "$dl_dir/$QEMU_SYS" --version &>/dev/null; then
                echo "[INSTALL] QEMU binaries downloaded and verified successfully!"
            else
                echo "[WARNING] Downloaded QEMU binaries failed sanity checks. Attempting automatic user-space libaio and libiscsi extraction..."
                
                # Resolve the matching packages for the system architecture
                local libaio_url=""
                local libiscsi_url=""
                if [ "$HOST_ARCH" = "x86_64" ]; then
                    libaio_url="http://archive.ubuntu.com/ubuntu/pool/main/liba/libaio/libaio1_0.3.112-13build1_amd64.deb"
                    libiscsi_url="http://ftp.debian.org/debian/pool/main/libi/libiscsi/libiscsi7_1.20.0-4_amd64.deb"
                elif [ "$HOST_ARCH" = "aarch64" ]; then
                    libaio_url="http://ports.ubuntu.com/pool/main/liba/libaio/libaio1_0.3.112-13build1_arm64.deb"
                    libiscsi_url="http://ftp.debian.org/debian/pool/main/libi/libiscsi/libiscsi7_1.20.0-4_arm64.deb"
                fi

                local urls=()
                [ -n "$libaio_url" ] && urls+=("$libaio_url")
                [ -n "$libiscsi_url" ] && urls+=("$libiscsi_url")

                if [ ${#urls[@]} -gt 0 ] && cmd_exists dpkg; then
                    local ext_dir="$dl_dir/lib_ext"
                    mkdir -p "$ext_dir"
                    
                    for url in "${urls[@]}"; do
                        local deb_file="$dl_dir/temp.deb"
                        if download_file "$url" "$deb_file"; then
                            if dpkg -x "$deb_file" "$ext_dir" 2>/dev/null; then
                                echo "[INFO] Extracted $(basename "$url")"
                            fi
                            rm -f "$deb_file"
                        fi
                    done
                    
                    # Copy all extracted shared libraries (.so) to the qemu-binaries directory
                    cp "$ext_dir"/usr/lib/*/lib*.so* "$dl_dir/" 2>/dev/null || \
                    find "$ext_dir" -name "lib*.so*" -exec cp {} "$dl_dir/" \; 2>/dev/null || true
                    rm -rf "$ext_dir"
                fi

                # Re-verify the sanity checks with the local library path set
                if "$dl_dir/$QEMU_IMG" --version &>/dev/null && "$dl_dir/$QEMU_SYS" --version &>/dev/null; then
                    echo "[INSTALL] QEMU binaries verified successfully after extracting libaio and libiscsi!"
                else
                    echo "[WARNING] Sanity check still failed. Falling back to compilation..."
                    success=0
                fi
            fi
        else
            success=0
        fi

        # 2. FALLBACK: COMPILE FROM GITLAB SOURCE
        if [ "$success" -ne 1 ]; then
            echo "[WARNING] Direct binary downloads failed or were incompatible. Falling back to compilation..."
            # Clean up potentially corrupt/incompatible binaries from direct downloads so build checker doesn't get confused
            for bin in "${bins[@]}"; do
                rm -f "$dl_dir/$bin"
            done
            if build_qemu_from_source; then
                success=1
            fi
        fi

        if [ "$success" -ne 1 ]; then
            echo "[ERROR] Local QEMU setup failed."
            exit 1
        fi
    fi

    # Handle cloud-localds installation separately
    if ! cmd_exists "$CLOUD_LOCALDS"; then
        echo "[INFO] '$CLOUD_LOCALDS' missing. Attempting setup..."
        
        local cloud_primary_url="https://raw.githubusercontent.com/BlackCatOfficialytb/QEMU-freeroot/refs/heads/main/cloud-localds.sh"
        local cloud_fallback_url="https://github.com/canonical/cloud-utils/raw/refs/heads/main/bin/cloud-localds"
        local temp_dest="$dl_dir/cloud-localds.sh"
        local final_dest="$dl_dir/cloud-localds"

        echo "[INFO] Attempting to download cloud-localds from primary source..."
        if download_file "$cloud_primary_url" "$temp_dest"; then
            echo "[INFO] Successfully downloaded primary cloud-localds.sh"
            if mv "$temp_dest" "$final_dest" 2>/dev/null; then
                chmod +x "$final_dest"
                echo "[INFO] Renamed primary cloud-localds.sh to cloud-localds."
            else
                echo "[WARNING] Could not rename cloud-localds.sh to cloud-localds. Keeping original."
                chmod +x "$temp_dest"
                CLOUD_LOCALDS="cloud-localds.sh"
            fi
        else
            echo "[WARNING] Primary source download failed. Trying fallback source..."
            if download_file "$cloud_fallback_url" "$final_dest"; then
                echo "[INFO] Successfully downloaded fallback cloud-localds."
                chmod +x "$final_dest"
            else
                echo "[ERROR] Failed to download cloud-localds from both primary and fallback sources."
                exit 1
            fi
        fi
    fi
}

install_qemu_auto

# =============================
# TOOL CHECK
# =============================
for cmd in "$QEMU_SYS" "$QEMU_IMG" "$CLOUD_LOCALDS"; do
    if ! cmd_exists "$cmd"; then
        echo "[ERROR] '$cmd' not found after auto-install attempts."
        exit 1
    fi
done

# =============================
# VM IMAGE SETUP
# =============================
if [ ! -f "$IMG_FILE" ]; then
    echo "[INFO] Downloading Ubuntu Base/Cloud Image..."
    wget "$IMG_URL" -O "$IMG_FILE"
    "$QEMU_IMG" resize "$IMG_FILE" "$DISK_SIZE"

    cat > user-data <<EOF
#cloud-config
hostname: $HOSTNAME
manage_etc_hosts: true
disable_root: false
ssh_pwauth: true
chpasswd:
  list: |
    $USERNAME:$PASSWORD
  expire: false
packages:
  - openssh-server
runcmd:
  - echo "$USERNAME:$PASSWORD" | chpasswd
  - mkdir -p /var/run/sshd
  - /usr/sbin/sshd -D &
  - |
    if [ "$SWAP_SIZE" != "0G" ] && [ "$SWAP_SIZE" != "0" ]; then
      fallocate -l $SWAP_SIZE /swapfile
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      echo '/swapfile none swap sw 0 0' >> /etc/fstab
    fi
growpart:
  mode: auto
  devices: ["/"]
  ignore_growroot_disabled: false
resize_rootfs: true
EOF

    cat > meta-data <<EOF
instance-id: iid-local01
local-hostname: $HOSTNAME
EOF

    "$CLOUD_LOCALDS" "$SEED_FILE" user-data meta-data
    echo "[INFO] VM image setup complete with OpenSSH and Swap!"
else
    echo "[INFO] VM image exists, skipping download..."
fi

# =============================
# PERSISTENT DISK SETUP
# =============================
if [ ! -f "$UBUNTU_PERSISTENT_DISK" ]; then
    echo "[INFO] Creating persistent disk..."
    "$QEMU_IMG" create -f qcow2 "$UBUNTU_PERSISTENT_DISK" "$IMG_SIZE"
fi

# =============================
# GRACEFUL SHUTDOWN TRAP
# =============================
cleanup() {
    echo "[INFO] Shutting down VM gracefully..."
    pkill -f "$QEMU_SYS" || true
}
trap cleanup SIGINT SIGTERM

# =============================
# START VM
# =============================
clear
if [ -e /dev/kvm ]; then
    ACCELERATION_FLAG="-enable-kvm -cpu host"
    echo "[INFO] KVM is available. Using hardware acceleration."
else
    ACCELERATION_FLAG="-accel tcg"
    echo "[INFO] KVM is not available. Falling back to TCG software emulation."
fi
echo "CREDIT: quanvm0501 (BlackCatOfficial), BiraloGaming"
echo "[INFO] Starting VM..."
echo "username: $USERNAME"
echo "password: $PASSWORD"
read -n1 -r -p "Press any key to continue..."
exec "$QEMU_SYS" \
    $ACCELERATION_FLAG \
    -m "$MEMORY" \
    -smp "$CPUS" \
    -drive file="$IMG_FILE",format=qcow2,if=virtio,cache=writeback \
    -drive file="$UBUNTU_PERSISTENT_DISK",format=qcow2,if=virtio,cache=writeback \
    -drive file="$SEED_FILE",format=raw,if=virtio \
    -boot order=c \
    -device virtio-net-pci,netdev=n0 \
    -netdev user,id=n0,hostfwd=tcp::"$SSH_PORT"-:22 \
    -nographic -serial mon:stdio
