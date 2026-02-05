# Why Simulation Is Often Run Alongside Real Franka Robots

Franka does **not** need simulation running to control real robots. Simulation is optional and used for convenience. The items below explain why simulation-like components often appear alongside real hardware.

- `Visualization in RViz`: You still need `robot_description`, `robot_state_publisher`, and `joint_states` to see the robot in RViz. That is not simulation, just visualization.
- `Testing controllers safely`: You can validate controller logic in Gazebo or a simulated robot before touching real hardware.
- `Planning or perception pipelines`: Some stacks assume a robot model in the TF tree and may need simulated or visualized frames to function.
- `Digital twin workflows`: Simulation and real can run together so you can compare expected versus actual motion.

If you are running Gazebo (`franka_gazebo`), that is simulation. If you are only running the hardware node plus visualization helpers, you are not simulating the robot.
