

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegisterFile_tb is
--  Port ( );
end RegisterFile_tb;

architecture Behavioral of RegisterFile_tb is

-- initialize the declared signal for testing
    signal clk_tb, rst_tb, reg_write_en_tb : STD_LOGIC;
    signal write_reg_num_tb, read_reg_num1_tb, read_reg_num2_tb : std_logic_vector(4 downto 0);
    signal write_data_tb, read_data1_tb, read_data2_tb : STD_LOGIC_VECTOR (31 downto 0);
    
    
    constant period : time := 20ns;
    
    component RegisterFile
        port(
            clk : in STD_LOGIC; -- 
            rst : in STD_LOGIC; -- 
            reg_write_en : in STD_LOGIC;
            write_reg_num, read_reg_num1, read_reg_num2 : in STD_LOGIC_VECTOR(4 downto 0);
            write_data : in STD_LOGIC_VECTOR(31 downto 0);
            read_data1, read_data2 : out STD_LOGIC_VECTOR(31 downto 0)
            
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
    
    TestRegisterFile : 
        RegisterFile port map(
            clk => clk_tb,
            rst => rst_tb,
            reg_write_en => reg_write_en_tb,
            write_reg_num => write_reg_num_tb,
            read_reg_num1 => read_reg_num1_tb,
            read_reg_num2 => read_reg_num2_tb,
            write_data => write_data_tb,
            read_data1 => read_data1_tb,
            read_data2 => read_data2_tb
            
        );
        
    process 
    begin
        --initialize the input values
        write_data_tb <= X"00000000";
        write_reg_num_tb <= "00000";
        read_reg_num1_tb <= "00001";
        read_reg_num2_tb <= "00010";
        rst_tb <= '0';
        reg_write_en_tb <= '0';
        wait for 20ns;
        
        --test the reset signal
        reg_write_en_tb <= '1';
        wait for 20ns;
        rst_tb <= '1';
        wait for 20ns;
        
        --test for enable signal
        rst_tb <= '0';
        reg_write_en_tb <= '0';
        wait for 40ns;
      
        --test for register
        reg_write_en_tb <= '1';
        write_data_tb <= X"11111111";
        write_reg_num_tb <= "00001";
        wait for 20ns;
        write_data_tb <= X"22222222";
        write_reg_num_tb <= "00010";
        
        wait for 20ns;
     
        
         
    end process;
    
end Behavioral;
