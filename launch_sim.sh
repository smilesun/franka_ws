source /home/sunxd/robustCapture/franka_ws/franka_ros_ws/devel/setup.bash
# headless:=false -> launch Gazebo with GUI (true runs server only)
# gazebo:=true    -> launch Gazebo as part of this launch (false assumes Gazebo is already running)
roslaunch franka_gazebo panda.launch controller:=cartesian_impedance_example_controller headless:=false gazebo:=true paused:=true rviz:=true
