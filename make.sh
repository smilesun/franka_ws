cd franka_ros_ws
source /opt/ros/noetic/setup.bash
catkin_make # with underscore, this command should be run at workspace root folder, where /src should be found
# catkin_make treats this directory as the workspace root.
# # It scans "${SCRIPT_DIR}/franka_ros_ws/src" for catkin packages.
# # It runs CMake in "${SCRIPT_DIR}/franka_ros_ws/build" to configure the workspace.
# # It builds with make, producing binaries and libraries in the build space.
# # It stages outputs (devel space) in "${SCRIPT_DIR}/franka_ros_ws/devel".
# # If you run "catkin_make install", it also copies installable artifacts into "${SCRIPT_DIR}/franka_ros_ws/install".
