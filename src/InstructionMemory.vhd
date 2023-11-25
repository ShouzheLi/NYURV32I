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
    -- ����ָ���ڴ��СΪ2KB��ÿ����ַ�洢32λ����
    type memory_type is array (0 to 2047) of STD_LOGIC_VECTOR(31 downto 0);
    -- ��ʼ���ڴ�����
    signal memory : memory_type := (others => (others => '0'));
begin
    -- ���ָ������
    instr <= memory(to_integer(unsigned(addr(11 downto 2))));
end Behavioral;
