library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        readcontrol : in STD_LOGIC_VECTOR(2 downto 0);
        writecontrol : in STD_LOGIC_VECTOR(2 downto 0);
        address : in STD_LOGIC_VECTOR(31 downto 0);
        writedata : in STD_LOGIC_VECTOR(31 downto 0);
        read_data : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity data_memory;

architecture Behavioral of data_memory is
    type data_mem_array is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
    signal data_mem_file : data_mem_array := (others => (others => '0'));
    signal store_intermediate : STD_LOGIC_VECTOR(31 downto 0);
begin
    process(clk, rst)
    begin
        if rising_edge(rst) then
            for i in 0 to 255 loop
                data_mem_file(i) <= (others => '0');
            end loop;
            store_intermediate <= (others => '0');
        elsif rising_edge(clk) then
            case writecontrol is
                when "000" =>  -- Store Byte
                    store_intermediate <= (24 => '0') & writedata(7 downto 0);
                    data_mem_file(to_integer(unsigned(address))) <= store_intermediate;
                when "001" =>  -- Store Halfword
                    store_intermediate <= (16 => '0') & writedata(15 downto 0);
                    data_mem_file(to_integer(unsigned(address))) <= store_intermediate;
                when "010" =>  -- Store Word
                    data_mem_file(to_integer(unsigned(address))) <= writedata;
                when others =>  -- Retain current value
                    null; -- 'null' statement is a no-operation in VHDL
            end case;
        end if;
    end process;

    process(readcontrol, address)
    begin
        case readcontrol is
            when "000" =>  -- Read Byte
                read_data <= std_logic_vector(signed('0' & data_mem_file(to_integer(unsigned(address)))(7 downto 0)));
            when "001" =>  -- Read Halfword
                read_data <= std_logic_vector(signed('0' & data_mem_file(to_integer(unsigned(address)))(15 downto 0)));
            when "010" =>  -- Read Word
                read_data <= data_mem_file(to_integer(unsigned(address)));
            when "100" =>  -- Read Byte Unsigned
                read_data <= (24 => '0') & data_mem_file(to_integer(unsigned(address)))(7 downto 0);
            when "101" =>  -- Read Halfword Unsigned
                read_data <= (16 => '0') & data_mem_file(to_integer(unsigned(address)))(15 downto 0);
            when others =>
                read_data <= (others => '0');
        end case;
    end process;
end Behavioral;
