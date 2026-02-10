#!/usr/bin/env bash
set -euo pipefail

bad=0
for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  gov="$(cat "$g")"
  if [[ "$gov" != "performance" ]]; then
    echo "NOT performance: $g = $gov"
    bad=1
  fi
done

if [[ "$bad" -eq 0 ]]; then
  echo "All CPUs in performance mode."
  exit 0
else
  exit 2
fi
