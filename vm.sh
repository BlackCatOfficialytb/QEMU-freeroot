#!/bin/bash
set -euo pipefail

# =============================
# QEMU-FREEROOT v2.0
# CREDIT: quanvm0501 (BlackCatOfficial), BiraloGaming
# Improved: interactive menu, .tar.gz support, lifecycle management
# =============================

VERSION="2.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# =============================
# CONFIG
# =============================
VM_DIR="$(pwd)/vm"
CONFIG_FILE="$VM_DIR/vm.conf"
DB_FILE="$VM_DIR/vm.db"

mkdir -p "$VM_DIR"

# Default config
DEFAULT_IMG_URL="https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img"
DEFAULT_MEMORY=4G
DEFAULT_CPUS=2
DEFAULT_DISK_SIZE=20G
DEFAULT_SWAP_SIZE=2G
DEFAULT_SSH_BASE=2222
DEFAULT_HOSTNAME="ubuntu"
DEFAULT_USERNAME="ubuntu"
DEFAULT_PASSWORD="ubuntu"

# =============================
# VM DATABASE (simple text file)
# =============================
db_init() {
    if [[ ! -f "$DB_FILE" ]]; then
        echo "# VM Database" > "$DB_FILE"
    fi
}

db_list_vms() {
    if [[ ! -f "$DB_FILE" ]] || ! grep -q "^VM:" "$DB_FILE" 2>/dev/null; then
        return 1
    fi
    grep "^VM:" "$DB_FILE"
}

db_add_vm() {
    local name="$1" img_path="$2" source="$3"
    if ! grep -q "^VM:${name}:" "$DB_FILE" 2>/dev/null; then
        echo "VM:${name}:${img_path}:${source}" >> "$DB_FILE"
    fi
}

db_remove_vm() {
    local name="$1"
    sed -i "/^VM:${name}:/d" "$DB_FILE"
}

db_get_vm() {
    local name="$1"
    grep "^VM:${name}:" "$DB_FILE" 2>/dev/null | head -1
}

db_get_field() {
    local vm_line="$1" field="$2"
    echo "$vm_line" | cut -d: -f"$field"
}

# =============================
# UTILITY FUNCTIONS
# =============================
check_tools() {
    local missing=()
    for cmd in qemu-system-x86_64 qemu-img; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}[ERROR] Missing required tools: ${missing[*]}${NC}"
        echo -e "${YELLOW}Install: sudo apt install qemu-kvm qemu-utils${NC}"
        return 1
    fi
    # Optional tools
    if ! command -v cloud-localds &>/dev/null; then
        echo -e "${YELLOW}[WARN] cloud-localds not found (cloud-init images won't have seed iso)${NC}"
        echo -e "${YELLOW}Install: sudo apt install cloud-image-utils${NC}"
    fi
}

is_vm_running() {
    local name="$1"
    pgrep -f "qemu-system.*${name}" &>/dev/null
}

get_ssh_port() {
    local name="$1"
    local vm_line
    vm_line=$(db_get_vm "$name")
    if [[ -n "$vm_line" ]]; then
        local img_path
        img_path=$(db_get_field "$vm_line" 3)
        # Read port from config if exists
        local conf="${img_path%.img}.conf"
        if [[ -f "$conf" ]]; then
            grep "^SSH_PORT=" "$conf" 2>/dev/null | cut -d= -f2
        else
            echo "$DEFAULT_SSH_BASE"
        fi
    else
        echo "$DEFAULT_SSH_BASE"
    fi
}

