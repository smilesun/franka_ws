# ROS Concepts in `franka_control`

- `Nodes`: `franka_control_node` and `franka_combined_control_node` are hardware nodes that integrate the real robot into `ros_control`. They manage the connection to the robot and expose control interfaces. See `franka_control/doc/index.rst`.
- `Hardware interfaces (ros_control)`: These nodes wrap hardware classes from `franka_hw` and expose them to the `ros_control` ecosystem so controllers can command the robot. See `franka_control/doc/index.rst`.
- `Controllers (pluginlib)`: Controllers are loaded via the ROS controller framework. `FrankaStateController` is registered as a plugin and publishes state. See `franka_control/franka_controller_plugins.xml` and `franka_control/doc/index.rst`.
- `ROS services`: The package exposes services to configure impedance, frames, collision thresholds, and loads. These are ROS services around the `libfranka` API. See `franka_control/doc/index.rst`.
- `ROS actions`: Error recovery is provided via an action (`franka_msgs::ErrorRecoveryAction`), so recovery is handled with action goals. See `franka_control/doc/index.rst`.
- `TF frames`: The package defines runtime-adjustable frames like `<arm_id>_EE` and `<arm_id>_K`, and explains how they relate to the robot model. See `franka_control/doc/index.rst`.
- `Parameter server`: Multi-robot setup is configured by putting hardware blocks under the node's namespace in YAML. This is standard ROS param usage. See `franka_control/doc/index.rst` and the YAML examples it references.
- `Launch files`: Launch files start the hardware node, state controller, and `robot_state_publisher`. See `franka_control/doc/index.rst` and `franka_control/launch`.
