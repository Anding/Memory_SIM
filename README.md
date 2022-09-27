# Memory_SIM
Drop-in functional simulation of Xilinx BLOCK RAM

## Overview
Running simulations of designs incorporating Xilinx BLOCK RAM instantiated via the IP library can be time consuming:
+ BLOCK RAM IP needs to be rebuilt each time the .COE file specifying the memory contents changes
+ Simulator startup time is (probably) slower with functionally accurate BLOCK RAM simulation
+ Limited scope for automated testbenches that re-test the design with different memory contents

## Usage
Use VHDL comments or ```GENERATE``` statements to toggle BLOCK RAM and MEMORY_SIM entities.  Example testbenches are included

