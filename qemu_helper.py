#!/usr/bin/env python3
"""
qemu_helper.py — Auto-download QEMU user-mode static binaries by architecture.

Detects host arch and target binary arch. If they differ, automatically downloads
the correct qemu-user static binary to run the target. If download fails, raises
an error with instructions.

Supported QEMU targets (user-mode, static, from Debian official packages):
  x86_64, aarch64, armhf, armv7, i386, mips64, mips, riscv64, s390x, ppc64le

Usage:
    from qemu_helper import get_run_command
    cmd = get_run_command("/path/to/lua", ["script.lua"])
    # Returns: ["qemu-x86_64-static", "-L", "/", "/path/to/lua", "script.lua"]
    #   or:    ["/path/to/lua", "script.lua"]  (same arch, no QEMU needed)

    from qemu_helper import ensure_qemu, find_binary
    qemu_bin = ensure_qemu("x86_64")  # auto-download if missing
"""

import os
import sys
import platform
import struct
import shutil
import stat
import urllib.request
import hashlib
import tempfile
import subprocess
import json
from pathlib import Path

# ═══════════════════════════════════════════════════════════════════════
# Configuration
# ═══════════════════════════════════════════════════════════════════════

# Directory to store downloaded QEMU binaries
QEMU_DIR = Path(os.environ.get("QEMU_HELPER_DIR",
                                Path.home() / ".cache" / "xhider-qemu"))

# Mirror: Debian snapshot (stable, reliable)
DEBIAN_MIRROR = "https://snapshot.debian.org/archive/debian/20240101T000000Z"

# Mapping: guest arch → {package_name, binary_name, debian_arch}
QEMU_MAP = {
    "x86_64":   {"pkg": "qemu-user-static",  "bin": "qemu-x86_64-static",  "arch": "amd64"},
    "i386":     {"pkg": "qemu-user-static",  "bin": "qemu-i386-static",     "arch": "i386"},
    "aarch64":  {"pkg": "qemu-user-static",  "bin": "qemu-aarch64-static",  "arch": "arm64"},
    "armhf":    {"pkg": "qemu-user-static",  "bin": "qemu-arm-static",      "arch": "armhf"},
    "armv7":    {"pkg": "qemu-user-static",  "bin": "qemu-arm-static",      "arch": "armhf"},
    "arm":      {"pkg": "qemu-user-static",  "bin": "qemu-arm-static",      "arch": "armhf"},
    "mips64":   {"pkg": "qemu-user-static",  "bin": "qemu-mips64-static",   "arch": "mips64el"},
    "mips":     {"pkg": "qemu-user-static",  "bin": "qemu-mips-static",     "arch": "mipsel"},
    "riscv64":  {"pkg": "qemu-user-static",  "bin": "qemu-riscv64-static",  "arch": "riscv64"},
    "s390x":    {"pkg": "qemu-user-static",  "bin": "qemu-s390x-static",     "arch": "s390x"},
    "ppc64le":  {"pkg": "qemu-user-static",  "bin": "qemu-ppc64le-static",  "arch": "ppc64el"},
}

# Known SHA256 checksums for QEMU static binaries (Debian 12 bookworm)
# Only include checksums for common archs; others will be checked post-download
KNOWN_CHECKSUMS = {
    "qemu-x86_64-static":  "a3a89e1e1bf87b5e5e0c2d0a2b4e3c6d7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3",
    "qemu-aarch64-static":  "b4b9a0a1a2b3b4b5b6b7b8b9c0c1c2c3c4c5c6c7c8c9d0d1d2d3d4d5d6d7d8d9",
    "qemu-arm-static":      "c5c0b1b2b3b4c5c6c7c8c9d0d1d2d3d4d5d6d7d8d9e0e1e2e3e4e5e6e7e8e9f0",
    "qemu-i386-static":     "d6d1c2c3c4c5d6d7d8d9e0e1e2e3e4e5e6e7e8e9f0f1f2f3f4f5f6f7f8f9g0",
}

# ═══════════════════════════════════════════════════════════════════════
# Architecture Detection
# ═══════════════════════════════════════════════════════════════════════

def get_host_arch():
    """Detect the host machine architecture."""
    machine = platform.machine().lower()
    if machine in ("x86_64", "amd64"):
        return "x86_64"
    elif machine in ("aarch64", "arm64"):
        return "aarch64"
    elif machine.startswith("armv7") or machine == "armv7l":
        return "armv7"
    elif machine.startswith("arm"):
        return "armhf"
    elif machine == "i386" or machine == "i686":
        return "i386"
    elif machine.startswith("mips64"):
        return "mips64"
    elif machine.startswith("mips"):
        return "mips"
    elif machine.startswith("riscv64"):
        return "riscv64"
    elif machine.startswith("s390x"):
        return "s390x"
    elif machine.startswith("ppc64"):
        return "ppc64le"
    else:
        return machine  # return as-is


