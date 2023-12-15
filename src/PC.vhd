library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ProgramCounter is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        pc_next : in STD_LOGIC_VECTOR(31 downto 0);
        pc : out STD_LOGIC_VECTOR(31 downto 0)
    );
end ProgramCounter;

architecture Behavioral of ProgramCounter is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            pc <= x"01000000";
        elsif not rising_edge(clk) then
            pc <= pc_next;
        end if;
    end process;
end Behavioral;
