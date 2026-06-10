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
# if not, simply set it to 0G
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
        echo "[ERROR] data.tar not found in .deb"
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

install_qemu_auto() {
    local missing=()
    cmd_exists "$QEMU_SYS" || missing+=("$QEMU_SYS")
    cmd_exists "$QEMU_IMG" || missing+=("$QEMU_IMG")
    cmd_exists "$CLOUD_LOCALDS" || missing+=("$CLOUD_LOCALDS")
    [ ${#missing[@]} -eq 0 ] && return 0

    echo "[INFO] Host architecture: $HOST_ARCH"
    echo "[INFO] Missing tools: ${missing[*]}"
    echo "[INFO] Attempting auto-install..."

    # Try package managers (root)
    if cmd_exists apt-get && [ "$(id -u)" -eq 0 ]; then
        echo "[INSTALL] Using apt-get..."
        apt-get update -qq 2>/dev/null
        local pkg="qemu-system-x86 qemu-utils cloud-image-utils"
        case "$HOST_ARCH" in
            x86_64)  pkg="qemu-system-x86 qemu-utils cloud-image-utils" ;;
            aarch64) pkg="qemu-system-arm qemu-utils cloud-image-utils" ;;
            armhf)   pkg="qemu-system-arm qemu-utils cloud-image-utils" ;;
        esac
        if apt-get install -y -qq $pkg 2>&1 | tail -3; then
            echo "[INSTALL] Installed via apt-get"
            return 0
        fi
    fi

    if cmd_exists pacman && [ "$(id -u)" -eq 0 ]; then
        echo "[INSTALL] Using pacman..."
        pacman -Sy --noconfirm qemu-system qemu-utils cloud-image-utils 2>&1 | tail -3
        return 0
    fi

    if cmd_exists dnf && [ "$(id -u)" -eq 0 ]; then
        echo "[INSTALL] Using dnf..."
        dnf install -y qemu-kvm qemu-img cloud-utils 2>&1 | tail -3
        return 0
    fi

    # Download .deb and extract (no root needed)
    echo "[INSTALL] Downloading static binaries..."
    local dl_dir="$VM_DIR/qemu-binaries"
    mkdir -p "$dl_dir"

    local deb_arch=""
    case "$HOST_ARCH" in
        x86_64)  deb_arch="amd64" ;;
        aarch64) deb_arch="arm64" ;;
        armhf)   deb_arch="armhf" ;;
        riscv64) deb_arch="riscv64" ;;
        *)       deb_arch="$HOST_ARCH" ;;
    esac

    # qemu-system package
    local pkg_name="qemu-system-x86"
    [ "$HOST_ARCH" = "aarch64" ] || [ "$HOST_ARCH" = "armhf" ] && pkg_name="qemu-system-arm"
    local qemu_ver="9.0.2+dfsg-4"
    local deb_url="https://deb.debian.org/debian/pool/main/q/qemu/${pkg_name}_${qemu_ver}_${deb_arch}.deb"

    if download_file "$deb_url" "$dl_dir/qemu.deb"; then
        extract_deb_binary "$dl_dir/qemu.deb" "$QEMU_SYS" "$dl_dir" && \
        extract_deb_binary "$dl_dir/qemu.deb" "$QEMU_IMG" "$dl_dir" && \
        echo "[INSTALL] QEMU system binaries extracted to $dl_dir"
    fi

    # cloud-localds
    if ! cmd_exists "$CLOUD_LOCALDS"; then
        local cloud_url="https://deb.debian.org/debian/pool/main/c/cloud-image-utils/cloud-image-utils_0.14-4_all.deb"
        download_file "$cloud_url" "$dl_dir/cloud.deb" 2>/dev/null && \
        extract_deb_binary "$dl_dir/cloud.deb" "cloud-localds" "$dl_dir"
    fi

    if [ -f "$dl_dir/$QEMU_SYS" ]; then
        export PATH="$dl_dir:$PATH"
        echo "[INSTALL] QEMU ready in $dl_dir"
        return 0
    fi

    echo "[ERROR] ============================================"
    echo "[ERROR] Failed to install QEMU automatically."
    echo "[ERROR] Install manually:"
    echo "[ERROR]   Ubuntu/Debian: sudo apt install qemu-system-x86 qemu-utils cloud-image-utils"
    echo "[ERROR]   Arch:          sudo pacman -S qemu-system qemu-utils cloud-image-utils"
    echo "[ERROR]   Fedora:        sudo dnf install qemu-kvm qemu-img cloud-utils"
    echo "[ERROR]   macOS:         brew install qemu"
    echo "[ERROR] ============================================"
    exit 1
}

install_qemu_auto

# =============================
# TOOL CHECK
# =============================
for cmd in "$QEMU_SYS" "$QEMU_IMG" "$CLOUD_LOCALDS"; do
    if ! cmd_exists $cmd; then
        echo "[ERROR] '$cmd' not found after auto-install."
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
