library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionMemory is
    Port (
        addr : in STD_LOGIC_VECTOR(31 downto 0);   -- Input address (byte-addressed)
        instr : out STD_LOGIC_VECTOR(31 downto 0)  -- Output instruction (word)
    );
end InstructionMemory;

architecture Behavioral of InstructionMemory is
    -- Instruction memory is 2KB, and we assume it is word-indexed and 32-bits wide.
    -- Since the memory starts at 0x01000000, we need to adjust the input addresses accordingly.
    constant BASE_ADDRESS : std_logic_vector(31 downto 0) := x"01000000";
    type memory_type is array (0 to 511) of STD_LOGIC_VECTOR(31 downto 0); -- 2KBytes / 4 bytes per word = 512 words
    signal memory : memory_type := (others => (others => '0'));
begin
    -- Perform address translation from byte address to word index.
    -- Subtract the base address then shift right by 2 (equivalent to dividing by 4 to get word indexing).
    process(addr)
    variable translated_index : integer;
    begin
        translated_index := to_integer(unsigned(addr) - unsigned(BASE_ADDRESS)) / 4;
        if translated_index >= 0 and translated_index < memory'length then
            instr <= memory(translated_index); -- Output the instruction at the translated index
        else
            instr <= (others => '0'); -- Output zeros if the address is outside the memory range
        end if;
    end process;
end Behavioral;
