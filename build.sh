#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Install libfranka dependencies (Ubuntu 20.04)
###############################################################################
sudo apt-get update
sudo apt-get install -y build-essential cmake git libpoco-dev libeigen3-dev libfmt-dev

###############################################################################
# Install libfranka package
###############################################################################
cd "${HOME}/Downloads"
wget https://github.com/frankarobotics/libfranka/releases/download/0.18.2/libfranka_0.18.2_focal_amd64.deb
sudo dpkg -i libfranka_0.18.2_focal_amd64.deb

###############################################################################
# Build franka_ros (catkin workspace)
###############################################################################
mkdir -p "${HOME}/workspaces/franka_ws/franka_ros_ws/src"
cd "${HOME}/workspaces/franka_ws/franka_ros_ws/src"
git clone git@github.com:prominentjohnson/franka_ros.git

sudo apt install -y ros-noetic-pinocchio
sudo apt install -y ros-noetic-combined-robot-hw
sudo apt install -y ros-noetic-boost-sml

cd "${HOME}/workspaces/franka_ws/franka_ros_ws"
catkin_make

###############################################################################
# ROS simulation launch commands (run in separate terminals)
###############################################################################
# source "${HOME}/workspaces/franka_ws/franka_ros_ws/devel/setup.bash"
# roslaunch franka_gazebo panda.launch x:=-0.5 world:=$(rospack find franka_gazebo)/world/stone.sdf controller:=cartesian_impedance_example_controller rviz:=true
# roslaunch franka_gazebo panda.launch rviz:=true controller:=cartesian_impedance_example_controller
# roslaunch franka_gazebo panda.launch controller:=joint_velocity_example_controller rviz:=true
# roslaunch franka_example_controllers joint_impedance_example_controller.launch load_gripper:=true robot:=panda
# roslaunch franka_example_controllers joint_velocity_example_controller.launch robot_ip:=192.168.3.108

###############################################################################
# Communication test
###############################################################################
# cd build/examples
# ./communication_test 192.168.3.108

###############################################################################
# Real-time kernel (manual/interactive steps required)
###############################################################################
# mkdir -p "${HOME}/kernel"
# cd "${HOME}/kernel"
# wget https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.15.195.tar.gz
# wget https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/5.15/patch-5.15.195-rt90.patch.xz
# tar -xzf linux-5.15.195.tar.gz
# xz -d patch-5.15.195-rt90.patch.xz
# cd linux-5.15.195/
# patch -p1 <../patch-5.15.195-rt90.patch
# cp /boot/config-5.15.0-139-generic .config

# Manual: make menuconfig and disable NFS server support.
# Manual: scripts/config --disable SYSTEM_TRUSTED_KEYS
# Manual: scripts/config --disable SYSTEM_REVOCATION_KEYS
# sudo apt install -y dwarves
# sudo apt install -y zstd
# Manual: sudo make (can take hours), then sudo make install
# Manual: reboot

###############################################################################
# Launch helper (example)
###############################################################################
# cat > "${HOME}/launch_both_robots.sh" <<'EOF'
# #!/bin/bash
# export PS4='+ $(date "+%H:%M:%S.%3N")  '
# set -x
# rostopic pub -1 -l /joint_position_example_controller/gripper_release std_msgs/Bool "data: true"
# echo "Hello world"
# echo " " > /tmp/run_barrier
# EOF
# chmod +x "${HOME}/launch_both_robots.sh"
