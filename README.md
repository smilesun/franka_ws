# Franka Workspace (with Git Submodules)

This repository uses Git submodules to include several dependent repositories.

## How to initialize a franka project

### Install libfranka

Actually you don't need to clone the libfranka repository and build it yourself as this won't work.
Just follow the link in readme in this repository. The following steps works for system Ubuntu20.04.

First install dependencies

```bash
sudo apt-get update
sudo apt-get install -y build-essential cmake git libpoco-dev libeigen3-dev libfmt-dev
```
Then download the package and extract it and install
```bash
cd Downloads
wget https://github.com/frankarobotics/libfranka/releases/download/0.18.2/libfranka_0.18.2_focal_amd64.deb
sudo dpkg -i libfranka_0.18.2_focal_amd64.deb
```
After executing this the libfranka package should be installed on your PC. This step is neccessary because
later the franka_ros library need this package to compile.

### Build franka_ros

create a workspace franka_ws, in this folder create a franka_ros_ws, this is the ros catkin workspace used later.
Inside franka_ros_ws add a src folder and clone the forked franka_ros repository on your own github.

```bash
mkdir franka_ws
cd franka_ws
mkdir franka_ros_ws
cd franka_ros_ws
mkdir src
cd src
git clone git@github.com:prominentjohnson/franka_ros.git
```
Before building it's better to install all the required dpendencies. For examples here are the dependencies that was missing on my PC.
```bash
sudo apt install ros-noetic-pinocchio
sudo apt install ros-noetic-combined-robot-hw
sudo apt install ros-noetic-boost-sml
```
Then go back to the ros workspace and build it. 
```bash
cd ..
catkin_make
```
Trouble shooting: When installing you might encounter the following error:
```bash
/usr/include/research_interface/robot/service_types.h:242:24: error: ‘optional’ in namespace ‘std’ does not name a template type 242 | const std::optional<std::vector<double>> &maximum_velocity = std::nullopt)
/usr/include/research_interface/robot/service_types.h:242:19: note: ‘std::optional’ is only available from C++17 onwards 242 | const std::optional<std::vector<double>> &maximum_velocity = std::nullopt)
```
This is because the code was compiled using C++14, however the code is C++17 compliant. So the solution is to modify the CmakeList and force it to compile using C++17. Here's how to do it: Find the CMakeLists.txt which is responsible for the error report, then delete the following two lines
```cmake
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
```
Then add the following line after add_library or add_executable command
```cmake
target_compile_features(franka_hw PUBLIC cxx_std_17)
```
Here are two examples:
```cmake
foreach(executable ${EXECUTABLES})
    add_executable(${executable}
    src/${executable}.cpp
  )
target_compile_features(${executable} PUBLIC cxx_std_17)
```
or
```cmake
add_library(franka_hw
  src/control_mode.cpp
  src/franka_hw.cpp
  src/franka_combinable_hw.cpp
  src/franka_combined_hw.cpp
  src/resource_helpers.cpp
  src/trigger_rate.cpp
)
target_compile_features(franka_hw PUBLIC cxx_std_17)
```
Then run catkin_make again until it can build successfully.

## How to run ROS simulation

source the setup file in the ros workspace
```bash
source ~/workspaces/franka_ws/franka_ros_ws/devel/setup.bash
```
Then run the launch file to start the gazebo simulation
```bash
roslaunch franka_gazebo panda.launch x:=-0.5     world:=$(rospack find franka_gazebo)/world/stone.sdf     controller:=cartesian_impedance_example_controller     rviz:=true
```
Then open another terminal and run
```bash
roslaunch franka_gazebo panda.launch rviz:=true controller:=cartesian_impedance_example_controller
```
and you should be able to drag the arm in the rviz.

roslaunch franka_gazebo panda.launch x:=-0.5     world:=$(rospack find franka_gazebo)/world/stone.sdf     controller:=joint_position_example_controller     rviz:=true


roslaunch franka_example_controllers joint_impedance_example_controller.launch load_gripper:=true robot:=panda


## Tips for Installing Real Time Kernel

### General steps

Basically follow this link https://www.acontis.com/en/building-a-real-time-linux-kernel-in-ubuntu-preemptrt.html (This one is better than other instructions which I have tried before)

Website for RT kernel patches: https://www.kernel.org/pub/linux/kernel/projects/rt/
```bash
mkdir ~/kernel
cd ~/kernel
```
For Ubuntu20.04 with the original kernel 5.15.0-139-generic, execute
```bash
wget https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.15.195.tar.gz
wget https://mirrors.edge.kernel.org/pub/linux/kernel/projects/rt/5.15/patch-5.15.195-rt90.patch.xz
```
Still you have to follow that link, but here are the commands I used during installation
```bash
tar -xzf linux-5.15.195.tar.gz
xz -d patch-5.15.195-rt90.patch.xz
cd linux-5.15.195/
patch -p1 <../patch-5.15.195-rt90.patch
cp /boot/config-5.15.0-139-generic .config
```

### Trouble shooting

1. When encountered with following error: 
```bash
././include/linux/compiler_types.h:334:38: error: call to ‘__compiletime_assert_933’ declared with attribute error: clamp() low limit slotsize greater than high limit total_avail/scale_factor
```
Disable NFS server support. This can be done by executing
```bash
make menuconfig
```
Then in the GUI, find -> File systems -> Network File Systems -> NFS server support, select this and press space until the check box in front is empty(<>). Then save and exit.


2. Execute following two commands in after running "make menuconfig"
```bash
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS
```

3. Before sudo make, 
```bash
sudo apt install dwarves
```

4. If have not install zstd,  then
```bash
sudo apt update
sudo apt install zstd
```

5. When compiling and executing sudo make, it might take around 3 hours. Drink cups of coffee and Wait.

6. After the compilation is finished, when executing "sudo make install", maybe the boot space is full. Then safely remove the old kernel before install again.

7. After everything is compiled and installed, reboot. If you encountered an error like "out of memory" in the grub interface and are not able to enter the system, here's the solution:

try to enter the Ubuntu system using the recovery mode, or using live Ubuntu with USB booting. Then do:
```bash
mount -o remount,rw/
sudo nano /etc/initramfs-tools/initramfs.conf
```
find the line ```MODULES=most``` and change it to ```MODULES=dep```, and press Ctrl+O, Enter and Ctrl+X. Then
```bash
sudo update-initramfs -c -k 5.15.195-rt90
sudo update-grub
```
Reboot again and it should be fine now.
