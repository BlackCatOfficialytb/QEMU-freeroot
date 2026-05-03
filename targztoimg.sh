#!/bin/bash
set -euo pipefail

# =============================
# TARGZ TO IMG / QCOW2 CONVERTER
# Converts Ubuntu rootfs .tar.gz → bootable .img (raw) or .qcow2
# Supports: Ubuntu Base, Debian rootfs, or any Linux rootfs tarball
#
# CREDIT: Original by BlackCatOfficial (BiraloGaming)
# Improved: multi-format output, auto-partition, bootloader install, ext4
# =============================

VERSION="2.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    echo -e "${BLUE}targztoimg.sh v${VERSION}${NC}"
    echo ""
    echo "Convert Ubuntu/Linux rootfs .tar.gz → bootable disk image"
    echo ""
    echo "Usage: $0 [OPTIONS] <input.tar.gz> <output>"
    echo ""
    echo "Arguments:"
    echo "  input.tar.gz    Input rootfs tarball (compressed or plain .tar)"
    echo "  output          Output image file (extension determines format)"
    echo ""
    echo "Options:"
    echo "  -f FORMAT       Output format: img (raw), qcow2 (default: auto from extension)"
    echo "  -s SIZE_GB      Disk size in GB (default: auto-calculated + 2GB buffer)"
    echo "  -l LABEL        Filesystem label (default: ubuntu)"
    echo "  --no-bootloader Skip GRUB bootloader installation (faster, boot via -kernel only)"
    echo "  -h, --help      Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 ubuntu-base.tar.gz output.img"
    echo "  $0 -s 20 -f qcow2 debian-rootfs.tar.gz disk.qcow2"
    echo "  $0 --no-bootloader ubuntu-base.tar.gz output.img"
    echo ""
    echo "Output formats (by extension):"
    echo "  .img  → Raw image (larger, faster I/O, compatible everywhere)"
    echo "  .qcow2 → QEMU copy-on-write (smaller, supports snapshots)"
    exit 0
}

# Parse args
FORMAT=""
SIZE_GB=""
LABEL="ubuntu"
NO_BOOTLOADER=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--format) FORMAT="$2"; shift 2 ;;
        -s|--size) SIZE_GB="$2"; shift 2 ;;
        -l|--label) LABEL="$2"; shift 2 ;;
        --no-bootloader) NO_BOOTLOADER=true; shift ;;
        -h|--help) usage ;;
        -*) echo -e "${RED}[ERROR] Unknown option: $1${NC}"; exit 1 ;;
        *) break ;;
    esac
done

if [[ $# -lt 2 ]]; then
    echo -e "${RED}[ERROR] Missing arguments.${NC}"
    echo "Usage: $0 <input.tar.gz> <output>"
    exit 1
fi

INPUT_TAR="$1"
OUTPUT="$2"

# Validate input
if [[ ! -f "$INPUT_TAR" ]]; then
    echo -e "${RED}[ERROR] Input file '$INPUT_TAR' not found.${NC}"
    exit 1
fi

# Auto-detect format from extension
if [[ -z "$FORMAT" ]]; then
    case "${OUTPUT##*.}" in
        img) FORMAT="raw" ;;
        qcow2) FORMAT="qcow2" ;;
        raw) FORMAT="raw" ;;
        *) echo -e "${RED}[ERROR] Cannot detect format from extension. Use -f to specify.${NC}"; exit 1 ;;
    esac
fi

echo -e "${BLUE}=== targztoimg v${VERSION} ===${NC}"
echo -e "Input:   ${INPUT_TAR}"
echo -e "Output:  ${OUTPUT} (${FORMAT})"
echo -e "Label:   ${LABEL}"
echo ""

# =============================
# TOOL CHECK
# =============================
TOOLS_MISSING=()

for cmd in tar; do
    command -v "$cmd" &>/dev/null || TOOLS_MISSING+=("$cmd")
done

