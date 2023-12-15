library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity instruction_memory is
    Port (
        
        pc : in std_logic_vector(31 downto 0);
        instr : out std_logic_vector(31 downto 0)
    );
end instruction_memory;

architecture Behavioral of instruction_memory is
    constant BASE_ADDRESS : std_logic_vector(31 downto 0) := x"01000000";
    type memory_type is array (natural range <>) of std_logic_vector(31 downto 0);
    signal instr_mem : memory_type(0 to 511);

    procedure Load_Memory_From_File(file_name : in string; mem : out memory_type) is
        file mem_file : text;
        variable line : line;
        variable line_num : integer := 0;
        variable mem_word : bit_vector(31 downto 0);
        variable good : boolean;
    begin
        file_open(mem_file, file_name, read_mode);
        while not endfile(mem_file) loop
            readline(mem_file, line);
            read(line, mem_word, good);
            if good then
                mem(line_num) := to_stdlogicvector(mem_word);
                line_num := line_num + 1;
            end if;
        end loop;
        file_close(mem_file);
    end procedure;


begin
    -- Call the procedure to load memory from a file during initialization
    init : process 
    variable mem_variable : memory_type(0 to 511);
    file mem_file : text;
        variable line : line;
        variable line_num : integer := 0;
        variable mem_word : bit_vector(31 downto 0);
        variable good : boolean;
    begin
        file_open(mem_file, "instruction.mem", read_mode);
        while not endfile(mem_file) loop
            readline(mem_file, line);
            read(line, mem_word, good);
            if good then
                instr_mem(line_num) <= to_stdlogicvector(mem_word);
                line_num := line_num + 1;
            end if;
        end loop;
        file_close(mem_file);
        wait;
    end process;

    -- Concurrent statement to output the instruction based on pc

    instr <= instr_mem(to_integer(unsigned(pc) - unsigned(BASE_ADDRESS)) / 4);

end Behavioral;
