cd franka_ros_ws
source /opt/ros/noetic/setup.bash
catkin_make -j8 # with underscore, this command should be run at workspace root folder, where /src should be found
# catkin_make treats this directory as the workspace root.
# # It scans "${SCRIPT_DIR}/franka_ros_ws/src" for catkin packages.
# # It runs CMake in "${SCRIPT_DIR}/franka_ros_ws/build" to configure the workspace.
# # It builds with make, producing binaries and libraries in the build space.
# # It stages outputs (devel space) in "${SCRIPT_DIR}/franka_ros_ws/devel".
# # If you run "catkin_make install", it also copies installable artifacts into "${SCRIPT_DIR}/franka_ros_ws/install".

#  91%] Built target franka_state_controller
#  [ 92%] Built target franka_control_node
#  [ 93%] Built target teleop_gripper_node
#  [ 93%] Building CXX object franka_ros/franka_example_controllers/CMakeFiles/franka_example_controllers.dir/src/joint_velocity_example_controller.cpp.o
#  [ 94%] Building CXX object franka_ros/franka_example_controllers/CMakeFiles/franka_example_controllers.dir/src/joint_impedance_example_controller.cpp.o
#  [ 94%] Building CXX object franka_ros/franka_example_controllers/CMakeFiles/franka_example_controllers.dir/src/cartesian_impedance_example_controller.cpp.o

################
#  [ 94%] Linking CXX shared library /home/sunxd/robustCapture/franka_ws/franka_ros_ws/devel/lib/libfranka_example_controllers.so
################

#  [ 97%] Built target franka_example_controllers
#  [ 97%] Linking CXX shared library /home/sunxd/robustCapture/franka_ws/franka_ros_ws/devel/lib/libfranka_gripper_sim.so
#  [ 97%] Linking CXX shared library /home/sunxd/robustCapture/franka_ws/franka_ros_ws/devel/lib/libfranka_hw_sim.so
#  [ 98%] Built target franka_gripper_sim
#  [100%] Built target franka_hw_sim
#