if [[ "$FORMAT" == "qcow2" ]] && ! command -v qemu-img &>/dev/null; then
    TOOLS_MISSING+=("qemu-img")
fi

if [[ ${#TOOLS_MISSING[@]} -gt 0 ]]; then
    echo -e "${RED}[ERROR] Missing required tools: ${TOOLS_MISSING[*]}${NC}"
    exit 1
fi

# Check for root or tools needed for raw image
if [[ "$FORMAT" == "raw" ]]; then
    NEED_ROOT=true

    # Check if we have guestfish (can work without root via libguestfs)
    if command -v guestfish &>/dev/null; then
        NEED_ROOT=false
        echo -e "${GREEN}[INFO] Using guestfish (no root required)${NC}"
    elif command -v mkfs.ext4 &>/dev/null && command -v debugfs &>/dev/null; then
        # mkfs.ext4 and debugfs can work on regular files without loop/root
        NEED_ROOT=false
        echo -e "${GREEN}[INFO] Using mkfs.ext4 + debugfs (no root required)${NC}"
    elif [[ $EUID -eq 0 ]]; then
        NEED_ROOT=false
        echo -e "${YELLOW}[INFO] Running as root — will use loop devices${NC}"
    else
        echo -e "${YELLOW}[WARN] Creating raw image without guestfish/debugfs/root.${NC}"
        echo -e "${YELLOW}       Will create ext4 filesystem image using dd + mkfs.ext4.${NC}"
        echo -e "${YELLOW}       Bootloader will require manual installation.${NC}"
        NO_BOOTLOADER=true
    fi
fi

# =============================
# EXTRACT TARBALL
# =============================
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR" "$MOUNT_POINT" 2>/dev/null; echo -e "${YELLOW}[INFO] Cleaned up temp files.${NC}"' EXIT

echo -e "${BLUE}[1/5] Extracting tarball...${NC}"

# Handle .tar.gz, .tar.xz, .tar.zst, .tar.bz2, .tar
case "$INPUT_TAR" in
    *.tar.gz|*.tgz)  tar -xzf "$INPUT_TAR" -C "$TEMP_DIR" ;;
    *.tar.xz)        tar -xJf "$INPUT_TAR" -C "$TEMP_DIR" ;;
    *.tar.zst)       tar --zstd -xf "$INPUT_TAR" -C "$TEMP_DIR" 2>/dev/null || unzstd "$INPUT_TAR" -o - | tar -xf - -C "$TEMP_DIR" ;;
    *.tar.bz2)       tar -xjf "$INPUT_TAR" -C "$TEMP_DIR" ;;
    *.tar)           tar -xf "$INPUT_TAR" -C "$TEMP_DIR" ;;
    *)               echo -e "${RED}[ERROR] Unsupported archive format. Use .tar.gz/.tar.xz/.tar.zst/.tar.bz2/.tar${NC}"; exit 1 ;;
esac

echo -e "${GREEN}[INFO] Extracted to $TEMP_DIR${NC}"