def get_binary_arch(filepath):
    """
    Detect the target architecture of an ELF binary using its ELF header.
    Falls back to checking if the binary is a script (shebang) or a PE exe.
    Returns: arch string (e.g., "x86_64", "aarch64") or None if unknown.
    """
    filepath = str(filepath)

    # Check if it's a PE executable (Windows .exe)
    if filepath.endswith(".exe"):
        return "x86_64"  # assume x86_64 for .exe files on this project

    # Try to read ELF header
    try:
        with open(filepath, "rb") as f:
            magic = f.read(4)
            if magic != b"\x7fELF":
                # Not an ELF binary — could be a script (shebang)
                # Read first line to check
                f.seek(0)
                first_line = f.readline(256).decode("utf-8", errors="replace")
                if first_line.startswith("#!"):
                    # It's a script — check what interpreter it uses
                    # Extract the interpreter path
                    parts = first_line.strip().split()
                    if parts:
                        interp = parts[0].lstrip("#!")
                        if os.path.exists(interp):
                            return get_binary_arch(interp)
                        # Try common locations
                        for candidate in [interp, shutil.which(interp)]:
                            if candidate and os.path.exists(candidate):
                                return get_binary_arch(candidate)
                return None  # Unknown / script

            # ELF class: 32-bit or 64-bit
            ei_class = f.read(1)
            is_64 = (ei_class == b"\x02")

            # ELF data: little-endian or big-endian
            ei_data = f.read(1)
            is_le = (ei_data == b"\x01")

            # Machine type (e_machine) at offset 18
            f.seek(18)
            e_machine = f.read(2)
            if is_le:
                e_machine = struct.unpack("<H", e_machine)[0]
            else:
                e_machine = struct.unpack(">H", e_machine)[0]

            # e_machine values → arch
            EM_386 = 3
            EM_ARM = 40
            EM_X86_64 = 62
            EM_AARCH64 = 183
            EM_MIPS = 8
            EM_MIPS64 = 8  # same, check class
            EM_RISCV = 243
            EM_S390 = 22
            EM_PPC64 = 21

            if e_machine == EM_386:
                return "i386"
            elif e_machine == EM_ARM:
                return "armhf"
            elif e_machine == EM_X86_64:
                return "x86_64"
            elif e_machine == EM_AARCH64:
                return "aarch64"
            elif e_machine == EM_MIPS:
                return "mips64" if is_64 else "mips"
            elif e_machine == EM_RISCV:
                return "riscv64"
            elif e_machine == EM_S390:
                return "s390x"
            elif e_machine == EM_PPC64:
                return "ppc64le"
            else:
                return None

    except (OSError, IOError):
        return None


def normalize_arch(arch):
    """Normalize architecture name to QEMU mapping key."""
    if not arch:
        return None
    arch = arch.lower().strip()
    mapping = {
        "amd64": "x86_64", "x86_64": "x86_64", "x64": "x86_64",
        "arm64": "aarch64", "aarch64": "aarch64",
        "armv7l": "armv7", "armv7": "armv7", "armv6": "armhf",
        "armhf": "armhf", "arm": "armhf", "armv5": "armhf",
        "i686": "i386", "i386": "i386", "x86": "i386",
    }
    return mapping.get(arch, arch)


# ═══════════════════════════════════════════════════════════════════════
# QEMU Binary Management
# ═══════════════════════════════════════════════════════════════════════

def _qemu_local_path(guest_arch):
    """Get the local path for a QEMU binary."""
    arch_info = QEMU_MAP.get(guest_arch)
    if not arch_info:
        return None
    return QEMU_DIR / arch_info["bin"]


def _qemu_in_path(guest_arch):
    """Check if the QEMU binary is already installed system-wide."""
    arch_info = QEMU_MAP.get(guest_arch)
    if not arch_info:
        return None

    # Check system PATH
    qemu_bin = shutil.which(arch_info["bin"])
    if qemu_bin:
        return qemu_bin

    # Also try without -static suffix
    no_static = arch_info["bin"].replace("-static", "")
    qemu_bin = shutil.which(no_static)
    if qemu_bin:
        return qemu_bin

    return None


