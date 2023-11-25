library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DataMemory is
    Port (
        clk : in STD_LOGIC;
        addr : in STD_LOGIC_VECTOR(31 downto 0);
        write_data : in STD_LOGIC_VECTOR(31 downto 0);
        mem_read : in STD_LOGIC;
        mem_write : in STD_LOGIC;
        read_data : out STD_LOGIC_VECTOR(31 downto 0)
    );
end DataMemory;

architecture Behavioral of DataMemory is
    -- ���������ڴ��СΪ4KB��ÿ����ַ�洢32λ����
    type memory_type is array (0 to 4095) of STD_LOGIC_VECTOR(31 downto 0);
    -- ��ʼ���ڴ�����
    signal memory : memory_type := (others => (others => '0'));
begin
    -- �����ڴ��д����
    process(clk)
    begin
        if rising_edge(clk) then
            -- ����д��
            if mem_write = '1' then
                memory(to_integer(unsigned(addr(11 downto 2)))) <= write_data;
            end if;
        end if;
    end process;

    -- ���ݶ�ȡ
    read_data <= memory(to_integer(unsigned(addr(11 downto 2)))) when mem_read = '1' else (others => '0');
end Behavioral;
