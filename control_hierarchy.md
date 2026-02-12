Your code
   ↓
   Velocity controller (robot firmware)
      ↓
      Torque controller
         ↓
         Motor current controller
            ↓
            Motor driver electronics
               ↓
               Motor torque
               
               
- Motor driver (hardware) is the power electronics that actually pushes current into the motor phases (H‑bridge, inverter, gate drivers, etc.).
- Motor drive/driver code (firmware) runs on a controller (MCU/FPGA) and talks to that driver circuit—it generates PWM, commutation, current loops, safety checks, etc.
- On‑board computer (SBC) runs high‑level control, planning, user I/O.
- MCU/FPGA motor controller runs the hard real‑time loops (current/torque/velocity), directly
  connected to the driver circuit. The on‑board computer communicates with the MCU/FPGA (e.g., UDP/CAN/RS‑485). 
                          
                          