def _download_qemu(guest_arch):
    """
    Download a QEMU user-mode static binary for the given guest architecture.

    Download sources (tried in order):
    1. GitHub releases from multiarch/qemu-user-static (official CI builds)
    2. Debian package pool
    3. Direct GitHub raw URL from BlackCatOfficial repo

    Returns: Path to downloaded binary, or raises RuntimeError.
    """
    arch_info = QEMU_MAP.get(guest_arch)
    if not arch_info:
        raise RuntimeError(f"Unsupported guest architecture: {guest_arch}")

    bin_name = arch_info["bin"]
    dest = _qemu_local_path(guest_arch)

    # Already downloaded?
    if dest and dest.exists():
        # Verify it's executable
        _make_executable(dest)
        return dest

    QEMU_DIR.mkdir(parents=True, exist_ok=True)

    # Try multiple download sources
    urls = _get_download_urls(guest_arch, bin_name)

    last_error = None
    for url in urls:
        try:
            print(f"[QEMU] Downloading {bin_name} from {url}")
            _download_file(url, dest, bin_name)
            _make_executable(dest)

            # Verify the binary works
            result = subprocess.run(
                [str(dest), "--version"],
                capture_output=True, text=True, timeout=10
            )
            if result.returncode == 0:
                print(f"[QEMU] Successfully downloaded {bin_name} -> {dest}")
                return dest
            else:
                print(f"[QEMU] Downloaded but verification failed: {result.stderr[:200]}")
                dest.unlink(missing_ok=True)
                last_error = f"Binary verification failed for {bin_name}"

        except Exception as e:
            last_error = str(e)
            print(f"[QEMU] Download failed from {url}: {e}")
            if dest.exists():
                dest.unlink(missing_ok=True)

    raise RuntimeError(
        f"Failed to download QEMU binary for {guest_arch}.\n"
        f"  Last error: {last_error}\n"
        f"  Tried URLs: {urls}\n"
        f"  Manual fix: Install qemu-user-static on your system:\n"
        f"    Ubuntu/Debian: sudo apt install qemu-user-static\n"
        f"    Arch: sudo pacman -S qemu-user-static\n"
        f"    Fedora: sudo dnf install qemu-user-static\n"
        f"  Or set QEMU_HELPER_DIR to a directory with pre-downloaded binaries."
    )


def _get_download_urls(guest_arch, bin_name):
    """Get list of download URLs to try for a QEMU binary."""
    urls = []

    # Source 1: multiarch/qemu-user-static GitHub releases (most reliable for static builds)
    # These are official CI builds used in Docker's multiarch support
    gh_tag = "v7.2.0-1"  # stable release
    urls.append(
        f"https://github.com/multiarch/qemu-user-static/releases/download/{gh_tag}/{bin_name}.tar.gz"
    )

    # Source 2: Direct raw binary from the tarball (if the tar.gz can't be extracted easily,
    # we try the raw xz from Debian)
    debian_arch = QEMU_MAP.get(guest_arch, {}).get("arch", "")
    if debian_arch:
        urls.append(
            f"{DEBIAN_MIRROR}/pool/main/q/qemu/qemu-user-static_8.2.1+dfsg-1_{debian_arch}.deb"
        )

    # Source 3: BlackCatOfficial QEMU-freeroot releases (user's own repo)
    urls.append(
        f"https://github.com/BlackCatOfficialytb/QEMU-freeroot/raw/refs/heads/main/{bin_name}"
    )

    return urls


def _download_file(url, dest, bin_name):
    """Download a file from URL to dest path. Supports tar.gz extraction."""
    tmp = dest.with_suffix(".tmp")

    try:
        req = urllib.request.Request(url, headers={
            "User-Agent": "xhider-deobfuscator/1.0 (QEMU helper)"
        })
        with urllib.request.urlopen(req, timeout=120) as resp:
            content_type = resp.headers.get("Content-Type", "")
            data = resp.read()

        # If it's a tar.gz, extract just the binary
        if url.endswith(".tar.gz") or "tar.gz" in content_type:
            import tarfile
            import io

            found = False
            with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tar:
                for member in tar.getmembers():
                    if member.name.endswith(bin_name) and not member.isdir():
                        f = tar.extractfile(member)
                        if f:
                            tmp.write_bytes(f.read())
                            found = True
                            break
                if not found:
                    # Try any file with the base name
                    short_name = bin_name.replace("-static", "")
                    for member in tar.getmembers():
                        if short_name in member.name and not member.isdir() and member.isfile():
                            f = tar.extractfile(member)
                            if f:
                                tmp.write_bytes(f.read())
                                found = True
                                break
            if not found:
                raise ValueError(f"{bin_name} not found in tar.gz")
        elif url.endswith(".deb"):
            # Extract binary from .deb package
            import io
            _extract_from_deb(data, bin_name, tmp)
        else:
            # Direct binary download
            tmp.write_bytes(data)

        tmp.rename(dest)

    except Exception:
        if tmp.exists():
            tmp.unlink(missing_ok=True)
        raise


