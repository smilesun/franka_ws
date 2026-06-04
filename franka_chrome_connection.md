
### Franka Panda
Switch on the robot and wait until the yellow light is continuous. Connect the Ethernet wire to your PC. Configure your Ethernet IP address to ```192.168.3.10``` and the netmask to ```255.255.255.0```. 
Open google chrome browser and visit ```https://192.168.3.108/```. If usrname and password is required, enter usrname: franka, password: frankaRSI

#### For first use, press the button on the last joint of the robot, in front of the center button (press once), the bigger one.
#### Open setting, in weight cancellation mode, choose the right end effector 
#### don't forget to source noetic, i.e. enter ros environment.

After logging in, unlock the robot by clicking a button in the right middle of the UI. Keep the safety button in your hand. press it to lock the robot and the white light should be on. Spin it clockwise to unlock the safety button, the light should turn blue and the robot can be moved. On the top right, find a button to activate FCI so that it can be controlled by your code.
Then you should be able to run your code. Open three terminals, one in libfranka/build/examples and two in franka_ros_ws.
In libfranka, execute
```bash
cd ~/workspace/franka_ws/libfranka/build/examples
./communication_test 192.168.3.108
```
to test communication with the robot, and the robot should be able to move to the zero position.
In franka_ros_ws 1, do
```bash
cd ~/workspace/franka_ws/franka_ros_ws
catkin_make
```
to compile the ros workspace whenever you did some changes in the code.
In franka_ros_ws_2, run the controller by
```bash
cd ~/workspace/franka_ws/franka_ros_ws
source devel/setup.bash
roslaunch franka_example_controllers joint_velocity_example_controller.launch robot_ip:=192.168.3.108

# To test the code in simulation:
source devel/setup.bash
roslaunch franka_gazebo panda.launch controller:=joint_velocity_example_controller rviz:=true
```


TODO next step: 
1. print a new catcher without the holder.
2. Try the robust trajectory.
