# Realtime Kernel Install Dependencies

## libncurses-dev
`make menuconfig` uses the ncurses library to render its text-based configuration UI. The `libncurses-dev` package provides the development headers and linkable libraries needed to build that UI. Without it, `menuconfig` fails to compile.

## pkg-config
`pkg-config` helps build tools discover the correct include paths and linker flags for libraries like ncurses. It is especially important when the library is installed in a non-default location. Installing it avoids “unable to find ncurses” errors in some environments.
