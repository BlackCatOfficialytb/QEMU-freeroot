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
# CLOUDFLARED TUNNEL
# =============================
cf_tunnel_start() {
    local name="$1" ssh_port="$2"
    local tunnel_dir="$VM_DIR/tunnels"
    local tunnel_pid_file="$tunnel_dir/${name}.pid"
    local tunnel_url_file="$tunnel_dir/${name}.url"

    mkdir -p "$tunnel_dir"

    if [[ -f "$tunnel_pid_file" ]] && kill -0 "$(cat "$tunnel_pid_file")" 2>/dev/null; then
        echo -e "${YELLOW}[INFO] Cloudflared tunnel already running for '$name'.${NC}"
        cat "$tunnel_url_file" 2>/dev/null
        return 0
    fi

    if ! command -v cloudflared &>/dev/null; then
        echo -e "${RED}[ERROR] cloudflared not found. Install it first.${NC}"
        echo -e "${YELLOW}Run: bash install_cloudflared.sh${NC}"
        return 1
    fi

    echo -e "${BLUE}[INFO] Starting cloudflared tunnel for SSH (port $ssh_port)...${NC}"
    cloudflared tunnel --url ssh://localhost:$ssh_port >"$tunnel_url_file" 2>&1 &
    local cf_pid=$!
    echo "$cf_pid" > "$tunnel_pid_file"

    echo -e "${YELLOW}[INFO] Waiting for tunnel URL...${NC}"
    local tries=0
    while [[ $tries -lt 30 ]]; do
        sleep 1
        if grep -q "https://" "$tunnel_url_file" 2>/dev/null; then
            local url=$(grep -oP 'https://[a-z0-9-]+\.trycloudflare\.com' "$tunnel_url_file" | head -1)
            if [[ -n "$url" ]]; then
                echo "$url" > "$tunnel_url_file"
                echo -e "${GREEN}[OK] Tunnel URL: ${url}${NC}"
                return 0
            fi
        fi
        tries=$((tries + 1))
    done

    echo -e "${RED}[ERROR] Tunnel URL not received in time. Check $tunnel_url_file${NC}"
    return 1
}

cf_tunnel_stop() {
    local name="$1"
    local tunnel_dir="$VM_DIR/tunnels"
    local tunnel_pid_file="$tunnel_dir/${name}.pid"

    if [[ -f "$tunnel_pid_file" ]]; then
        local pid=$(cat "$tunnel_pid_file")
        kill "$pid" 2>/dev/null || true
        rm -f "$tunnel_pid_file" "$tunnel_dir/${name}.url"
        echo -e "${GREEN}[OK] Cloudflared tunnel stopped for '$name'.${NC}"
    fi
}

cf_tunnel_get_url() {
    local name="$1"
    local tunnel_dir="$VM_DIR/tunnels"
    local tunnel_url_file="$tunnel_dir/${name}.url"

    if [[ -f "$tunnel_url_file" ]]; then
        grep -oP 'https://[a-z0-9-]+\.trycloudflare\.com' "$tunnel_url_file" | head -1
    else
        echo ""
    fi
}

# =============================
# VM CONTROL (direct interaction)
# =============================
get_qemu_pid() {
    local name="$1"
    local pid_file="$VM_DIR/${name}.pid"
    if [[ -f "$pid_file" ]]; then
        cat "$pid_file"
    else
        pgrep -f "qemu-system.*${name}" | head -1
    fi
}

