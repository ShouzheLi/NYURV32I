library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionMemory is
    Port (
        addr : in STD_LOGIC_VECTOR(31 downto 0);
        instr : out STD_LOGIC_VECTOR(31 downto 0)
    );
end InstructionMemory;

architecture Behavioral of InstructionMemory is
    -- 假设指令内存大小为2KB，每个地址存储32位数据
    type memory_type is array (0 to 2047) of STD_LOGIC_VECTOR(31 downto 0);
    -- 初始化内存内容
    signal memory : memory_type := (others => (others => '0'));
begin
    -- 输出指令数据
    instr <= memory(to_integer(unsigned(addr(11 downto 2))));
end Behavioral;