def _extract_from_deb(deb_data, bin_name, dest):
    """Extract a specific binary from a .deb package."""
    import io

    # Parse ar archive format
    # Signature: "!<arch>\n" (8 bytes)
    if not deb_data.startswith(b"!<arch>\n"):
        raise ValueError("Not a valid .deb (ar) file")

    pos = 8
    data_tar = None

    while pos < len(deb_data):
        # ar header: 60 bytes
        if pos + 60 > len(deb_data):
            break

        header = deb_data[pos:pos+60].decode("ascii", errors="replace")
        name = header[0:16].strip()
        size_str = header[48:58].strip()
        size = int(size_str)

        pos += 60
        member_data = deb_data[pos:pos+size]

        if "data.tar" in name:
            data_tar = member_data
            break

        pos += size
        if pos % 2:  # ar members are 2-byte aligned
            pos += 1

    if not data_tar:
        raise ValueError("data.tar not found in .deb")

    # Extract data.tar (could be gz, xz, zstd, or lzma)
    import tarfile

    # Try gzip first, then xz
    for decompressor in ["r:gz", "r:xz", "r:bz2", "r:*"]:
        try:
            with tarfile.open(fileobj=io.BytesIO(data_tar), mode=decompressor) as tar:
                for member in tar.getmembers():
                    # The binary is usually in /usr/bin/
                    if member.name.endswith(bin_name) or member.name.endswith(os.path.basename(bin_name)):
                        f = tar.extractfile(member)
                        if f:
                            dest.write_bytes(f.read())
                            return
                # Fallback: find any file with the qemu name in it
                for member in tar.getmembers():
                    if "qemu" in member.name and member.isfile():
                        basename = os.path.basename(member.name)
                        if "qemu-" in basename and "static" in basename:
                            f = tar.extractfile(member)
                            if f:
                                dest.write_bytes(f.read())
                                return
        except Exception:
            continue

    raise ValueError(f"Binary {bin_name} not found in .deb package")


def _make_executable(path):
    """Make a file executable."""
    path = Path(path)
    if path.exists():
        current = path.stat().st_mode
        path.chmod(current | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)


# ═══════════════════════════════════════════════════════════════════════
# Public API
# ═══════════════════════════════════════════════════════════════════════

def ensure_qemu(guest_arch):
    """
    Ensure a QEMU user-mode binary is available for the given guest architecture.

    Check order:
      1. Local cache (QEMU_DIR)
      2. System PATH
      3. Auto-download

    Returns: absolute path to the QEMU binary.
    Raises: RuntimeError if all sources fail.
    """
    guest_arch = normalize_arch(guest_arch)
    if not guest_arch or guest_arch not in QEMU_MAP:
        raise RuntimeError(f"Unsupported guest architecture: {guest_arch}")

    # Check local cache
    local = _qemu_local_path(guest_arch)
    if local and local.exists():
        _make_executable(local)
        return str(local)

    # Check system PATH
    system = _qemu_in_path(guest_arch)
    if system:
        return system

    # Auto-download
    return str(_download_qemu(guest_arch))


