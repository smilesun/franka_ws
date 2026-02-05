#!/usr/bin/env bash
set -euo pipefail

KERNEL_VERSION="${1:-5.15.195-rt90}"
CONF_FILE="/etc/initramfs-tools/initramfs.conf"
BACKUP_FILE="${CONF_FILE}.bak.$(date +%Y%m%d%H%M%S)"

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (use sudo)." >&2
  exit 1
fi

if [[ ! -f "$CONF_FILE" ]]; then
  echo "Missing $CONF_FILE. Are you running from the installed system?" >&2
  exit 1
fi

echo "Remounting / as read-write (if needed)..."
mount -o remount,rw / || true

echo "Backing up $CONF_FILE to $BACKUP_FILE"
cp "$CONF_FILE" "$BACKUP_FILE"

if grep -q '^MODULES=most' "$CONF_FILE"; then
  sed -i 's/^MODULES=most/MODULES=dep/' "$CONF_FILE"
  echo "Updated MODULES=most -> MODULES=dep"
else
  echo "No MODULES=most line found. Leaving $CONF_FILE unchanged."
fi

echo "Updating initramfs for kernel $KERNEL_VERSION..."
update-initramfs -c -k "$KERNEL_VERSION"

echo "Updating GRUB..."
update-grub

initrd_path="/boot/initrd.img-${KERNEL_VERSION}"
if [[ -f "$initrd_path" ]]; then
  initrd_bytes=$(stat -c '%s' "$initrd_path" 2>/dev/null || echo 0)
  if [[ "$initrd_bytes" -gt 157286400 ]]; then
    echo "Warning: initramfs is larger than 150MB. GRUB OOM risk may remain." >&2
  elif [[ "$initrd_bytes" -gt 52428800 ]]; then
    echo "Note: initramfs is larger than 50MB. Risk is usually still OK, but keep an eye on it."
  else
    echo "Initramfs size looks reasonable."
  fi
else
  echo "Note: $initrd_path not found to size-check."
fi

echo "Done. You can reboot now."
