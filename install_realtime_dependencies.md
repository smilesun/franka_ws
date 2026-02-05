# Realtime Kernel Install Dependencies

## Why Franka Needs a Realtime Kernel
Franka control loops run at 1 kHz and depend on consistent scheduling latency. A realtime (RT) kernel reduces jitter and ensures control threads run within predictable timing bounds. Without RT behavior, the control loop can miss deadlines and trigger safety stops.

## What a Realtime Kernel Is
A realtime kernel is a Linux kernel configured for deterministic scheduling. It prioritizes time‑critical tasks and minimizes worst‑case latency, trading some throughput for predictability.

## libncurses-dev
`make menuconfig` uses the ncurses library to render its text-based configuration UI. The `libncurses-dev` package provides the development headers and linkable libraries needed to build that UI. Without it, `menuconfig` fails to compile.

## pkg-config
`pkg-config` helps build tools discover the correct include paths and linker flags for libraries like ncurses. It is especially important when the library is installed in a non-default location. Installing it avoids “unable to find ncurses” errors in some environments.
