library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_memory is
    Port (
        pc : in STD_LOGIC_VECTOR(31 downto 0);
        instr : out STD_LOGIC_VECTOR(31 downto 0)
    );
end instruction_memory;

architecture Behavioral of instruction_memory is
    constant BASE_ADDRESS : STD_LOGIC_VECTOR(31 downto 0) := x"01000000";
    type memory_type is array (0 to 511) of STD_LOGIC_VECTOR(31 downto 0);
    signal instr_mem : memory_type := (
        0 => x"00500113", 1 => x"00c00193", 2 => x"003100b3",
        3 => x"00500113", 4 => x"00c00193", 5 => x"003100b3",
        6 => x"00500113", 7 => x"00c00193", 8 => x"003100b3",
        9 => x"00500113", 10 => x"00c00193", 11 => x"003100b3",
        12 => x"00500113", 13 => x"00c00193", 14 => x"003100b3",
        15 => x"00500113", 16 => x"00c00193", 17 => x"003100b3",
        18 => x"00500113", 19 => x"00c00193", 20 => x"003100b3",
        others => (others => '0')
    );
begin
    
    -- Concurrent statement to output the instruction based on pc
    instr <= instr_mem(to_integer(unsigned(pc) - unsigned(BASE_ADDRESS)) / 4);


end Behavioral;
