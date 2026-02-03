#!/usr/bin/env bash
set -euo pipefail

export PS4='+ $(date "+%H:%M:%S.%3N")  '
set -x
rostopic pub -1 -l /joint_position_example_controller/gripper_release std_msgs/Bool "data: true"
echo "Hello world"
echo " " > /tmp/run_barrier
