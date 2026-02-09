sudo apt update
sudo apt install -y cpufrequtils

# set performance now (works on most systems)
for g in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  [ -f "$g" ] && echo performance | sudo tee "$g" >/dev/null
done

# verify
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor | head

