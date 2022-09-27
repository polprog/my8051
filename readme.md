my8051
======

This project contains my experimental FPGA code aiming to program an
8051 software core with several peripherals on the Colorlight 5A-75B
board using the Lattice ECP5 FPGA.

The `r8051.v` and `instruction.v` is the Verilog source code for an
8051 core, by Li Xinbing released under the Apache 2.0 Licence

The main Verilog module is `top.v`. `test.v` is the Icarus Verilog testbench.

The 8051_leds/ contains a KiCad project for a small addon board that
plugs on the HUB75 header. It's angled so that its parallel with the
main PCB.

tools/bin2memh.py is a script that can convert a file to a hex file
that is loaded with $readmemh directive. This is not an Intel HEX
format.

Currently the project stalled as the core seems to take every jump ;)

Requisites
==========

The code has been tested with Yosys suite for compilation for ECP5.
The makefile uses Icarus Verilog for simulation

You need SDCC assembler for 8051 (sdas8051) to assemble the test
listings. You can also assemble them by hand.




Copying
=======
Except otherwise stated, the files are

Copyright 2022 polprog

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.