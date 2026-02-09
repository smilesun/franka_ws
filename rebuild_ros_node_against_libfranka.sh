cd franka_ros_ws
source /opt/ros/noetic/setup.bash

rm -rf build devel
catkin_make
source devel/setup.bash

ldd devel/lib/franka_control/franka_control_node | grep franka
ldd devel/lib/franka_gripper/franka_gripper_node | grep franka

# ensure /usr/local/lib is in the loader path:
cat /etc/ld.so.conf.d/*.conf | grep -n "/usr/local/lib" || true

# if above is showing nothing

ldconfig -v 2>/dev/null | grep -A1 "/usr/local/lib"




