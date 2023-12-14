library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity instruction_fetch is
    Port (
        instr : in STD_LOGIC_VECTOR(31 downto 0);
        opcode : out STD_LOGIC_VECTOR(6 downto 0);
        rd : out STD_LOGIC_VECTOR(4 downto 0);
        funct3 : out STD_LOGIC_VECTOR(2 downto 0);
        rs1 : out STD_LOGIC_VECTOR(4 downto 0);
        rs2 : out STD_LOGIC_VECTOR(4 downto 0);
        funct7 : out STD_LOGIC_VECTOR(6 downto 0);
        imm : out STD_LOGIC_VECTOR(24 downto 0)
    );
end instruction_fetch;

architecture Behavioral of instruction_fetch is
begin
    opcode <= instr(6 downto 0);
    rd <= instr(11 downto 7);
    funct3 <= instr(14 downto 12);
    rs1 <= instr(19 downto 15);
    rs2 <= instr(24 downto 20);
    funct7 <= instr(31 downto 25);
    imm <= instr(31 downto 7);
end Behavioral;
