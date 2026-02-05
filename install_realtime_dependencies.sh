#!/usr/bin/env bash
set -euo pipefail

# Realtime Kernel Install Dependencies
#
# libncurses-dev:
# - make menuconfig uses ncurses for its text-based UI.
# - This package provides the headers and libraries needed to build it.
#
# pkg-config:
# - Helps build tools locate the correct include/link flags for ncurses.
# - Avoids "unable to find ncurses" errors on some systems.

sudo apt update
sudo apt-get install -y libncurses-dev pkg-config
