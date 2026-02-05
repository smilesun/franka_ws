#!/usr/bin/env bash
set -euo pipefail

cat <<'PATTERN'
Expected output patterns to compare:
- uname -r: should include "-rt" (e.g., 5.15.195-rt90)
- /boot/config-$(uname -r): CONFIG_PREEMPT_RT=y
- /sys/kernel/realtime: 1

--- Actual outputs ---
PATTERN

echo "uname -r:"
uname -r

echo
echo "/boot/config-$(uname -r) (filtered):"
grep -E "CONFIG_PREEMPT_RT|CONFIG_PREEMPT" "/boot/config-$(uname -r)" || true

echo
echo "/sys/kernel/realtime:"
if [[ -r /sys/kernel/realtime ]]; then
  cat /sys/kernel/realtime
else
  echo "(not readable or not present)"
fi
