#!/usr/bin/env bash
set -euo pipefail

echo "GRUB OOM Risk Check (Ubuntu 20)"
echo

echo "Boot mode:"
if [[ -d /sys/firmware/efi ]]; then
  echo "  UEFI"
else
  echo "  BIOS/Legacy"
fi
echo

echo "Initramfs sizes:"
ls -lh /boot/initrd.img-* 2>/dev/null || echo "  No initrd.img files found."
echo

echo "Current kernel initramfs size:"
if [[ -f /boot/initrd.img-$(uname -r) ]]; then
  ls -lh /boot/initrd.img-$(uname -r)
else
  echo "  /boot/initrd.img-$(uname -r) not found."
fi
echo

echo "initramfs MODULES setting:"
if [[ -f /etc/initramfs-tools/initramfs.conf ]]; then
  grep '^MODULES=' /etc/initramfs-tools/initramfs.conf || echo "  MODULES not set."
else
  echo "  /etc/initramfs-tools/initramfs.conf not found."
fi
echo

echo "ESP usage (/boot/efi):"
if mountpoint -q /boot/efi; then
  df -h /boot/efi
else
  echo "  /boot/efi not mounted."
fi
echo

echo "GRUB config size:"
if [[ -f /boot/grub/grub.cfg ]]; then
  ls -lh /boot/grub/grub.cfg
else
  echo "  /boot/grub/grub.cfg not found."
fi
echo

echo "Notes:"
echo "- Very large initramfs (hundreds of MB) increases GRUB OOM risk."
echo "- MODULES=dep typically reduces initramfs size."
echo "- ESP space affects updates, but is not the same as GRUB OOM."

echo
echo "Risk rating (heuristic):"
current_initrd="/boot/initrd.img-$(uname -r)"
risk_score=0

if [[ -f "$current_initrd" ]]; then
  initrd_bytes=$(stat -c '%s' "$current_initrd" 2>/dev/null || echo 0)
  if [[ "$initrd_bytes" -gt 157286400 ]]; then
    risk_score=$((risk_score + 2))
  elif [[ "$initrd_bytes" -gt 52428800 ]]; then
    risk_score=$((risk_score + 1))
  fi
fi

modules_setting=$(grep '^MODULES=' /etc/initramfs-tools/initramfs.conf 2>/dev/null || true)
if [[ "$modules_setting" == "MODULES=most" ]]; then
  risk_score=$((risk_score + 1))
fi

esp_used_pct=0
if mountpoint -q /boot/efi; then
  esp_used_pct=$(df -P /boot/efi | awk 'NR==2 {gsub("%","",$5); print $5}')
  if [[ "$esp_used_pct" -ge 80 ]]; then
    risk_score=$((risk_score + 1))
  fi
fi

if [[ "$risk_score" -ge 3 ]]; then
  echo "  High"
elif [[ "$risk_score" -ge 2 ]]; then
  echo "  Medium"
else
  echo "  Low"
fi

echo "Heuristic details:"
echo "- Initramfs size: <50MB (low), 50-150MB (medium), >150MB (high)."
echo "- MODULES=most adds risk."
echo "- ESP usage >=80% adds risk (update failures, not GRUB RAM)."
