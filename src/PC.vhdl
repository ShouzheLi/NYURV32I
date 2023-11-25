library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ProgramCounter is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        pc_in : in STD_LOGIC_VECTOR(31 downto 0);
        pc_out : out STD_LOGIC_VECTOR(31 downto 0);
        pc_enable : in STD_LOGIC
    );
end ProgramCounter;

architecture Behavioral of ProgramCounter is
    signal pc : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            pc <= (others => '0');
        elsif rising_edge(clk) and pc_enable = '1' then
            pc <= pc_in;
        end if;
    end process;

    pc_out <= pc;
end Behavioral;
