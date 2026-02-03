#!/usr/bin/env bash
set -euo pipefail

# This script captures the non-interactive parts of the RT kernel setup.
# Manual steps are left as comments because they require user input.

mkdir -p "${HOME}/kernel"
cd "${HOME}/kernel"

wget https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.15.195.tar.gz
wget https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/5.15/patch-5.15.195-rt90.patch.xz

tar -xzf linux-5.15.195.tar.gz
xz -d patch-5.15.195-rt90.patch.xz

cd linux-5.15.195/
patch -p1 <../patch-5.15.195-rt90.patch
cp /boot/config-5.15.0-139-generic .config

# Manual: make menuconfig and disable NFS server support.
# Manual: scripts/config --disable SYSTEM_TRUSTED_KEYS
# Manual: scripts/config --disable SYSTEM_REVOCATION_KEYS

sudo apt install -y dwarves
sudo apt install -y zstd

# Manual: sudo make (can take hours), then sudo make install
# Manual: reboot
