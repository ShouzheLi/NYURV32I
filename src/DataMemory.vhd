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
    constant BASE_ADDRESS : std_logic_vector(31 downto 0) := x"80000000";
    type data_mem_array is array (0 to 1023) of STD_LOGIC_VECTOR(31 downto 0); -- 4KBytes with 32-bit width
    signal data_mem_file : data_mem_array := (others => (others => '0'));
    signal store_intermediate : STD_LOGIC_VECTOR(31 downto 0);
    -- Memory-mapped values
    constant GROUP_NUM_1 : STD_LOGIC_VECTOR(31 downto 0) := x"16198602";
    constant GROUP_NUM_2 : STD_LOGIC_VECTOR(31 downto 0) := x"15189634";
    constant GROUP_NUM_3 : STD_LOGIC_VECTOR(31 downto 0) := x"15991202";
begin
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset the data memory to zero
            for i in 0 to data_mem_file'high loop
                data_mem_file(i) <= (others => '0');
            end loop;
            store_intermediate <= (others => '0');
        elsif rising_edge(clk) then
            -- Write operations
            case writecontrol is
                when "000" =>  -- Store Byte
                    store_intermediate(7 downto 0) <= writedata(7 downto 0);
                    -- Handle writes only if the address is within the data memory range
                    if unsigned(address) >= unsigned(BASE_ADDRESS) then
                        data_mem_file(to_integer(unsigned(address) - unsigned(BASE_ADDRESS)) / 4)(7 downto 0) <= store_intermediate(7 downto 0);
                    end if;
                when "001" =>  -- Store Halfword
                    store_intermediate(15 downto 0) <= writedata(15 downto 0);
                    if unsigned(address) >= unsigned(BASE_ADDRESS) then
                        data_mem_file(to_integer(unsigned(address) - unsigned(BASE_ADDRESS)) / 4)(15 downto 0) <= store_intermediate(15 downto 0);
                    end if;
                when "010" =>  -- Store Word
                    if unsigned(address) >= unsigned(BASE_ADDRESS) then
                        data_mem_file(to_integer(unsigned(address) - unsigned(BASE_ADDRESS)) / 4) <= writedata;
                    end if;
                when others =>  -- Retain current value
                    null; -- 'null' statement is a no-operation in VHDL
            end case;
        end if;
    end process;

    -- Read operations with special memory-mapped values
    process(readcontrol, address)
    variable index : integer;
    begin
        index := to_integer(unsigned(address) - unsigned(BASE_ADDRESS)) / 4;
        -- Special memory-mapped addresses
        if address = x"00100000" then
            read_data <= GROUP_NUM_1;
        elsif address = x"00100004" then
            read_data <= GROUP_NUM_2;
        elsif address = x"00100008" then
            read_data <= GROUP_NUM_3;
        elsif index >= 0 and index < data_mem_file'length then
            -- Standard memory read
            case readcontrol is
                when "000" =>  -- Read Byte
                    read_data <= (23 downto 0 => '0') & data_mem_file(index)(7 downto 0);
                when "001" =>  -- Read Halfword
                    read_data <= (15 downto 0 => '0') & data_mem_file(index)(15 downto 0);
                when "010" =>  -- Read Word
                    read_data <= data_mem_file(index);
                when others =>
                    read_data <= (others => '0'); -- Default case for other read controls
            end case;
        else
            read_data <= (others => '0'); -- Address out of range
        end if;
    end process;
end Behavioral;
