# README Commands Explained (Lines 90–117)

This file explains the commands shown in `README.md` lines 90–117.

1. `source ~/workspaces/franka_ws/franka_ros_ws/devel/setup.bash`
Sets up the current shell so ROS can find packages built in that workspace (e.g., updates `ROS_PACKAGE_PATH`).

2. `roslaunch franka_gazebo panda.launch x:=-0.5 world:=$(rospack find franka_gazebo)/world/stone.sdf controller:=cartesian_impedance_example_controller rviz:=true`
Starts the Gazebo simulation of the Panda robot with:
- custom world file (`stone.sdf`)
- the robot spawned with an `x` offset
- the Cartesian impedance controller loaded
- RViz enabled

3. `roslaunch franka_gazebo panda.launch rviz:=true controller:=cartesian_impedance_example_controller`
Starts the same Gazebo simulation but with default world and default robot pose (no `x` or `world` overrides).

4. `roslaunch franka_gazebo panda.launch controller:=joint_velocity_example_controller rviz:=true`
Starts the simulation again but loads the joint velocity controller instead of the Cartesian impedance controller.

5. `roslaunch franka_example_controllers joint_impedance_example_controller.launch load_gripper:=true robot:=panda`
Launches the joint impedance controller example (no Gazebo). Typically used with a real robot or an already-running hardware interface. Also loads the gripper.

6. `roslaunch franka_example_controllers joint_velocity_example_controller.launch robot_ip:=192.168.3.108`
Launches the joint velocity controller example and connects to a real robot at the specified IP.

7. `cd build/examples` then `./communication_test 192.168.3.108`
Runs a libfranka example binary (not ROS) that directly tests communication with the robot at the given IP.
