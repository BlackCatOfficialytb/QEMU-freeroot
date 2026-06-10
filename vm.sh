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

# URL to download your qemu.zip
# Replace this URL with your actual direct download link if needed
QEMU_ZIP_URL="https://github.com/BlackCatOfficialytb/QEMU-freeroot/releases/download/v1.0.0/qemu.zip"

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

extract_deb_binary() {
    local deb_file="$1" bin_name="$2" out_dir="$3"
    mkdir -p "$out_dir"
    local data_tar="" member_offset=8
    local file_size
    file_size=$(stat -c%s "$deb_file" 2>/dev/null || echo 0)

    while [ "$member_offset" -lt "$file_size" ]; do
        local header mname msize
        header=$(dd if="$deb_file" bs=1 skip="$member_offset" count=60 2>/dev/null)
        mname=$(echo "$header" | cut -c1-16 | tr -d ' ')
        msize=$(echo "$header" | cut -c49-58 | tr -d ' ')
        [ -z "$msize" ] && break
        [ "$msize" -eq 0 ] 2>/dev/null && break
        member_offset=$((member_offset + 60))
        if echo "$mname" | grep -q "data.tar"; then
            dd if="$deb_file" bs=1 skip="$member_offset" count="$msize" of="$out_dir/data.tar.tmp" 2>/dev/null
            data_tar="$out_dir/data.tar.tmp"
            break
        fi
        member_offset=$((member_offset + msize))
        [ $((member_offset % 2)) -ne 0 ] && member_offset=$((member_offset + 1))
    done

    if [ -z "$data_tar" ] || [ ! -f "$data_tar" ]; then
        echo "[ERROR] data.tar not found in .deb."
        return 1
    fi

    local found=0
    # Try all decompression methods
    for try in "-xzf" "-xjf" "-xf"; do
        [ "$found" -eq 1 ] && break
        if tar $try "$data_tar" -C "$out_dir" "usr/bin/$bin_name" 2>/dev/null; then
            mv "$out_dir/usr/bin/$bin_name" "$out_dir/$bin_name" 2>/dev/null
            found=1
        elif tar $try "$data_tar" -C "$out_dir" 2>/dev/null; then
            if [ -f "$out_dir/usr/bin/$bin_name" ]; then
                mv "$out_dir/usr/bin/$bin_name" "$out_dir/$bin_name"
                found=1
            fi
        fi
    done
    rm -f "$data_tar"

    if [ "$found" -eq 1 ] && [ -f "$out_dir/$bin_name" ]; then
        chmod +x "$out_dir/$bin_name"
        return 0
    fi
    echo "[ERROR] $bin_name not found in .deb"
    return 1
}

