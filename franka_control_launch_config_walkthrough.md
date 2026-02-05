# Hands-On Walk-Through: `franka_control` Launch and Config

## Single-Robot Launch Flow (`franka_control.launch`)

1. `robot_description` is generated from Xacro so ROS knows the robot model and frames.
   File: `franka_control/launch/franka_control.launch`
2. Optionally starts the gripper launch when `load_gripper:=true`.
   File: `franka_control/launch/franka_control.launch`
3. Starts the hardware node `franka_control_node` and loads its params from YAML.
   File: `franka_control/launch/franka_control.launch`
   File: `franka_control/config/franka_control_node.yaml`
4. Loads controller definitions from YAML, then spawns `franka_state_controller`.
   File: `franka_control/launch/franka_control.launch`
   File: `franka_control/config/default_controllers.yaml`
5. Starts `robot_state_publisher` and a `joint_state_publisher` that fuses joint states from arm and gripper.
   File: `franka_control/launch/franka_control.launch`

## Key Controller Configs (`default_controllers.yaml`)

- `position_joint_trajectory_controller`
  Uses `position_controllers/JointTrajectoryController` and targets `$(arg arm_id)_joint1...7`.
  File: `franka_control/config/default_controllers.yaml`
- `effort_joint_trajectory_controller`
  Uses `effort_controllers/JointTrajectoryController` with PID gains per joint.
  File: `franka_control/config/default_controllers.yaml`
- `franka_state_controller`
  A custom controller plugin that publishes the Franka state at 30 Hz.
  File: `franka_control/config/default_controllers.yaml`
  Plugin registration: `franka_control/franka_controller_plugins.xml`

## What the Hardware Node Config Does (`franka_control_node.yaml`)

- Sets `arm_id` and joint names, plus runtime safety/behavior settings like rate limiting, collision thresholds, and internal impedance controller mode.
  File: `franka_control/config/franka_control_node.yaml`

## Multi-Robot Launch Flow (`franka_combined_control.launch`)

1. Launches `franka_combined_control_node` with a multi-robot hardware config.
   File: `franka_control/launch/franka_combined_control.launch`
   File: `franka_control/config/franka_combined_control_node.yaml`
2. Loads controller configs for all robots and spawns the controllers in one shot.
   File: `franka_control/launch/franka_combined_control.launch`
   File: `franka_control/config/default_combined_controllers.yaml`
3. Uses a `group` namespace so multiple robot controllers and state publishers do not collide.
   File: `franka_control/launch/franka_combined_control.launch`

## Multi-Robot Config Patterns

- `franka_combined_control_node.yaml` defines a list of robot hardware blocks (`robot_hardware`) and each robot's settings.
  File: `franka_control/config/franka_combined_control_node.yaml`
- `default_combined_controllers.yaml` includes one controller that drives all joints, plus one state controller per arm.
  File: `franka_control/config/default_combined_controllers.yaml`
