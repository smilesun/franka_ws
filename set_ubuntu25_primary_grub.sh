#!/usr/bin/env bash
set -euo pipefail

BOOT_ID="${1:-ubuntu25}"
EFI_DIR="/boot/efi"

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (use sudo)." >&2
  exit 1
fi

if [[ ! -d /sys/firmware/efi ]]; then
  echo "UEFI not detected. This script is intended for UEFI systems." >&2
  exit 1
fi

if ! mountpoint -q "$EFI_DIR"; then
  echo "$EFI_DIR is not mounted. Mount the EFI System Partition and retry." >&2
  exit 1
fi

echo "Installing GRUB to EFI as '$BOOT_ID'..."
grub-install --target=x86_64-efi --efi-directory="$EFI_DIR" --bootloader-id="$BOOT_ID"

echo "Updating GRUB menu..."
update-grub

echo "Current EFI boot entries:"
efibootmgr -v

bootnum=$(efibootmgr -v | awk -v id="$BOOT_ID" '
  $1 ~ /^Boot[0-9A-Fa-f]{4}\*/ && $0 ~ id {
    match($1, /^Boot([0-9A-Fa-f]{4})\*/, m);
    if (m[1] != "") { print m[1]; exit }
  }')

if [[ -z "${bootnum:-}" ]]; then
  echo "Could not find EFI entry for $BOOT_ID. Set boot order manually with efibootmgr." >&2
  exit 1
fi

current_order=$(efibootmgr | awk -F': ' '/BootOrder/ {print $2}')
if [[ -z "${current_order:-}" ]]; then
  echo "Could not read current BootOrder. Set boot order manually with efibootmgr." >&2
  exit 1
fi

new_order="$bootnum"
IFS=',' read -r -a order_list <<< "$current_order"
for entry in "${order_list[@]}"; do
  if [[ "$entry" != "$bootnum" ]]; then
    new_order="${new_order},${entry}"
  fi
done

echo "Setting BootOrder to: $new_order"
efibootmgr -o "$new_order"

echo "Done. $BOOT_ID is now first in BootOrder."
