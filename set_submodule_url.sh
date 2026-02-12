git submodule set-url franka_ros_ws/src/franka_ros git@github.com:smilesun/franka_ros.git
git submodule sync -- franka_ros_ws/src/franka_ros
git -C franka_ros_ws/src/franka_ros remote -v
git config -f .gitmodules --get submodule.franka_ros_ws/src/franka_ros.url
