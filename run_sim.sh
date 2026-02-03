#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${WORKSPACE_DIR}/franka_ros_ws/devel/setup.bash"

roslaunch franka_gazebo panda.launch \
  x:=-0.5 \
  world:=$(rospack find franka_gazebo)/world/stone.sdf \
  controller:=cartesian_impedance_example_controller \
  rviz:=true
