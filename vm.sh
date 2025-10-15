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
IMG_URL="https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
IMG_FILE="$VM_DIR/ubuntu-image.img"
UBUNTU_PERSISTENT_DISK="$VM_DIR/persistent.qcow2"
SEED_FILE="$VM_DIR/seed.iso"
MEMORY=64G
CPUS=16
SSH_PORT=2222
DISK_SIZE=120G
IMG_SIZE=20G
HOSTNAME="noxy"
USERNAME="root"
PASSWORD="554466DSAFf"
# use this if you are using tcg
# if not, simply set it to 0G
SWAP_SIZE=4G
mkdir -p "$VM_DIR"
cd "$VM_DIR"

# =============================
# TOOL CHECK
# =============================
for cmd in qemu-system-x86_64 qemu-img cloud-localds; do
    if ! command -v $cmd &>/dev/null; then
        echo "[ERROR] Required command '$cmd' not found. Install it first."
        exit 1
    fi
done

# =============================
# VM IMAGE SETUP
# =============================
if [ ! -f "$IMG_FILE" ]; then
    echo "[INFO] Downloading Ubuntu Base/Cloud Image..."
    wget "$IMG_URL" -O "$IMG_FILE"
    qemu-img resize "$IMG_FILE" "$DISK_SIZE"

    # Cloud-init setup for OpenSSH and Swap
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
  # Swap file creation and activation
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

    cloud-localds "$SEED_FILE" user-data meta-data
    echo "[INFO] VM image setup complete with OpenSSH and Swap!"
else
    echo "[INFO] VM image exists, skipping download..."
fi

# =============================
# PERSISTENT DISK SETUP
# =============================
if [ ! -f "$UBUNTU_PERSISTENT_DISK" ]; then
    echo "[INFO] Creating persistent disk..."
    qemu-img create -f qcow2 "$UBUNTU_PERSISTENT_DISK" "$IMG_SIZE"
fi

# =============================
# GRACEFUL SHUTDOWN TRAP
# =============================
cleanup() {
    echo "[INFO] Shutting down VM gracefully..."
    pkill -f "qemu-system-x86_64" || true
}
trap cleanup SIGINT SIGTERM

# =============================
# START VM
# =============================
# Check if KVM is available
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
exec qemu-system-x86_64 \
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
