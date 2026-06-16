#!/usr/bin/env bash
set -euo pipefail

if ! command -v cpufreq-info >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y cpufrequtils
fi

# set performance now (works on most systems)
for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  [ -f "$g" ] && echo performance | sudo tee "$g" >/dev/null
done

# verify
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor | head
