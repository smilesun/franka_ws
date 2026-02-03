#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${WORKSPACE_DIR}/franka_ros_ws/devel/setup.bash"

roslaunch franka_example_controllers joint_velocity_example_controller.launch \
  robot_ip:=192.168.3.108