next_ssh_port() {
    local used_ports=$(grep -oP "SSH_PORT=\K\d+" "$VM_DIR"/*.conf 2>/dev/null || true)
    local port=$DEFAULT_SSH_BASE
    while echo "$used_ports" | grep -q "^${port}$"; do
        port=$((port + 1))
    done
    echo "$port"
}

# =============================
# VM CREATION FUNCTIONS
# =============================
create_from_cloudimg() {
    local name="$1" url="${2:-$DEFAULT_IMG_URL}"
    local memory="${3:-$DEFAULT_MEMORY}" cpus="${4:-$DEFAULT_CPUS}"
    local disk_size="${5:-$DEFAULT_DISK_SIZE}" swap_size="${6:-$DEFAULT_SWAP_SIZE}"
    local hostname="${7:-$DEFAULT_HOSTNAME}" username="${8:-$DEFAULT_USERNAME}" password="${9:-$DEFAULT_PASSWORD}"

    local img_file="$VM_DIR/${name}.img"
    local seed_file="$VM_DIR/${name}-seed.iso"
    local conf_file="$VM_DIR/${name}.conf"
    local ssh_port=$(next_ssh_port)

    if [[ -f "$img_file" ]]; then
        echo -e "${YELLOW}[WARN] VM '$name' already exists. Delete it first.${NC}"
        return 1
    fi

    echo -e "${BLUE}[1/4] Downloading cloud image...${NC}"
    wget -q --show-progress "$url" -O "$img_file"
    qemu-img resize "$img_file" "$disk_size" 2>/dev/null

    echo -e "${BLUE}[2/4] Creating cloud-init config...${NC}"
    mkdir -p "$VM_DIR/ci-${name}"
    cat > "$VM_DIR/ci-${name}/user-data" <<EOF
#cloud-config
hostname: ${hostname}
manage_etc_hosts: true
disable_root: false
ssh_pwauth: true
chpasswd:
  list: |
    ${username}:${password}
  expire: false
packages:
  - openssh-server
  - curl
  - wget
runcmd:
  - echo "${username}:${password}" | chpasswd
  - mkdir -p /var/run/sshd
  - /usr/sbin/sshd -D &
  - fallocate -l ${swap_size} /swapfile
  - chmod 600 /swapfile
  - mkswap /swapfile
  - swapon /swapfile
  - echo '/swapfile none swap sw 0 0' >> /etc/fstab
growpart:
  mode: auto
  devices: ["/"]
  ignore_growroot_disabled: false
resize_rootfs: true
EOF

    cat > "$VM_DIR/ci-${name}/meta-data" <<EOF
instance-id: ${name}-$(date +%s)
local-hostname: ${hostname}
EOF

    if command -v cloud-localds &>/dev/null; then
        cloud-localds "$seed_file" "$VM_DIR/ci-${name}/user-data" "$VM_DIR/ci-${name}/meta-data"
    fi

    echo -e "${BLUE}[3/4] Saving config...${NC}"
    cat > "$conf_file" <<EOF
# VM Config: ${name}
MEMORY=${memory}
CPUS=${cpus}
DISK_SIZE=${disk_size}
SWAP_SIZE=${swap_size}
SSH_PORT=${ssh_port}
HOSTNAME=${hostname}
USERNAME=${username}
PASSWORD=${password}
SEED_FILE=${seed_file}
EOF

    echo -e "${BLUE}[4/4] Registering VM...${NC}"
    db_add_vm "$name" "$img_file" "cloudimg"
    echo -e "${GREEN}[OK] VM '$name' created!${NC}"
    echo -e "     Image: ${img_file}"
    echo -e "     SSH: localhost:${ssh_port} (${username}:${password})"
}

create_from_targz() {
    local tarball="$1" name="$2"
    local memory="${3:-$DEFAULT_MEMORY}" cpus="${4:-$DEFAULT_CPUS}"
    local disk_size="${5:-$DEFAULT_DISK_SIZE}" label="${6:-$name}"

    if [[ ! -f "$tarball" ]]; then
        echo -e "${RED}[ERROR] File not found: $tarball${NC}"
        return 1
    fi

    local img_file="$VM_DIR/${name}.img"
    local conf_file="$VM_DIR/${name}.conf"
    local ssh_port=$(next_ssh_port)

    if [[ -f "$img_file" ]]; then
        echo -e "${YELLOW}[WARN] VM '$name' already exists. Delete it first.${NC}"
        return 1
    fi

    echo -e "${BLUE}[1/3] Converting tarball to image...${NC}"

    # Use our converter script if available
    if [[ -f "$(dirname "$0")/targztoimg.sh" ]]; then
        bash "$(dirname "$0")/targztoimg.sh" --no-bootloader -s "${disk_size%G}" -l "$label" "$tarball" "$img_file"
    else
        # Inline conversion (basic)
        echo -e "${YELLOW}[WARN] targztoimg.sh not found in script directory. Using basic conversion...${NC}"

        TEMP_ROOTFS=$(mktemp -d)
        tar -xzf "$tarball" -C "$TEMP_ROOTFS"

        # Flatten if nested
        FIRST=$(ls "$TEMP_ROOTFS" | head -1)
        if [[ -d "$TEMP_ROOTFS/$FIRST" ]] && [[ $(ls "$TEMP_ROOTFS" | wc -l) -eq 1 ]]; then
            if [[ -d "$TEMP_ROOTFS/$FIRST/bin" ]] || [[ -d "$TEMP_ROOTFS/$FIRST/usr" ]]; then
                NEST=$(mktemp -d)
                mv "$TEMP_ROOTFS/$FIRST/"* "$NEST/" 2>/dev/null; mv "$TEMP_ROOTFS/$FIRST/".[!.]* "$NEST/" 2>/dev/null
                rm -rf "$TEMP_ROOTFS"/*
                mv "$NEST/"* "$TEMP_ROOTFS/" 2>/dev/null; mv "$NEST/".[!.]* "$TEMP_ROOTFS/" 2>/dev/null
                rm -rf "$NEST"
            fi
        fi

        DISK_SECTORS=$(( ${disk_size%G} * 1024 * 1024 * 1024 / 512 ))
        dd if=/dev/zero of="$img_file" bs=1M count=0 seek="${disk_size%G}" status=progress 2>&1
        mkfs.ext4 -F -L "$label" "$img_file" 2>&1 | tail -1

        if command -v fuse2fs &>/dev/null; then
            MNT=$(mktemp -d)
            fuse2fs "$img_file" "$MNT" -o rw 2>/dev/null
            rsync -aHX --exclude='/dev/*' --exclude='/proc/*' --exclude='/sys/*' "$TEMP_ROOTFS/" "$MNT/"
            fusermount -u "$MNT" 2>/dev/null || true
            rm -rf "$MNT"
        elif command -v guestmount &>/dev/null; then
            MNT=$(mktemp -d)
            guestmount -a "$img_file" -m /dev/sda1 "$MNT"
            rsync -aHX --exclude='/dev/*' --exclude='/proc/*' --exclude='/sys/*' "$TEMP_ROOTFS/" "$MNT/"
            guestunmount "$MNT"
            rm -rf "$MNT"
        else
            echo -e "${RED}[ERROR] No mount tool available. Install fuse2fs (e2fsprogs) or guestmount (libguestfs-tools).${NC}"
            rm -rf "$TEMP_ROOTFS"
            rm -f "$img_file"
            return 1
        fi
        rm -rf "$TEMP_ROOTFS"
    fi

    echo -e "${BLUE}[2/3] Saving config...${NC}"
    cat > "$conf_file" <<EOF
# VM Config: ${name}
MEMORY=${memory}
CPUS=${cpus}
DISK_SIZE=${disk_size}
SSH_PORT=${ssh_port}
LABEL=${label}
FORMAT=raw
EOF

    echo -e "${BLUE}[3/3] Registering VM...${NC}"
    db_add_vm "$name" "$img_file" "targz"
    echo -e "${GREEN}[OK] VM '$name' created from tarball!${NC}"
    echo -e "     Image: ${img_file}"
    echo -e "     Format: raw ext4"
    echo -e "     SSH: localhost:${ssh_port}"
}

# =============================
# VM LIFECYCLE
# =============================
start_vm() {
    local name="$1"
    local vm_line
    vm_line=$(db_get_vm "$name")
    if [[ -z "$vm_line" ]]; then
        echo -e "${RED}[ERROR] VM '$name' not found.${NC}"
        return 1
    fi

    if is_vm_running "$name"; then
        echo -e "${YELLOW}[WARN] VM '$name' is already running.${NC}"
        return 0
    fi

    local img_path=$(db_get_field "$vm_line" 3)
    local source=$(db_get_field "$vm_line" 4)
    local conf_file="${img_path%.img}.conf"

    if [[ ! -f "$conf_file" ]]; then
        echo -e "${RED}[ERROR] Config file not found: $conf_file${NC}"
        return 1
    fi

    # Source config
    source "$conf_file"

    local accel_flag
    if [[ -e /dev/kvm ]]; then
        accel_flag="-enable-kvm -cpu host"
        echo -e "${GREEN}[INFO] KVM acceleration enabled${NC}"
    else
        accel_flag="-accel tcg"
        echo -e "${YELLOW}[INFO] Using TCG software emulation (slow)${NC}"
    fi

    local qemu_cmd="qemu-system-x86_64 $accel_flag -m ${MEMORY} -smp ${CPUS} -name ${name} -nographic -serial mon:stdio"
    qemu_cmd+=" -device virtio-net-pci,netdev=net0 -netdev user,id=net0,hostfwd=tcp::${SSH_PORT}-:22"

    if [[ "$source" == "cloudimg" ]]; then
        qemu_cmd+=" -drive file=${img_path},format=qcow2,if=virtio,cache=writeback"
        if [[ -f "${SEED_FILE:-}" ]]; then
            qemu_cmd+=" -drive file=${SEED_FILE},format=raw,if=virtio"
        fi
    elif [[ "$source" == "targz" ]]; then
        qemu_cmd+=" -drive file=${img_path},format=raw,if=virtio"
        # Try to find kernel/initrd
        if [[ -d "${img_path}_rootfs" ]]; then
            local kern=$(ls "${img_path}_rootfs/boot/vmlinuz"* 2>/dev/null | head -1)
            local init=$(ls "${img_path}_rootfs/boot/initrd"* 2>/dev/null | head -1)
            if [[ -n "$kern" ]]; then
                qemu_cmd+=" -kernel $kern"
                [[ -n "$init" ]] && qemu_cmd+=" -initrd $init"
                qemu_cmd+=' -append "root=/dev/vda1 ro console=ttyS0"'
            fi
        fi
    fi

    echo -e "${GREEN}[INFO] Starting VM '$name'...${NC}"
    echo -e "${CYAN}  SSH: ssh ${USERNAME:-ubuntu}@localhost:${SSH_PORT}${NC}"

    cleanup_vm() {
        echo -e "\n${YELLOW}[INFO] Stopping VM '$name'...${NC}"
        pkill -f "qemu-system.*${name}" || true
    }
    trap cleanup_vm SIGINT SIGTERM

    eval $qemu_cmd
    trap - SIGINT SIGTERM
}

stop_vm() {
    local name="$1"
    if ! is_vm_running "$name"; then
        echo -e "${YELLOW}[WARN] VM '$name' is not running.${NC}"
        return 0
    fi
    echo -e "${BLUE}[INFO] Stopping VM '$name'...${NC}"
    pkill -f "qemu-system.*${name}" || true
    sleep 2
    if is_vm_running "$name"; then
        pkill -9 -f "qemu-system.*${name}" || true
    fi
    echo -e "${GREEN}[OK] VM '$name' stopped.${NC}"
}

delete_vm() {
    local name="$1"
    if is_vm_running "$name"; then
        echo -e "${YELLOW}[WARN] Stopping VM '$name' first...${NC}"
        stop_vm "$name"
    fi

    local vm_line
    vm_line=$(db_get_vm "$name")
    if [[ -n "$vm_line" ]]; then
        local img_path=$(db_get_field "$vm_line" 3)
        local conf_file="${img_path%.img}.conf"
        local seed_file=""
        if [[ -f "$conf_file" ]]; then
            seed_file=$(grep "^SEED_FILE=" "$conf_file" 2>/dev/null | cut -d= -f2)
        fi

        rm -f "$img_path" "$conf_file" "$seed_file"
        rm -rf "$VM_DIR/ci-${name}"
        db_remove_vm "$name"
        echo -e "${GREEN}[OK] VM '$name' deleted.${NC}"
    else
        echo -e "${RED}[ERROR] VM '$name' not found.${NC}"
    fi
}

configure_vm() {
    local name="$1"
    local vm_line
    vm_line=$(db_get_vm "$name")
    if [[ -z "$vm_line" ]]; then
        echo -e "${RED}[ERROR] VM '$name' not found.${NC}"
        return 1
    fi

    local img_path=$(db_get_field "$vm_line" 3)
    local conf_file="${img_path%.img}.conf"

    if [[ ! -f "$conf_file" ]]; then
        echo -e "${RED}[ERROR] Config file not found.${NC}"
        return 1
    fi

    echo -e "${CYAN}=== Config for VM: ${name} ===${NC}"
    echo -e "Config file: ${conf_file}"
    echo ""
    cat "$conf_file"
    echo ""
    echo -e "${YELLOW}Edit the config file directly to change VM settings.${NC}"
}

# =============================
# INTERACTIVE MENU
# =============================
show_header() {
    clear
    echo -e "${BOLD}${BLUE}  ╔══════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}  ║       QEMU-FREEROOT v${VERSION}                 ║${NC}"
    echo -e "${BOLD}${BLUE}  ║   Credit: BlackCatOfficial, BiraloGaming   ║${NC}"
    echo -e "${BOLD}${BLUE}  ╚══════════════════════════════════════════╝${NC}"
    echo ""
}

show_vm_list() {
    echo -e "${BOLD}  VMs:${NC}"
    echo -e "${BOLD}  ──────────────────────────────────────────────────${NC}"

    if ! db_list_vms; then
        echo -e "${YELLOW}  (no VMs created yet)${NC}"
        echo ""
    else
        while IFS= read -r line; do
            local name=$(db_get_field "$line" 2)
            local img=$(db_get_field "$line" 3)
            local source=$(db_get_field "$line" 4)

            if is_vm_running "$name"; then
                status="${GREEN}● running${NC}"
            else
                status="${RED}■ stopped${NC}"
            fi

            local conf="${img%.img}.conf"
            local ssh_port=$DEFAULT_SSH_BASE
            [[ -f "$conf" ]] && ssh_port=$(grep "^SSH_PORT=" "$conf" 2>/dev/null | cut -d= -f2 || echo "$DEFAULT_SSH_PORT")

            printf "  %-4s %-18s %-10s %-6s %-12s\n" \
                "" "$name" "[$source]" "ssh:$ssh_port" "$(echo -e $status)"
        done < <(db_list_vms)
        echo ""
    fi
}

menu_main() {
    show_header
    show_vm_list

    echo -e "${BOLD}  Commands:${NC}"
    echo -e "${BOLD}  ──────────────────────────────────────────────────${NC}"
    echo -e "  ${CYAN}1${NC}. Create VM (from Ubuntu Cloud Image)"
    echo -e "  ${CYAN}2${NC}. Create VM (from .tar.gz rootfs)"
    echo -e "  ${CYAN}3${NC}. Start VM"
    echo -e "  ${CYAN}4${NC}. Stop VM"
    echo -e "  ${CYAN}5${NC}. Configure VM"
    echo -e "  ${CYAN}6${NC}. Delete VM"
    echo -e "  ${CYAN}7${NC}. Global Settings"
    echo -e "  ${CYAN}8${NC}. Quick Start (create + start in one step)"
    echo -e "  ${CYAN}0${NC}. Quit"
    echo ""
}

menu_create_cloudimg() {
    echo -e "${BOLD}${BLUE}=== Create VM from Cloud Image ===${NC}"
    echo ""

    local name img_url memory cpus disk_size swap_size hostname username password

    read -p "  VM name [ubuntu]: " name
    name=${name:-ubuntu}

    read -p "  Image URL [Ubuntu Resolute]: " img_url
    img_url=${img_url:-$DEFAULT_IMG_URL}

    read -p "  Memory [${DEFAULT_MEMORY}]: " memory
    memory=${memory:-$DEFAULT_MEMORY}

    read -p "  CPUs [${DEFAULT_CPUS}]: " cpus
    cpus=${cpus:-$DEFAULT_CPUS}

    read -p "  Disk size [${DEFAULT_DISK_SIZE}]: " disk_size
    disk_size=${disk_size:-$DEFAULT_DISK_SIZE}

    read -p "  Swap size [${DEFAULT_SWAP_SIZE}]: " swap_size
    swap_size=${swap_size:-$DEFAULT_SWAP_SIZE}

    read -p "  Hostname [${DEFAULT_HOSTNAME}]: " hostname
    hostname=${hostname:-$DEFAULT_HOSTNAME}

    read -p "  Username [${DEFAULT_USERNAME}]: " username
    username=${username:-$DEFAULT_USERNAME}

    read -p "  Password [${DEFAULT_PASSWORD}]: " password
    password=${password:-$DEFAULT_PASSWORD}

    echo ""
    create_from_cloudimg "$name" "$img_url" "$memory" "$cpus" "$disk_size" "$swap_size" "$hostname" "$username" "$password"

    read -p ""
}

menu_create_targz() {
    echo -e "${BOLD}${BLUE}=== Create VM from .tar.gz ===${NC}"
    echo ""

    local tarball name memory cpus disk_size label

    read -p "  Path to .tar.gz file: " tarball
    if [[ -z "$tarball" ]]; then
        echo -e "${RED}[ERROR] No file specified.${NC}"
        return 1
    fi

    read -p "  VM name: " name
    name=${name:-$(basename "$tarball" .tar.gz)}

    read -p "  Memory [${DEFAULT_MEMORY}]: " memory
    memory=${memory:-$DEFAULT_MEMORY}

    read -p "  CPUs [${DEFAULT_CPUS}]: " cpus
    cpus=${cpus:-$DEFAULT_CPUS}

    read -p "  Disk size [${DEFAULT_DISK_SIZE}]: " disk_size
    disk_size=${disk_size:-$DEFAULT_DISK_SIZE}

    read -p "  Filesystem label [$name]: " label
    label=${label:-$name}

    echo ""
    create_from_targz "$tarball" "$name" "$memory" "$cpus" "$disk_size" "$label"

    read -p ""
}

menu_start() {
    echo -e "${BOLD}${BLUE}=== Start VM ===${NC}"
    echo ""
    if ! db_list_vms; then
        echo -e "${YELLOW}No VMs available. Create one first.${NC}"
        read -p ""
        return 0
    fi
    read -p "  VM name: " name
    [[ -z "$name" ]] && return 0
    echo ""
    start_vm "$name"
}

menu_stop() {
    echo -e "${BOLD}${BLUE}=== Stop VM ===${NC}"
    echo ""
    if ! db_list_vms; then
        echo -e "${YELLOW}No VMs available.${NC}"
        read -p ""
        return 0
    fi
    read -p "  VM name: " name
    [[ -z "$name" ]] && return 0
    stop_vm "$name"
    read -p ""
}

menu_configure() {
    echo -e "${BOLD}${BLUE}=== Configure VM ===${NC}"
    echo ""
    if ! db_list_vms; then
        echo -e "${YELLOW}No VMs available.${NC}"
        read -p ""
        return 0
    fi
    read -p "  VM name: " name
    [[ -z "$name" ]] && return 0
    echo ""
    configure_vm "$name"
    read -p ""
}

menu_delete() {
    echo -e "${BOLD}${BLUE}=== Delete VM ===${NC}"
    echo ""
    if ! db_list_vms; then
        echo -e "${YELLOW}No VMs available.${NC}"
        read -p ""
        return 0
    fi
    read -p "  VM name: " name
    [[ -z "$name" ]] && return 0
    echo -e "${RED}This will delete all files for VM '$name'. Are you sure?${NC}"
    read -p "  Type '${name}' to confirm: " confirm
    if [[ "$confirm" == "$name" ]]; then
        delete_vm "$name"
    else
        echo -e "${YELLOW}Cancelled.${NC}"
    fi
    read -p ""
}

menu_global_settings() {
    echo -e "${BOLD}${BLUE}=== Global Settings ===${NC}"
    echo ""
    echo -e "  Current defaults:"
    echo -e "    Image URL:     ${DEFAULT_IMG_URL}"
    echo -e "    Memory:        ${DEFAULT_MEMORY}"
    echo -e "    CPUs:          ${DEFAULT_CPUS}"
    echo -e "    Disk size:     ${DEFAULT_DISK_SIZE}"
    echo -e "    Swap size:     ${DEFAULT_SWAP_SIZE}"
    echo -e "    SSH base port: ${DEFAULT_SSH_BASE}"
    echo -e "    Hostname:      ${DEFAULT_HOSTNAME}"
    echo -e "    Username:      ${DEFAULT_USERNAME}"
    echo -e "    Password:      ${DEFAULT_PASSWORD}"
    echo -e "    VM directory:  ${VM_DIR}"
    echo ""
    echo -e "${YELLOW}Edit the DEFAULT_* variables at the top of this script to change defaults.${NC}"
    echo -e "${YELLOW}Per-VM settings are stored in: ${VM_DIR}/<name>.conf${NC}"
    read -p ""
}

menu_quick_start() {
    echo -e "${BOLD}${BLUE}=== Quick Start (one-shot VM) ===${NC}"
    echo ""

    local name img_url memory cpus
    read -p "  VM name [quick]: " name
    name=${name:-quick}
    read -p "  Image URL [Ubuntu Resolute]: " img_url
    img_url=${img_url:-$DEFAULT_IMG_URL}
    read -p "  Memory [${DEFAULT_MEMORY}]: " memory
    memory=${memory:-$DEFAULT_MEMORY}
    read -p "  CPUs [${DEFAULT_CPUS}]: " cpus
    cpus=${cpus:-$DEFAULT_CPUS}

    create_from_cloudimg "$name" "$img_url" "$memory" "$cpus" 2>/dev/null
    echo ""
    echo -e "${CYAN}Press Ctrl+C to stop the VM.${NC}"
    read -p "Press Enter to start..."
    start_vm "$name"
}

# =============================
# CLI MODE (no arguments = menu)
# =============================
cli_mode() {
    local cmd="${1:-}"
    case "$cmd" in
        create)
            shift
            if [[ "${1:-}" == "--targz" ]]; then
                shift
                create_from_targz "$@"
            else
                create_from_cloudimg "$@"
            fi
            ;;
        start)  shift; start_vm "$@" ;;
        stop)   shift; stop_vm "$@" ;;
        delete) shift; delete_vm "$@" ;;
        list)
            show_header
            show_vm_list
            ;;
        *)
            echo -e "${BOLD}QEMU-FREEROOT v${VERSION}${NC}"
            echo ""
            echo "Usage: $0 <command> [options]"
            echo ""
            echo "Commands:"
            echo "  (no args)           Interactive menu"
            echo "  create [NAME]       Create VM from cloud image"
            echo "  create --targz <file> <NAME>"
            echo "                      Create VM from .tar.gz rootfs"
            echo "  start <NAME>        Start VM"
            echo "  stop <NAME>         Stop VM"
            echo "  delete <NAME>       Delete VM"
            echo "  list                List all VMs"
            echo ""
            echo "Quick start (one-shot):"
            echo "  QUICK=yes $0        Create + start default VM immediately"
            exit 0
            ;;
    esac
}

# =============================
# MAIN
# =============================
db_init
check_tools

if [[ "${1:-}" != "" ]] && [[ "${QUICK:-no}" != "yes" ]]; then
    cli_mode "$@"
    exit 0
fi

# Quick start mode
if [[ "${QUICK:-no}" == "yes" ]]; then
    create_from_cloudimg "quick" 2>/dev/null || true
    start_vm "quick"
    exit 0
fi

# Interactive menu loop
while true; do
    menu_main
    read -p "  > " choice
    case "$choice" in
        1) menu_create_cloudimg ;;
        2) menu_create_targz ;;
        3) menu_start ;;
        4) menu_stop ;;
        5) menu_configure ;;
        6) menu_delete ;;
        7) menu_global_settings ;;
        8) menu_quick_start ;;
        0|q|quit|exit) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option.${NC}"; sleep 1 ;;
    esac
done
