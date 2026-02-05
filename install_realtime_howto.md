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

## General Process Overview

The `install_realtime.sh` script follows a predictable flow:

1. Prepare a workspace under `~/kernel`.
   This keeps all downloads, sources, and build outputs in a single place so the rest of the system stays clean.
2. Fetch the Linux kernel source tarball and the matching RT patch.
   The RT patch is a set of changes maintained by the PREEMPT_RT project that adds deterministic scheduling and low‑latency behavior to a standard Linux kernel. The patch version must match the kernel version.
3. Extract the kernel source and apply the RT patch.
   This produces a new source tree that includes the real‑time scheduling changes.
4. Start from your current `/boot/config-<kernel>` as the base config.
   This means the script copies your existing kernel’s config to `.config` so hardware support and system options are preserved, and you only adjust the real‑time settings.
5. Pause for `make menuconfig` to enable PREEMPT_RT and adjust options.
   You switch the preemption model to `Fully Preemptible Kernel (Real-Time)` and disable `NFS server support` if it is enabled.
6. Disable trusted/revocation keys in `.config` to avoid build issues.
   Some systems fail to build with default key settings; disabling them avoids signing‑related errors.
7. Build the kernel, install modules, then install the kernel itself.
   This compiles the kernel and its modules, then places them into `/lib/modules` and `/boot`.
8. Update initramfs and grub for the new kernel.
   The initramfs and bootloader menu are updated so the new RT kernel can be selected at boot.
9. Reboot and verify using `./install_realtime.sh --check`.
   This confirms the running kernel has the expected RT suffix and `CONFIG_PREEMPT_RT=y`.

## Does This Replace the Existing Kernel?

No. The script installs a new kernel alongside the existing one. The new RT kernel is placed in `/boot` and its modules in `/lib/modules/<version>`. Your old kernel remains available, and you can choose it from the boot menu if needed. Depending on GRUB settings, the new kernel may become the default boot entry, but it does not delete the old one.

## What `/boot`, GRUB, and the Boot Loader Are

- `/boot` is the directory that stores kernel images, initramfs files, and related boot assets needed to start Linux.
- A boot loader is the small program that runs at startup to let you choose which kernel to boot and to load it into memory.
- GRUB is the most common Linux boot loader. `update-grub` refreshes the boot menu so newly installed kernels appear as selectable options.
- An initramfs file is a small temporary root filesystem loaded into memory at boot. It contains early-boot drivers and scripts needed to mount the real root filesystem before the full system starts. These files typically live in `/boot` (for example, `initrd.img-<kernel-version>`), and `update-initramfs` rebuilds them so the new kernel has the correct early-boot environment.

## What “Preempt” Means (and How It Differs From an Interrupt)

- Preempt means the scheduler can pause a running task so a higher‑priority task can run immediately. This reduces worst‑case latency and is critical for real‑time control loops.
- An interrupt is a hardware or software signal that temporarily stops the CPU’s normal execution to handle an urgent event (like a timer tick or device input). After the interrupt handler finishes, control returns to whatever was running (or to a newly scheduled task).

In short: interrupts are event signals to the CPU; preemption is the scheduler choosing to switch tasks to honor priorities.

Plain English meaning:
“Preempt” means to stop something before it finishes because something more important needs to happen first.

Example:
If a network card raises an interrupt, the CPU stops briefly to handle it (interrupt). After that, the scheduler may decide to switch to a high‑priority control thread immediately (preemption).

Robot example:
A camera interrupt signals a new frame. The interrupt handler runs briefly, then the scheduler preempts a low‑priority logging task so the robot’s 1 kHz control loop runs on time.

## Why Not Run Only the 1 kHz Controller?

Even if your control loop runs at 1 kHz, the system still has other tasks that must execute:

- Robot I/O (Ethernet packets, sensor updates, status messages)
- OS housekeeping (interrupt handlers, memory management, filesystem writes)
- Your app/ROS (state estimation, planning, visualization, logging)
- Hardware interrupts (network card, USB, timers)

A realtime kernel ensures the 1 kHz control thread can preempt lower‑priority work and meet its timing deadlines while the rest of the system continues to function.

Example timeline (simplified):

```
Time (ms): 0    1    2    3    4
Non-RT:    |------ long disk write ------|
Control:        ^ missed deadline

RT:       |-- small slice --|-- small slice --|
Control:   ^ on time  ^ on time  ^ on time
```

## What “Jitter” Means Here

Jitter is the variation in timing between when a control loop should run and when it actually runs. In a 1 kHz loop, the target period is 1 ms. If some iterations happen late (for example at 1.3 ms or 1.6 ms instead of 1.0 ms), that delay is jitter and can cause missed deadlines or unstable control.

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
