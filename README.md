# NYURV32I
EL-6463-RV32I Processor Design Project

Group Number: Group 14

Name: shouzhe Li, Tong Wu, yuye Li

NetId: sl9705, Tw2593, yl1203


## ALU

The ALU.vhd module in VHDL is designed to perform various arithmetic and logical operations fundamental to the functioning of a CPU. This ALU accepts two 32-bit inputs (a and b) and a 4-bit operation selector (alu_sel). Based on the value of alu_sel, the ALU can execute operations like addition, subtraction, bitwise AND, OR, XOR, left and right shifts, and set on less than. The result of the operation is output as a 32-bit value (alu_result). Additionally, the ALU provides flags such as zero, indicating if the result is zero, and overload, signaling arithmetic overflow conditions. This design makes the ALU versatile and capable of supporting a wide range of computational tasks in a digital system.

## CONTROL_UNIT

The ControlUnit.vhd module is a key component in VHDL for orchestrating the operation of a processor. It acts as the brain of the processor, interpreting the opcode and function codes from the incoming instruction and generating the necessary control signals to guide data flow and operation throughout the processor's sub-modules.

This module takes in a 32-bit instruction (instr), an opcode (opcode), function codes (funct3, funct7), and a clock signal (clk). It decodes the opcode and function codes to determine the type of instruction (e.g., arithmetic, logic, load/store, branch, jump) and sets various control signals accordingly. These control signals include immsrc (immediate data source type), alu_op (ALU operation code), br_type (branch type), readcontrol, writecontrol (for memory operations), reg_wr (register write enable), sel_A, sel_B (operand selectors for ALU), and wb_sel (write-back selection for the result).

The module's internal Finite State Machine (FSM) navigates through stages like Instruction Fetch (IFI), Decode (ID), Execute (EX), Memory Access (MEM), and Write Back (WB), reflecting a typical instruction cycle in a processor. In each stage, the control unit generates and updates control signals based on the current instruction's needs. For instance, in the Decode stage, it sets signals for the ALU operation and source selection, while in the Execute stage, it might evaluate branch conditions or execute an ALU operation.

## DATAMEMORY

The DataMemory.vhd module in VHDL serves as a data storage unit in a processor design. It interfaces with the processor through a 32-bit address input (address), data input (writedata), and outputs a 32-bit data (read_data). The module operates on clock (clk) and reset (rst) signals. It supports read and write operations governed by control signals readcontrol and writecontrol, which determine the size and type of the data operation (byte, halfword, or word). The module is essential for the processor's memory operations, allowing it to store and retrieve data as per the program's requirements, playing a pivotal role in the execution of load/store instructions.
