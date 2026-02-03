#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "${WORKSPACE_DIR}/franka_ros_ws/build/examples"
./communication_test 192.168.3.108
