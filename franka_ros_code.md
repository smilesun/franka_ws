# Joint Velocity Example Controller (C++)

## Source locations
- Controller implementation: `franka_ros_ws/src/franka_ros/franka_example_controllers/src/joint_velocity_example_controller.cpp`
- Controller header: `franka_ros_ws/src/franka_ros/franka_example_controllers/include/franka_example_controllers/joint_velocity_example_controller.h`
- Launch file that loads it: `franka_ros_ws/src/franka_ros/franka_example_controllers/launch/joint_velocity_example_controller.launch`
- YAML config referenced by the launch: `franka_ros_ws/src/franka_ros/franka_example_controllers/config/franka_example_controllers.yaml`

## What the controller does (summary)
- Implements `JointVelocityExampleController` as a `MultiInterfaceController` over `VelocityJointInterface` and `FrankaStateInterface`.
- Reads `joint_names` from the ROS param server and obtains velocity joint handles.
- Gets the Franka state handle for `<arm_id>_robot` (currently hard-coded to `panda` in the .cpp).
- Verifies the robot is near the expected start pose (`q_start`) before starting.
- Starts an input thread to listen for `r` key press and exposes a ROS service `gripper_release` to request gripper release.
- Creates action clients for gripper `homing`, `move`, `grasp`, `stop` and performs a homing on init.
- In `update`, commands joint velocities to move toward a fixed `q_target` using `omega_max * tanh(kp * e)`.
- When the arm is stable at the target pose, drives a simple gripper state machine (open -> grasp -> release).

## Notable parameters/values in code
- `q_start`: expected initial pose; controller refuses to start if too far from it.
- `q_target`: fixed pose target inside `update`.
- `omega_max = 0.2`, `kp = 3.0`.
- Stability thresholds: `e_tol = 4e-2 rad`, `dq_tol = 3e-2 rad/s`, `stable_duration = 0.5 s`.

## Critical line: user presses `r`
This is the exact line that reacts to the keypress, and what it triggers:

```cpp
      if (c == 'r') {       // press r to release
        release_requested_.store(true, std::memory_order_relaxed);
        triggerRunBarrier();
        ROS_INFO("Release key pressed!");
      }
```

What happens:
- `release_requested_` is set, which later makes the gripper state machine transition to `RELEASE` in `update()`.
- `triggerRunBarrier()` writes a byte to `/tmp/run_barrier` (if it exists), which can be used as a synchronization signal.
- A ROS log message is emitted.

Source: `franka_ros_ws/src/franka_ros/franka_example_controllers/src/joint_velocity_example_controller.cpp`.

## Differences vs original
- There is an alternate file `joint_velocity_example_controller_original.cpp` in the same folder, but the build references `joint_velocity_example_controller.cpp`.
