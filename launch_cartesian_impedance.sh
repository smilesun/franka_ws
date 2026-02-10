cd franka_ros_ws
source devel/setup.bash
roslaunch franka_example_controllers cartesian_impedance_example_controller.launch robot_ip:=192.168.3.108 use_rviz:=false
