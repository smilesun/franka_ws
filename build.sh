#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

###############################################################################
# Install libfranka dependencies (Ubuntu 20.04)
###############################################################################
sudo apt-get update
sudo apt-get install -y build-essential cmake git libpoco-dev libeigen3-dev libfmt-dev # build toolchain, build system, VCS, Poco libs, Eigen headers, and fmt formatting lib

###############################################################################
# Install libfranka package
###############################################################################
cd "${HOME}/Downloads"
wget https://github.com/frankarobotics/libfranka/releases/download/0.18.2/libfranka_0.18.2_focal_amd64.deb
sudo dpkg -i libfranka_0.18.2_focal_amd64.deb
# .deb is the prebuilt libfranka package for Ubuntu 20.04.  It typically contains:
#  - Shared library files (e.g., libfranka.so)
#  - C++ headers for the libfranka API
#  - CMake config files (so projects can find_package(libfranka))
#  - License and docs
#
#  To see the exact contents on your machine (after download), run:
#
#  dpkg -c libfranka_0.18.2_focal_amd64.deb
#
#  To see metadata:
#
#  dpkg -I libfranka_0.18.2_focal_amd64.deb
#
#
# - libfranka is the low‑level C++ library that talks directly to Franka robots (FCI). It provides the core API for real robot control.
# - franka_ros is a ROS 1 wrapper that depends on libfranka. It exposes the robot into ROS (topics, services, controllers).
# - ros-noetic-desktop-full is the full ROS 1 Noetic distribution. It gives you ROS itself (tools, messages, Gazebo, RViz). 
# dependency: libfranka → franka_ros → ROS.

###############################################################################
# Build franka_ros (catkin workspace)
###############################################################################
mkdir -p "${SCRIPT_DIR}/franka_ros_ws/src"
cd "${SCRIPT_DIR}/franka_ros_ws/src"

git clone git@github.com:smilesun/franka_ros.git

sudo apt install -y ros-noetic-pinocchio # Pinocchio rigid-body dynamics for kinematics/dynamics
sudo apt install -y ros-noetic-combined-robot-hw # ROS combined robot hardware abstraction
sudo apt install -y ros-noetic-boost-sml # Boost.SML for state-machine logic
sudo apt install -y ros-noetic-combined-robot-hw

sudo apt install -y ros-noetic-catkin
# sudo apt install -y catkin  # dependency problem

cd "${SCRIPT_DIR}/franka_ros_ws"
source /opt/ros/noetic/setup.bash
catkin_make # with underscore
