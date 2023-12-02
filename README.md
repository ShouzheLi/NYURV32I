# NYURV32I
EL-6463-RV32I Processor Design Project

Group Number: Group 14

Name: shouzhe Li, Tong Wu, yuye Li

NetId: sl9705, Tw2593, yl1203


## ALU

The ALU.vhd module in VHDL is designed to perform various arithmetic and logical operations fundamental to the functioning of a CPU. This ALU accepts two 32-bit inputs (a and b) and a 4-bit operation selector (alu_sel). Based on the value of alu_sel, the ALU can execute operations like addition, subtraction, bitwise AND, OR, XOR, left and right shifts, and set on less than. The result of the operation is output as a 32-bit value (alu_result). Additionally, the ALU provides flags such as zero, indicating if the result is zero, and overload, signaling arithmetic overflow conditions. This design makes the ALU versatile and capable of supporting a wide range of computational tasks in a digital system.

tb_ALU: Each different instruction is selected by assigning the corresponding value to signal alu_sel. Then, in the test for each instruction, the values of a and b are assigned and assert statements are used to check if the output values in signal alu_result and overload are correct or not.

## CONTROL_UNIT

The ControlUnit.vhd module is a key component in VHDL for orchestrating the operation of a processor. It acts as the brain of the processor, interpreting the opcode and function codes from the incoming instruction and generating the necessary control signals to guide data flow and operation throughout the processor's sub-modules.

This module takes in a 32-bit instruction (instr), an opcode (opcode), function codes (funct3, funct7), and a clock signal (clk). It decodes the opcode and function codes to determine the type of instruction (e.g., arithmetic, logic, load/store, branch, jump) and sets various control signals accordingly. These control signals include immsrc (immediate data source type), alu_op (ALU operation code), br_type (branch type), readcontrol, writecontrol (for memory operations), reg_wr (register write enable), sel_A, sel_B (operand selectors for ALU), and wb_sel (write-back selection for the result).

The module's internal Finite State Machine (FSM) navigates through stages like Instruction Fetch (IFI), Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB), reflecting a typical instruction cycle in a processor. In each stage, the control unit generates and updates control signals based on the current instruction's needs. For instance, in the Decode stage, it sets signals for the ALU operation and source selection, while in the Execute stage, it might evaluate branch conditions or execute an ALU operation.

tb_Control: The reset signal is tested firstly, and then check the module passes or fails by the value of output signal hlt.

## DATA MEMORY

The DataMemory.vhd module in VHDL serves as a data storage unit in a processor design. It interfaces with the processor through a 32-bit address input (address), data input (writedata), and outputs a 32-bit data (read_data). The module operates on clock (clk) and reset (rst) signals. It supports read and write operations governed by control signals readcontrol and writecontrol, which determine the size and type of the data operation (byte, halfword, or word). The module is essential for the processor's memory operations, allowing it to store and retrieve data as per the program's requirements, playing a pivotal role in the execution of load/store instructions.

tb_DataMemory: Firstly, reset signal is tested by converting the signal rst. Then a 32 bits values are input using the 32 bits writing instruction, and the 8 bits reading instruction is used to read the last 8 bits of the value I stored before. The test for instruction memory module is included in this testbench.

## INSTRUCTION MEMORY

The InstructionMemory.vhd is a VHDL module designed to store and provide instruction data for a processor. It accepts a 32-bit input address (addr) and outputs a corresponding 32-bit instruction (instr). The module utilizes an internal memory array, with each address storing a distinct instruction. This setup simulates an instruction memory in digital systems, serving as a repository of executable instructions that the processor fetches and decodes during operation. This module is crucial for the processor's instruction fetch phase, enabling the sequential execution of program instructions.

The testbench for this module is included in the tb_DataMemory.

## PROGRAM COUNTER

The PC.vhd is a VHDL module that functions as a Program Counter in digital systems. It has a 32-bit output pc that holds the current instruction address. The module updates this address based on the input signal pc_next, synchronized with the clock clk. A reset input rst is used to initialize or reset the counter. This module is essential in sequential logic, driving the instruction fetch process by pointing to the next instruction to be executed in a program.

tb_PC: Convert the input values of reset signal and enable signal to check the function of them.


## REGISTER FILE

The InstructionMemory.vhd is a VHDL module representing a read-only memory that stores program instructions. It accepts a 32-bit address input addr, which specifies the memory location to be accessed. The module outputs a 32-bit instruction instr corresponding to the input address. This module essentially simulates the behavior of an instruction memory in a processor, where it retrieves stored instructions based on the program counter's value, aiding in the sequential execution of a program.

tb_RegisterFile: firstly, the values of signal rst and write enable are changed to check the reset functon. Then the write instructions are used to store the value x"11111111" in the register with index "1", and the value x"22222222" in the register with index "2".

## BRANCH

The branch.vhd is a VHDL module designed to determine branching conditions in a computational process. It accepts two 32-bit inputs a and b, representing comparison operands, and a 3-bit input branch_type to specify the type of branch condition (e.g., BEQ, BNE). The module outputs a single bit branch_taken, which signals whether the branch condition is met. This module plays a critical role in controlling the flow of a program, deciding if the next instruction sequence should be altered based on the comparison result.