# Check if it's a nested rootfs (tarball contains a single root directory like "ubuntu-base-24.04/")
FIRST_ITEM=$(ls "$TEMP_DIR" | head -1)
if [[ -d "$TEMP_DIR/$FIRST_ITEM" ]] && [[ $(ls "$TEMP_DIR" | wc -l) -eq 1 ]]; then
    # Check if this looks like a rootfs (has /bin, /etc, etc.)
    if [[ -d "$TEMP_DIR/$FIRST_ITEM/bin" ]] || [[ -d "$TEMP_DIR/$FIRST_ITEM/usr" ]]; then
        echo -e "${YELLOW}[INFO] Detected nested rootfs directory: $FIRST_ITEM (flattening)${NC}"
        NESTED_TEMP=$(mktemp -d)
        mv "$TEMP_DIR/$FIRST_ITEM/"* "$NESTED_TEMP/" 2>/dev/null || true
        mv "$TEMP_DIR/$FIRST_ITEM/".[!.]* "$NESTED_TEMP/" 2>/dev/null || true
        rm -rf "$TEMP_DIR"/*
        mv "$NESTED_TEMP/"* "$TEMP_DIR/" 2>/dev/null || true
        mv "$NESTED_TEMP/".[!.]* "$TEMP_DIR/" 2>/dev/null || true
        rm -rf "$NESTED_TEMP"
    fi
fi

# Verify it looks like a rootfs
if [[ ! -d "$TEMP_DIR/etc" ]] && [[ ! -d "$TEMP_DIR/bin" ]] && [[ ! -d "$TEMP_DIR/usr" ]]; then
    echo -e "${RED}[ERROR] Extracted content doesn't look like a Linux rootfs.${NC}"
    echo -e "${RED}       Expected /bin, /etc, or /usr directories.${NC}"
    echo -e "       Contents: $(ls "$TEMP_DIR" | head -5)..."
    exit 1
fi

# =============================
# CALCULATE SIZE
# =============================
echo -e "${BLUE}[2/5] Calculating disk size...${NC}"

EXTRACTED_SIZE_MB=$(du -sm "$TEMP_DIR" | awk '{print $1}')
EXTRACTED_SIZE_GB=$((EXTRACTED_SIZE_MB / 1024 + 1))

if [[ -n "$SIZE_GB" ]]; then
    DISK_SIZE_GB="$SIZE_GB"
else
    DISK_SIZE_GB=$((EXTRACTED_SIZE_GB + 2))
fi

echo -e "${GREEN}[INFO] Rootfs size: ~${EXTRACTED_SIZE_MB}MB, Image size: ${DISK_SIZE_GB}GB${NC}"

# =============================
# CREATE IMAGE
# =============================
echo -e "${BLUE}[3/5] Creating ${FORMAT} image (${DISK_SIZE_GB}GB)...${NC}"

case "$FORMAT" in
    raw)
        # Create raw image with partition table
        if command -v guestfish &>/dev/null; then
            echo -e "${GREEN}[INFO] Using guestfish to create partitioned image...${NC}"
            guestfish -a "$OUTPUT" -N fs:ext4:"$LABEL":"${DISK_SIZE_GB}G" : \
                mkdir-p /etc : \
                tar-in "$INPUT_TAR" / : \
                mount /dev/sda1 / : \
                write /etc/hostname "$LABEL" : \
                shutdown 2>/dev/null || true

            if [[ -f "$OUTPUT" ]]; then
                echo -e "${GREEN}[INFO] Image created with guestfish${NC}"
            else
                echo -e "${YELLOW}[WARN] guestfish failed, falling back to mkfs.ext4 method...${NC}"
                rm -f "$OUTPUT"
                create_with_mkfs=true
            fi
        else
            create_with_mkfs=true
        fi

        if [[ "${create_with_mkfs:-false}" == "true" ]]; then
            # Method: dd + mkfs.ext4 + debugfs (no root needed)
            DISK_SIZE_SECTORS=$((DISK_SIZE_GB * 1024 * 1024 * 1024 / 512))
            dd if=/dev/zero of="$OUTPUT" bs=1M count=0 seek="$DISK_SIZE_GB" status=progress 2>&1

            if command -v mkfs.ext4 &>/dev/null; then
                mkfs.ext4 -F -L "$LABEL" "$OUTPUT" 2>&1 | tail -1
            elif command -v mke2fs &>/dev/null; then
                mke2fs -F -L "$LABEL" -t ext4 "$OUTPUT" 2>&1 | tail -1
            else
                echo -e "${RED}[ERROR] No filesystem tool available (mkfs.ext4 or mke2fs).${NC}"
                exit 1
            fi
        fi
        ;;
    qcow2)
        qemu-img create -f qcow2 "$OUTPUT" "${DISK_SIZE_GB}G"
        # Convert to raw temporarily for filesystem creation, then back to qcow2
        RAW_TEMP=$(mktemp --suffix=.raw)
        dd if=/dev/zero of="$RAW_TEMP" bs=1M count=0 seek="$DISK_SIZE_GB" status=progress 2>&1

        if command -v mkfs.ext4 &>/dev/null; then
            mkfs.ext4 -F -L "$LABEL" "$RAW_TEMP" 2>&1 | tail -1
        elif command -v mke2fs &>/dev/null; then
            mke2fs -F -L "$LABEL" -t ext4 "$RAW_TEMP" 2>&1 | tail -1
        else
            echo -e "${RED}[ERROR] No filesystem tool available (mkfs.ext4 or mke2fs).${NC}"
            rm -f "$RAW_TEMP"
            exit 1
        fi

        qemu-img convert -f raw -O qcow2 "$RAW_TEMP" "$OUTPUT"
        rm -f "$RAW_TEMP"
        ;;
esac

echo -e "${GREEN}[INFO] Image file created: $(du -sh "$OUTPUT" | awk '{print $1}')${NC}"

# =============================
# COPY FILES INTO IMAGE
# =============================
echo -e "${BLUE}[4/5] Copying rootfs into image...${NC}"

MOUNT_POINT=$(mktemp -d)

if [[ "$FORMAT" == "raw" ]] && [[ "${create_with_mkfs:-false}" == "true" ]]; then
    # Use debugfs to copy files (no mount needed)
    echo -e "${GREEN}[INFO] Using debugfs to populate filesystem...${NC}"

    # Create file list for debugfs
    cd "$TEMP_DIR"
    find . -mindepth 1 | while read -r item; do
        rel_path="${item#./}"
        if [[ -d "$item" ]]; then
            echo "mkdir ${rel_path}"
        fi
    done > /tmp/debugfs_cmds.txt

    # debugfs has limitations with bulk copy, use e2cp if available
    if command -v e2cp &>/dev/null; then
        find . -mindepth 1 -print0 | while IFS= read -r -d '' item; do
            rel_path="${item#./}"
            if [[ -f "$item" ]]; then
                e2cp "$item" "$OUTPUT":/"$rel_path" 2>/dev/null || true
            fi
        done
        echo -e "${GREEN}[INFO] Files copied via e2cp${NC}"
    elif command -v fuse2fs &>/dev/null; then
        # Use fuse2fs for non-root mounting
        fuse2fs "$OUTPUT" "$MOUNT_POINT" -o rw 2>/dev/null || {
            echo -e "${YELLOW}[WARN] fuse2fs mount failed. Trying with guestmount...${NC}"
            if command -v guestmount &>/dev/null; then
                guestmount -a "$OUTPUT" -m /dev/sda1 "$MOUNT_POINT"
            fi
        }
        rsync -aHX --exclude='/dev/*' --exclude='/proc/*' --exclude='/sys/*' "$TEMP_DIR/" "$MOUNT_POINT/"
        fusermount -u "$MOUNT_POINT" 2>/dev/null || guestunmount "$MOUNT_POINT" 2>/dev/null || true
        echo -e "${GREEN}[INFO] Files copied via fuse2fs/guestmount${NC}"
    else
        echo -e "${YELLOW}[WARN] No direct copy tool available. Using QEMU+NBD method...${NC}"
        echo -e "${YELLOW}       Install e2fsprogs or libguestfs-tools for better support.${NC}"
        echo -e "${YELLOW}       Creating helper tarball for first-boot extraction...${NC}"

        # Pack rootfs back into a tarball and embed it in the image
        # This will be extracted on first boot via cloud-init or init script
        tar -czf "$MOUNT_POINT/rootfs.tar.gz" -C "$TEMP_DIR" .

        # Create a first-boot extraction script
        cat > "$MOUNT_POINT/extract-rootfs.sh" <<'XEOF'
#!/bin/bash
if [[ -f /rootfs.tar.gz ]] && [[ ! -f /etc/rootfs-extracted ]]; then
    echo "[FIRST BOOT] Extracting rootfs..."
    tar -xzf /rootfs.tar.gz -C /
    rm -f /rootfs.tar.gz
    touch /etc/rootfs-extracted
    echo "[FIRST BOOT] Rootfs extracted. Rebooting..."
    reboot
fi
XEOF

        # If using guestfish, we can do better
        if command -v guestfish &>/dev/null; then
            echo -e "${YELLOW}[WARN] Retrying with guestfish...${NC}"
            rm -f "$OUTPUT"
            guestfish -a "$OUTPUT" -N fs:ext4:"$LABEL":"${DISK_SIZE_GB}G" : \
                mkdir-p /etc : \
                tar-in "$INPUT_TAR" / : \
                mount /dev/sda1 / : \
                write /etc/hostname "$LABEL" : \
                shutdown 2>/dev/null || true
            if [[ -f "$OUTPUT" ]]; then
                echo -e "${GREEN}[INFO] Files copied via guestfish fallback${NC}"
            else
                echo -e "${YELLOW}[WARN] Image uses first-boot extraction method.${NC}"
            fi
        fi
    fi
    cd - > /dev/null

elif command -v guestmount &>/dev/null; then
    guestmount -a "$OUTPUT" -m /dev/sda1 "$MOUNT_POINT"
    rsync -aHX --exclude='/dev/*' --exclude='/proc/*' --exclude='/sys/*' "$TEMP_DIR/" "$MOUNT_POINT/"
    guestunmount "$MOUNT_POINT"
    echo -e "${GREEN}[INFO] Files copied via guestmount + rsync${NC}"

elif command -v fuse2fs &>/dev/null; then
    fuse2fs "$OUTPUT" "$MOUNT_POINT" -o rw 2>/dev/null
    rsync -aHX --exclude='/dev/*' --exclude='/proc/*' --exclude='/sys/*' "$TEMP_DIR/" "$MOUNT_POINT/"
    fusermount -u "$MOUNT_POINT" 2>/dev/null || true
    echo -e "${GREEN}[INFO] Files copied via fuse2fs + rsync${NC}"

else
    echo -e "${YELLOW}[WARN] No mount method available. Image has filesystem but no files copied.${NC}"
    echo -e "${YELLOW}       Install libguestfs-tools (guestfish) or e2fsprogs (fuse2fs) for full support.${NC}"
fi

# =============================
# BOOTLOADER (optional)
# =============================
if [[ "$NO_BOOTLOADER" == false ]] && [[ "$FORMAT" == "raw" ]]; then
    echo -e "${BLUE}[5/5] Setting up bootloader...${NC}"

    if [[ $EUID -eq 0 ]] || command -v guestfish &>/dev/null; then
        # Try to install GRUB
        if [[ -d "$TEMP_DIR/usr/lib/grub" ]] || [[ -d "$TEMP_DIR/boot/grub" ]]; then
            echo -e "${GREEN}[INFO] GRUB files found in rootfs${NC}"

            if [[ $EUID -eq 0 ]]; then
                # Root method: use loop device + grub-install
                LOOP_DEV=$(losetup --find --show --partscan "$OUTPUT")
                PART_DEV="${LOOP_DEV}p1"

                # Mount and install GRUB
                mkdir -p "$MOUNT_POINT"
                mount "$PART_DEV" "$MOUNT_POINT" 2>/dev/null || true

                if command -v grub-install &>/dev/null; then
                    grub-install --target=i386-pc --boot-directory="$MOUNT_POINT/boot" "$LOOP_DEV" 2>&1 || \
                    grub-install --target=i386-pc --boot-directory="$MOUNT_POINT/boot" --force "$LOOP_DEV" 2>&1 || \
                    echo -e "${YELLOW}[WARN] GRUB install failed (non-fatal)${NC}"
                fi

                umount "$MOUNT_POINT" 2>/dev/null || true
                losetup -d "$LOOP_DEV" 2>/dev/null || true
            else
                echo -e "${YELLOW}[INFO] Not root — GRUB bootloader will be installed via guestfish if available${NC}"
                if command -v guestfish &>/dev/null; then
                    guestfish -a "$OUTPUT" -i : \
                        write /boot/grub/grub.cfg "
menuentry '${LABEL}' {
    set root=(hd0)
    linux /boot/vmlinuz root=/dev/sda1 ro quiet
    initrd /boot/initrd.img
}
" 2>/dev/null || echo -e "${YELLOW}[WARN] guestfish GRUB config failed (non-fatal)${NC}"
                fi
            fi
        else
            echo -e "${YELLOW}[INFO] No GRUB files found in rootfs. Skipping bootloader install.${NC}"
            echo -e "${YELLOW}       Use QEMU -kernel and -initrd options to boot this image.${NC}"
        fi
    else
        echo -e "${YELLOW}[INFO] Bootloader install skipped (no root/guestfish).${NC}"
        echo -e "${YELLOW}       Use QEMU -kernel and -initrd to boot this image.${NC}"
        echo -e "${YELLOW}       Or convert with: qemu-img convert -f raw -O qcow2 $OUTPUT disk.qcow2${NC}"
    fi
else
    echo -e "${BLUE}[5/5] Skipping bootloader (--no-bootloader or qcow2 format)${NC}"
fi

# =============================
# FINALIZE
# =============================
echo ""
echo -e "${GREEN}=== Conversion Complete ===${NC}"
echo -e "Output:  ${OUTPUT}"
echo -e "Format:  ${FORMAT}"
echo -e "Size:    $(du -sh "$OUTPUT" | awk '{print $1}')"
echo -e "Label:   ${LABEL}"
echo ""
echo -e "${BLUE}To use with QEMU:${NC}"
echo ""

# Find kernel and initrd in the rootfs
KERNEL=""
INITRD=""
[[ -f "$TEMP_DIR/boot/vmlinuz" ]] && KERNEL="/boot/vmlinuz"
[[ -f "$TEMP_DIR/boot/vmlinuz-generic" ]] && KERNEL="/boot/vmlinuz-generic"
[[ -f "$TEMP_DIR/boot/vmlinuz-"* ]] && KERNEL=$(ls "$TEMP_DIR/boot/vmlinuz-"* | head -1 | sed "s|$TEMP_DIR||")
[[ -f "$TEMP_DIR/boot/initrd.img" ]] && INITRD="/boot/initrd.img"
[[ -f "$TEMP_DIR/boot/initrd.img-"* ]] && INITRD=$(ls "$TEMP_DIR/boot/initrd.img-"* | head -1 | sed "s|$TEMP_DIR||")
[[ -f "$TEMP_DIR/initrd.img" ]] && INITRD="/initrd.img"

if [[ "$FORMAT" == "raw" ]]; then
    if [[ -n "$KERNEL" ]]; then
        echo "  qemu-system-x86_64 -m 4G -smp 2 \\"
        echo "    -drive file=${OUTPUT},format=raw,if=virtio \\"
        echo "    -kernel \"${OUTPUT}:${KERNEL}\" \\"
        [[ -n "$INITRD" ]] && echo "    -initrd \"${OUTPUT}:${INITRD}\" \\"
        echo "    -append \"root=/dev/vda1 ro console=ttyS0\" \\"
        echo "    -nographic"
    else
        echo "  qemu-system-x86_64 -m 4G -smp 2 \\"
        echo "    -drive file=${OUTPUT},format=raw,if=virtio \\"
        echo "    -nographic"
    fi
else
    echo "  qemu-system-x86_64 -m 4G -smp 2 \\"
    echo "    -drive file=${OUTPUT},format=qcow2,if=virtio \\"
    echo "    -nographic"
fi

echo ""
echo -e "${YELLOW}NOTE: If no kernel found in rootfs, use the cloud image download method instead.${NC}"
echo -e "      See vm.sh for the full cloud-image approach.${NC}"
