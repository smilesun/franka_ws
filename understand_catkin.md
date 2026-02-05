# Understanding Catkin Packages

A **catkin package** is the basic build and distribution unit in ROS 1. It is a folder that contains code plus metadata so the ROS build system knows how to build it, link it, and expose its APIs.

A folder is a catkin package if it contains **both**:

- `package.xml`
- `CMakeLists.txt` (written in the catkin style)

These files define things like:

- Package name and version
- Build and run dependencies
- Libraries or executables to compile
- Message/service definitions
- Include directories and exports

In this workspace, `franka_ros` contains multiple catkin packages (for example `franka_hw`, `franka_control`, `franka_gazebo`, and `franka_example_controllers`). `catkin_make` scans the `src/` tree, finds each package, computes their dependency order, and builds them in the right sequence.