control_vm() {
    local name="$1"
    local vm_line
    vm_line=$(db_get_vm "$name")
    if [[ -z "$vm_line" ]]; then
        echo -e "${RED}[ERROR] VM '$name' not found.${NC}"
        return 1
    fi

    local pid=$(get_qemu_pid "$name")
    if [[ -z "$pid" ]]; then
        echo -e "${RED}[ERROR] VM '$name' is not running.${NC}"
        return 1
    fi

    local img_path=$(db_get_field "$vm_line" 3)
    local conf_file="${img_path%.img}.conf"
    local ssh_port=$DEFAULT_SSH_BASE
    local username="ubuntu"
    [[ -f "$conf_file" ]] && {
        ssh_port=$(grep "^SSH_PORT=" "$conf_file" 2>/dev/null | cut -d= -f2 || echo "$DEFAULT_SSH_BASE")
        username=$(grep "^USERNAME=" "$conf_file" 2>/dev/null | cut -d= -f2 || echo "ubuntu")
    }

    local serial_sock="$VM_DIR/${name}-serial.sock"
    local monitor_sock="$VM_DIR/${name}-monitor.sock"
    local cf_url=$(cf_tunnel_get_url "$name")

    echo -e "${BOLD}${BLUE}=== Control VM: ${name} (PID: ${pid}) ===${NC}"
    echo ""
    echo -e "  ${CYAN}1${NC}. Watch QEMU ttyS0 (serial console)"
    echo -e "  ${CYAN}2${NC}. SSH into VM (cloudflared${cf_url:+: ${GREEN}${cf_url}${NC}})"
    echo -e "  ${CYAN}3${NC}. Send command via SSH (cloudflared)"
    echo -e "  ${CYAN}4${NC}. Pause / Resume VM"
    echo -e "  ${CYAN}5${NC}. Send key combo (QEMU monitor)"
    echo -e "  ${CYAN}6${NC}. Create snapshot"
    echo -e "  ${CYAN}7${NC}. View VM info"
    echo -e "  ${CYAN}8${NC}. Resize disk"
    echo -e "  ${CYAN}9${NC}. Manage cloudflared tunnel"
    echo -e "  ${CYAN}0${NC}. Back"
    echo ""
    read -p "  > " ctrl_choice

    case "$ctrl_choice" in
        1)
            if [[ -S "$serial_sock" ]]; then
                echo -e "${GREEN}[INFO] Connecting to serial console...${NC}"
                echo -e "${YELLOW}(Press Ctrl+] to disconnect)${NC}"
                echo ""
                if command -v socat &>/dev/null; then
                    socat - UNIX-CONNECT:"$serial_sock"
                elif command -v nc &>/dev/null; then
                    nc -U "$serial_sock"
                else
                    echo -e "${RED}[ERROR] No serial client found. Install socat or netcat-openbsd.${NC}"
                fi
            else
                echo -e "${YELLOW}[WARN] VM was started in foreground mode (serial on stdio).${NC}"
                echo -e "${YELLOW}       Stop and restart with: ./vm.sh start-bg $name${NC}"
            fi
            ;;
        2)
            cf_url=$(cf_tunnel_get_url "$name")
            if [[ -z "$cf_url" ]]; then
                echo -e "${YELLOW}[INFO] No active cloudflared tunnel. Starting...${NC}"
                if cf_tunnel_start "$name" "$ssh_port"; then
                    cf_url=$(cf_tunnel_get_url "$name")
                else
                    echo -e "${RED}[ERROR] Cannot start tunnel. Falling back to direct SSH.${NC}"
                    echo -e "${GREEN}[INFO] Connecting: ${username}@localhost:${ssh_port}${NC}"
                    echo -e "${YELLOW}(Type 'exit' or Ctrl+D to return)${NC}"
                    echo ""
                    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 "${username}@localhost:${ssh_port}" 2>/dev/null || \
                    echo -e "${RED}[ERROR] SSH connection failed.${NC}"
                    read -p ""
                    return 0
                fi
            fi
            echo -e "${GREEN}[INFO] Connecting SSH via cloudflared: ${cf_url}${NC}"
            echo -e "${YELLOW}(Type 'exit' or Ctrl+D to return)${NC}"
            echo ""
            ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
                -o ProxyCommand="cloudflared access ssh --hostname ${cf_url}" \
                "${username}@${cf_url#https://}" 2>/dev/null || \
            echo -e "${RED}[ERROR] SSH connection failed. Is sshd running in the VM?${NC}"
            ;;
        3)
            read -p "  Command to send: " cmd
            if [[ -n "$cmd" ]]; then
                cf_url=$(cf_tunnel_get_url "$name")
                echo -e "${GREEN}[INFO] Executing: $cmd${NC}"
                echo "---"
                if [[ -n "$cf_url" ]]; then
                    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
                        -o ProxyCommand="cloudflared access ssh --hostname ${cf_url}" \
                        "${username}@${cf_url#https://}" "$cmd" 2>/dev/null || \
                    echo -e "${RED}[ERROR] SSH connection failed.${NC}"
                else
                    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
                        "${username}@localhost:${ssh_port}" "$cmd" 2>/dev/null || \
                    echo -e "${RED}[ERROR] SSH connection failed.${NC}"
                fi
                echo "---"
            fi
            ;;
        4)
            local proc_state=$(ps -o state= -p "$pid" 2>/dev/null | tr -d ' ')
            if [[ "$proc_state" == "T" ]]; then
                echo -e "${BLUE}[INFO] Resuming VM...${NC}"
                kill -SIGCONT "$pid"
                echo -e "${GREEN}[OK] VM resumed.${NC}"
            else
                echo -e "${BLUE}[INFO] Pausing VM (SIGSTOP)...${NC}"
                kill -SIGSTOP "$pid"
                echo -e "${GREEN}[OK] VM paused. Use Control > Resume to unpause.${NC}"
            fi
            ;;
        5)
            echo -e "  Key combos (via QEMU monitor):"
            echo -e "  ${CYAN}1${NC}. Ctrl+Alt+Del (force reboot)"
            echo -e "  ${CYAN}2${NC}. Ctrl+A x (quit VM)"
            echo -e "  ${CYAN}3${NC}. Open monitor shell"
            echo -e "  ${CYAN}4${NC}. Custom sendkey"
            echo -e "  ${CYAN}5${NC}. Custom monitor command"
            echo ""
            read -p "  > " key_choice
            case "$key_choice" in
                1)
                    if [[ -S "$monitor_sock" ]]; then
                        echo "sendkey ctrl-alt-delete" | socat - UNIX-CONNECT:"$monitor_sock" 2>/dev/null
                        echo -e "${GREEN}[OK] Sent ctrl-alt-delete via monitor.${NC}"
                    else
                        echo -e "${YELLOW}[WARN] No monitor socket. Using SIGINT fallback...${NC}"
                        kill -SIGINT "$pid"
                        echo -e "${GREEN}[OK] Sent SIGINT.${NC}"
                    fi
                    ;;
                2)
                    if [[ -S "$monitor_sock" ]]; then
                        echo "quit" | socat - UNIX-CONNECT:"$monitor_sock" 2>/dev/null
                        echo -e "${GREEN}[OK] Quit command sent.${NC}"
                    else
                        pkill -f "qemu-system.*${name}"
                        echo -e "${GREEN}[OK] VM killed.${NC}"
                    fi
                    ;;
                3)
                    if [[ -S "$monitor_sock" ]]; then
                        echo -e "${YELLOW}[INFO] Monitor shell (type 'help' for commands, 'quit' to exit):${NC}"
                        socat - UNIX-CONNECT:"$monitor_sock"
                    else
                        echo -e "${YELLOW}[WARN] No monitor socket available.${NC}"
                    fi
                    ;;
                4)
                    read -p "  Keys (e.g. ret, spc, ctrl-a, shift-tab): " keys
                    if [[ -S "$monitor_sock" ]]; then
                        echo "sendkey $keys" | socat - UNIX-CONNECT:"$monitor_sock" 2>/dev/null
                        echo -e "${GREEN}[OK] Sent: sendkey $keys${NC}"
                    else
                        echo -e "${RED}[ERROR] No monitor socket.${NC}"
                    fi
                    ;;
                5)
                    read -p "  Monitor command: " mon_cmd
                    if [[ -S "$monitor_sock" ]]; then
                        echo -e "${YELLOW}Executing: $mon_cmd${NC}"
                        echo "$mon_cmd" | socat - UNIX-CONNECT:"$monitor_sock" 2>/dev/null
                    else
                        echo -e "${RED}[ERROR] No monitor socket.${NC}"
                    fi
                    ;;
                *) echo -e "${RED}Invalid.${NC}" ;;
            esac
            ;;
        6)
            echo -e "${BLUE}[INFO] Creating snapshot...${NC}"
            local snapshot_name="${name}-$(date +%Y%m%d-%H%M%S)"
            if command -v qemu-img &>/dev/null; then
                qemu-img snapshot -c "$snapshot_name" "$img_path" 2>/dev/null && \
                    echo -e "${GREEN}[OK] Snapshot '$snapshot_name' created.${NC}" || \
                    echo -e "${YELLOW}[WARN] Snapshot failed (image may be locked or format unsupported).${NC}"
            else
                echo -e "${RED}[ERROR] qemu-img not found.${NC}"
            fi
            ;;
        7)
            echo -e "${CYAN}VM Info: ${name}${NC}"
            echo -e "${BOLD}  ──────────────────────────────────────────────────${NC}"
            echo -e "  PID:           ${pid}"
            echo -e "  Status:        $(ps -o state= -p "$pid" 2>/dev/null | tr -d ' ' || echo 'unknown')"
            echo -e "  Image:         ${img_path}"
            echo -e "  Image size:    $(du -sh "$img_path" 2>/dev/null | awk '{print $1}')"
            echo -e "  SSH local:     ${username}@localhost:${ssh_port}"
            cf_url=$(cf_tunnel_get_url "$name")
            if [[ -n "$cf_url" ]]; then
                echo -e "  SSH cloudflare: ${GREEN}${cf_url}${NC}"
            else
                echo -e "  SSH cloudflare: ${RED}not running${NC}"
            fi
            echo -e "  Serial socket: $([ -S "$serial_sock" ] && echo "${GREEN}active${NC}" || echo "${RED}N/A (foreground mode)${NC}")"
            echo -e "  Monitor socket: $([ -S "$monitor_sock" ] && echo "${GREEN}active${NC}" || echo "${RED}N/A${NC}")"
            echo -e "  Uptime:        $(ps -o etime= -p "$pid" 2>/dev/null | tr -d ' ' || echo 'unknown')"
            echo -e "  Memory (RSS):  $(ps -o rss= -p "$pid" 2>/dev/null | awk '{printf "%.0f MB", $1/1024}' || echo 'unknown')"
            echo -e "  CPU %%:         $(ps -o %cpu= -p "$pid" 2>/dev/null | tr -d ' ' || echo 'unknown')%"
            if command -v nc &>/dev/null; then
                if nc -z -w2 localhost "$ssh_port" 2>/dev/null; then
                    echo -e "  SSH status:    ${GREEN}reachable${NC}"
                else
                    echo -e "  SSH status:    ${RED}not reachable (VM booting?)${NC}"
                fi
            fi
            if command -v qemu-img &>/dev/null; then
                local snaps=$(qemu-img snapshot -l "$img_path" 2>/dev/null | tail -n +2)
                if [[ -n "$snaps" ]]; then
                    echo -e "  Snapshots:"
                    echo "$snaps" | while read -r snap_line; do
                        echo -e "    $snap_line"
                    done
                fi
            fi
            echo -e "${BOLD}  ──────────────────────────────────────────────────${NC}"
            ;;
        8)
            read -p "  New disk size (e.g. 40G): " new_size
            if [[ -n "$new_size" ]]; then
                echo -e "${YELLOW}[WARN] This will resize the VM disk to ${new_size}.${NC}"
                echo -e "${YELLOW}       You may need to grow the partition inside the VM.${NC}"
                read -p "  Confirm? (y/N): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    if command -v qemu-img &>/dev/null; then
                        qemu-img resize "$img_path" "$new_size" 2>/dev/null && \
                            echo -e "${GREEN}[OK] Disk resized to ${new_size}.${NC}" || \
                            echo -e "${RED}[ERROR] Resize failed.${NC}"
                    else
                        echo -e "${RED}[ERROR] qemu-img not found.${NC}"
                    fi
                else
                    echo -e "${YELLOW}Cancelled.${NC}"
                fi
            fi
            ;;
        9)
            cf_url=$(cf_tunnel_get_url "$name")
            echo -e "  ${CYAN}1${NC}. Start cloudflared tunnel"
            echo -e "  ${CYAN}2${NC}. Stop cloudflared tunnel"
            echo -e "  ${CYAN}3${NC}. Show tunnel URL"
            echo ""
            read -p "  > " tunnel_choice
            case "$tunnel_choice" in
                1) cf_tunnel_start "$name" "$ssh_port" ;;
                2) cf_tunnel_stop "$name" ;;
                3)
                    if [[ -n "$cf_url" ]]; then
                        echo -e "${GREEN}  URL: ${cf_url}${NC}"
                    else
                        echo -e "${YELLOW}  No active tunnel.${NC}"
                    fi
                    ;;
                *) ;;
            esac
            ;;
        0|q) return 0 ;;
        *) echo -e "${RED}Invalid option.${NC}" ;;
    esac

    read -p ""
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
    echo -e "  ${CYAN}3${NC}. Start VM (background + serial/monitor socket)"
    echo -e "  ${CYAN}4${NC}. Stop VM"
    echo -e "  ${CYAN}5${NC}. Control VM"
    echo -e "  ${CYAN}6${NC}. Configure VM"
    echo -e "  ${CYAN}7${NC}. Delete VM"
    echo -e "  ${CYAN}8${NC}. Global Settings"
    echo -e "  ${CYAN}9${NC}. Quick Start (create + start in one step)"
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
    echo -e "${BOLD}${BLUE}=== Start VM (background) ===${NC}"
    echo ""
    if ! db_list_vms; then
        echo -e "${YELLOW}No VMs available. Create one first.${NC}"
        read -p ""
        return 0
    fi
    read -p "  VM name: " name
    [[ -z "$name" ]] && return 0
    echo ""
    start_vm "$name" "no"
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

menu_control() {
    echo -e "${BOLD}${BLUE}=== Control VM ===${NC}"
    echo ""
    if ! db_list_vms; then
        echo -e "${YELLOW}No VMs available.${NC}"
        read -p ""
        return 0
    fi
    read -p "  VM name: " name
    [[ -z "$name" ]] && return 0
    echo ""
    control_vm "$name"
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
        control) shift; control_vm "$@" ;;
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
            echo "  control <NAME>      Control VM (SSH, pause, snapshot, etc.)"
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
        5) menu_control ;;
        6) menu_configure ;;
        7) menu_delete ;;
        8) menu_global_settings ;;
        9) menu_quick_start ;;
        0|q|quit|exit) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option.${NC}"; sleep 1 ;;
    esac
done
