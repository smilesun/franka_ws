# install_realtime.sh Usage

This guide explains how to use `install_realtime.sh`.

## 1) Run the guided install

From the workspace root:

```bash
cd /home/sunxd/robustCapture/franka_ws
./install_realtime.sh
```

What it does:

- Downloads the kernel source and RT patch
- Applies the RT patch
- Copies your current kernel config as a starting point
- Pauses for manual configuration steps (menuconfig and config tweaks)
- Builds and installs the kernel
- Updates initramfs and grub

Follow the on-screen prompts for each manual step.

## 2) Reboot and verify

After reboot, run the built-in check:

```bash
./install_realtime.sh --check
```

Expected results:

- `uname -r` includes the RT suffix (e.g., `5.15.195-rt90`)
- `/boot/config-<kernel>` shows `CONFIG_PREEMPT_RT=y`
- `/sys/kernel/realtime` prints `1`
- The script prints `RT kernel check: PASS`

If any check fails, re-open the script’s output to see which part did not match.
