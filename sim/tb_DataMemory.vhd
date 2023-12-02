


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data_memory_tb is
--  Port ( );
end data_memory_tb;

architecture Behavioral of data_memory_tb is

-- initialize the declared signal for testing
    signal clk_tb, rst_tb : STD_LOGIC;
    signal readcontrol_tb, writecontrol_tb : STD_LOGIC_VECTOR (2 downto 0);
    signal address_tb, writedata_tb, read_data_tb : STD_LOGIC_VECTOR (31 downto 0); 
    
    
    constant period : time := 20ns;
    
    component data_memory
        port(
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            readcontrol : in STD_LOGIC_VECTOR(2 downto 0);
            writecontrol : in STD_LOGIC_VECTOR(2 downto 0);
            address : in STD_LOGIC_VECTOR(31 downto 0);
            writedata : in STD_LOGIC_VECTOR(31 downto 0);
            read_data : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    

begin
    
    -- generate the clock...
    clk_gen: process
        begin
           loop
               clk_tb <= '0';
           wait for period / 2;
               clk_tb <= '1';
           wait for period / 2;
           end loop;
    end process;
    
    TestDataMemory : 
        data_memory port map(
            clk => clk_tb,
            rst => rst_tb,
            readcontrol => readcontrol_tb,
            writecontrol => writecontrol_tb,
            address => address_tb,
            writedata => writedata_tb,
            read_data => read_data_tb
        );
        
    process 
    begin
        
        
--reset
        rst_tb <= '1';
        wait for 20ns;
        rst_tb <= '0';
        
        writecontrol_tb <= "010";
        writedata_tb <= x"11111111";
        address_tb <= x"8000000C"; -- store in file(3)
        wait for 60ns;
        
        readcontrol_tb <= "000";
        address_tb <= x"8000000C"; 
        wait for 100ns;
        
         
    end process;
    
end Behavioral;
