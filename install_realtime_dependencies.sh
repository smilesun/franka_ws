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
#
# flex:
# - Lexical analyzer generator used by kernel menuconfig build.
# - Provides the lexer for Kconfig (scripts/kconfig/lexer.lex.c).
#
# bison:
# - Parser generator used by kernel menuconfig build.
# - Provides the Kconfig parser (scripts/kconfig/parser.tab.[ch]).
#
# libelf-dev:
# - Provides libelf.h and gelf.h required by objtool and BPF tooling.

sudo apt update
sudo apt-get install -y libncurses-dev pkg-config flex bison libelf-dev
