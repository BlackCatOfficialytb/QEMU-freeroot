# QEMU-freeroot
## QEMU-freeroot is a script to create a isolated ubuntu system (Same as freeroot)

## How to use
1. Install QEMU

Arch: `pacman -S qemu`

Debian/Ubuntu: `apt-get install qemu-system`

Fedora: `dnf install @virtualization`

Gentoo: `emerge --ask app-emulation/qemu`

RHEL/CentOS: `yum install qemu-kvm`

SUSE: `zypper install qemu`

Google Firebase Studio: copy the `dev.nix` file and paste it

2. Clone the repo

`git clone https://github.com/BlackCatOfficialytb/QEMU-freeroot.git`

3. Run vm.sh

```bash
cd QEMU-freeroot
sh vm.sh
# or
bash vm.sh
``` 

## Optional tools

We have tar.gz to qcow2 (still functional but not implemented in vm.sh yet): targztoqcow2.sh

Soon add pre-built QEMU for Linux for full freeroot-like

## Videos: https://www.youtube.com/watch?v=PPJWx2UnQQE
Copyright: 
Codes: GPL-3.0 with credits
Video: CC BY-SA 4.0