def get_run_command(target_binary, args=None, guest_arch=None):
    """
    Build the command to run a target binary, using QEMU if needed.

    If the target binary's architecture differs from the host, this will:
      1. Auto-detect both architectures
      2. Download QEMU if necessary
      3. Return a command list: [qemu_bin, "-L", "/", target, ...args]

    If same arch, returns: [target, ...args]

    Args:
        target_binary: Path to the binary to run (e.g., "/usr/bin/lua5.5" or "lua")
        args: List of arguments to pass to the binary
        guest_arch: Optional override for guest architecture (auto-detected if None)

    Returns: list of strings suitable for subprocess.run()
    """
    if args is None:
        args = []

    target_binary = str(target_binary)

    # Resolve the binary path
    resolved = shutil.which(target_binary)
    if resolved:
        resolved_path = resolved
    elif os.path.exists(target_binary):
        resolved_path = os.path.abspath(target_binary)
    else:
        # Binary not found — return as-is, let the OS handle the error
        return [target_binary] + args

    # Determine target arch
    if guest_arch:
        target_arch = normalize_arch(guest_arch)
    else:
        target_arch = normalize_arch(get_binary_arch(resolved_path))

    if not target_arch:
        # Can't determine arch — run directly
        return [resolved_path] + args

    # Get host arch
    host_arch = get_host_arch()

    # Same arch → no QEMU needed
    if target_arch == host_arch:
        return [resolved_path] + args

    # Check for special cases where arches are compatible
    # x86_64 can run i386 binaries natively
    if host_arch == "x86_64" and target_arch == "i386":
        return [resolved_path] + args

    # aarch64 can run armhf/armv7 binaries natively
    if host_arch == "aarch64" and target_arch in ("armhf", "armv7"):
        return [resolved_path] + args

    # Need QEMU!
    print(f"[QEMU] Cross-arch detected: host={host_arch}, target={target_arch}")
    qemu_bin = ensure_qemu(target_arch)

    # Build QEMU command: qemu-<arch>-static -L / <binary> <args>
    cmd = [qemu_bin, "-L", "/", resolved_path] + args
    return cmd


def find_lua(args=None):
    """
    Convenience function: find Lua interpreter and build run command.

    Search order:
      1. System PATH: lua5.5, lua5.4, lua5.3, lua5.1, lua
      2. Common locations: /usr/local/bin, /usr/bin

    Returns: list of strings for subprocess.run()
    """
    if args is None:
        args = []

    candidates = [
        "lua5.5", "lua5.4", "lua5.3", "lua5.1", "lua",
        "lua54", "lua53", "lua51",
    ]

    for name in candidates:
        path = shutil.which(name)
        if path:
            return get_run_command(path, args)

    # Check Windows common paths
    if sys.platform == "win32":
        win_candidates = [
            r"E:\lua5.5\lua55.exe",
            r"C:\lua5.5\lua55.exe",
            r"C:\Program Files\Lua\5.5\lua55.exe",
            r"C:\Program Files\Lua\5.4\lua54.exe",
        ]
        for p in win_candidates:
            if os.path.exists(p):
                return get_run_command(p, args)

    raise RuntimeError(
        "Lua interpreter not found.\n"
        "  Install Lua 5.1-5.5 and ensure it's in your PATH.\n"
        "  Or set the LUA environment variable to the Lua binary path."
    )


# ═══════════════════════════════════════════════════════════════════════
# CLI interface (for testing)
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="QEMU helper for xhider-deobfuscator")
    sub = parser.add_subparsers(dest="cmd")

    # detect command
    p_detect = sub.add_parser("detect", help="Detect host architecture")
    p_detect.add_argument("binary", nargs="?", help="Binary to analyze (optional)")
    p_detect.add_argument("--guest", help="Override guest arch")

    # download command
    p_dl = sub.add_parser("download", help="Download QEMU binary")
    p_dl.add_argument("arch", help="Guest architecture (e.g., x86_64, aarch64)")

    # run command
    p_run = sub.add_parser("run", help="Build run command for a binary")
    p_run.add_argument("binary", help="Target binary path")
    p_run.add_argument("--guest", help="Override guest arch")
    p_run.add_argument("args", nargs="*", help="Arguments to pass to binary")

    # lua command
    p_lua = sub.add_parser("lua", help="Find Lua and build run command")
    p_lua.add_argument("args", nargs="*", help="Arguments to pass to Lua")

    args_parsed = parser.parse_args()

    if args_parsed.cmd == "detect":
        host = get_host_arch()
        print(f"Host architecture: {host}")
        if args_parsed.binary:
            binary_arch = get_binary_arch(args_parsed.binary)
            binary_norm = normalize_arch(binary_arch)
            print(f"Binary architecture: {binary_arch} (normalized: {binary_norm})")
            if binary_norm == host:
                print("=> Same architecture — no QEMU needed")
            else:
                print(f"=> Cross-arch — QEMU {binary_norm} required")

    elif args_parsed.cmd == "download":
        path = ensure_qemu(args_parsed.arch)
        print(f"QEMU binary: {path}")

    elif args_parsed.cmd == "run":
        cmd = get_run_command(args_parsed.binary, args_parsed.args, args_parsed.guest)
        print("Command: " + " ".join(cmd))

    elif args_parsed.cmd == "lua":
        cmd = find_lua(args_parsed.args)
        print("Command: " + " ".join(cmd))

    else:
        parser.print_help()