# ===================================================
# FALLBACK: CLONE & COMPILE FROM SOURCE
# ===================================================
build_qemu_from_source() {
    echo "[FALLBACK] Cloning and compiling QEMU from GitLab..."
    local src_dir="$VM_DIR/qemu-src"
    local dl_dir="$VM_DIR/qemu-binaries"
    rm -rf "$src_dir"
    
    if ! cmd_exists git; then
        echo "[ERROR] 'git' is required to clone QEMU source code. Please install 'git' first."
        return 1
    fi
    
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
        if cmd_exists apt-get; then
            apt-get update -qq && apt-get install -y -qq ninja-build python3-pip libglib2.0-dev libpixman-1-dev pkg-config make gcc g++
        elif cmd_exists pacman; then
            pacman -Sy --noconfirm ninja python glib2 pixman pkgconf make gcc gcc-libs
        elif cmd_exists dnf; then
            dnf install -y ninja-build python3 glib2-devel pixman-devel pkgconfig make gcc gcc-c++
        fi
    else
        echo "[INFO] Not running as root; skipping package dependency installation."
        echo "[INFO] Please ensure 'ninja', 'glib', 'pixman', 'pkg-config', and C++ compiler tools are preinstalled on your host."
    fi

    echo "[BUILD] Configuring QEMU for $TARGET..."
    ./configure --target-list="$TARGET"

    echo "[BUILD] Compiling QEMU..."
    make -j "$(nproc)"

    mkdir -p "$dl_dir"
    
    # Locate and copy built binaries
    local sys_bin="qemu-system-${HOST_ARCH}"
    [ "$HOST_ARCH" = "armhf" ] && sys_bin="qemu-system-arm"
    
    if [ -f "build/$sys_bin" ]; then
        cp "build/$sys_bin" "$dl_dir/"
    elif [ -f "build/$TARGET/$sys_bin" ]; then
        cp "build/$TARGET/$sys_bin" "$dl_dir/"
    fi

    if [ -f "build/qemu-img" ]; then
        cp "build/qemu-img" "$dl_dir/"
    elif [ -f "qemu-img" ]; then
        cp "qemu-img" "$dl_dir/"
    fi

    cd "$VM_DIR"
    if [ -f "$dl_dir/$QEMU_SYS" ] && [ -f "$dl_dir/$QEMU_IMG" ]; then
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
    
    # Prepend our binaries folder to the path
    export PATH="$dl_dir:$PATH"

    local missing=()
    cmd_exists "$QEMU_SYS" || missing+=("$QEMU_SYS")
    cmd_exists "$QEMU_IMG" || missing+=("$QEMU_IMG")
    
    if [ ${#missing[@]} -eq 0 ]; then
        echo "[INFO] QEMU binaries ($QEMU_SYS, $QEMU_IMG) are already available."
    else
        echo "[INFO] Host architecture: $HOST_ARCH"
        echo "[INFO] Missing tools: ${missing[*]}"
        local success=0

        # Install unzip dependency if running as root
        if ! cmd_exists unzip && [ "$(id -u)" -eq 0 ]; then
            echo "[INSTALL] Installing unzip..."
            if cmd_exists apt-get; then apt-get update -qq && apt-get install -y -qq unzip; fi
            if cmd_exists pacman; then pacman -Sy --noconfirm unzip; fi
            if cmd_exists dnf; then dnf install -y unzip; fi
        fi

        # 1. TRY ZIP METHOD
        if cmd_exists unzip; then
            echo "[INSTALL] Attempting ZIP-based setup..."
            if download_file "$QEMU_ZIP_URL" "$VM_DIR/qemu.zip"; then
                unzip -o "$VM_DIR/qemu.zip" -d "$dl_dir"
                
                # Check if binaries are nested inside any subfolders within the zip and flatten them
                local found_sys
                found_sys=$(find "$dl_dir" -type f -name "$QEMU_SYS" -print -quit)
                if [ -n "$found_sys" ]; then
                    local bin_dir
                    bin_dir=$(dirname "$found_sys")
                    if [ "$bin_dir" != "$dl_dir" ]; then
                        mv "$bin_dir"/* "$dl_dir/" 2>/dev/null || true
                    fi
                    chmod +x "$dl_dir"/*
                    
                    if [ -f "$dl_dir/$QEMU_SYS" ] && [ -f "$dl_dir/$QEMU_IMG" ]; then
                        echo "[INSTALL] QEMU binaries successfully set up from ZIP!"
                        success=1
                    fi
                fi
                rm -f "$VM_DIR/qemu.zip"
            fi
        else
            echo "[WARNING] 'unzip' utility is missing. Skipping ZIP extraction."
        fi

        # 2. FALLBACK: COMPILE FROM GITLAB SOURCE
        if [ "$success" -ne 1 ]; then
            echo "[WARNING] ZIP installation failed or skipped. Trying compilation fallback..."
            if build_qemu_from_source; then
                success=1
            fi
        fi

        if [ "$success" -ne 1 ]; then
            echo "[ERROR] Local QEMU setup failed."
            exit 1
        fi
    fi

    # Handle cloud-localds installation separately (part of cloud-image-utils)
    if ! cmd_exists "$CLOUD_LOCALDS"; then
        echo "[INFO] '$CLOUD_LOCALDS' missing. Attempting setup..."
        if cmd_exists apt-get && [ "$(id -u)" -eq 0 ]; then
            apt-get update -qq && apt-get install -y -qq cloud-image-utils
        elif cmd_exists pacman && [ "$(id -u)" -eq 0 ]; then
            pacman -Sy --noconfirm cloud-image-utils 2>/dev/null || true
        elif cmd_exists dnf && [ "$(id -u)" -eq 0 ]; then
            dnf install -y cloud-utils 2>/dev/null || true
        fi

        if ! cmd_exists "$CLOUD_LOCALDS"; then
            local cloud_url="https://deb.debian.org/debian/pool/main/c/cloud-image-utils/cloud-image-utils_0.14-4_all.deb"
            if download_file "$cloud_url" "$dl_dir/cloud.deb"; then
                extract_deb_binary "$dl_dir/cloud.deb" "cloud-localds" "$dl_dir"
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
  - fallocate -l $SWAP_SIZE /swapfile
  - chmod 600 /swapfile
  - mkswap /swapfile
  - swapon /swapfile
  - echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
  - if [ "$SWAP_SIZE" -eq 0 ]; then
      on_swap
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
