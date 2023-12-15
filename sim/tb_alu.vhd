
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

entity alu_tb is
--  Port ( );
end alu_tb;

architecture Behavioral of alu_tb is

-- initialize the declared signal for testing
    signal clk : STD_LOGIC;
    signal alu_sel_tb : STD_LOGIC_VECTOR (3 downto 0);
    signal a_tb : STD_LOGIC_VECTOR (31 downto 0); 
    signal b_tb : STD_LOGIC_VECTOR (31 downto 0); 
    signal alu_result_tb : STD_LOGIC_VECTOR (31 downto 0);
    signal zero_tb, overload_tb : STD_LOGIC;
    
    constant period : time := 20ns;
    
    component alu
        port(
            alu_sel : in STD_LOGIC_VECTOR (3 downto 0); 
            a : in STD_LOGIC_VECTOR (31 downto 0); 
            b : in STD_LOGIC_VECTOR (31 downto 0); 
            alu_result : out STD_LOGIC_VECTOR (31 downto 0); 
            zero : out STD_LOGIC ;
            overload : out STD_LOGIC
        );
    end component;
    

begin
    
    -- generate the clock...
    clk_gen: process
        begin
           loop
               clk <= '0';
           wait for period / 2;
           clk <= '1';
           wait for period / 2;
           end loop;
    end process;
    
    Testalu : 
        ALU port map(
            alu_sel => alu_sel_tb,
            a => a_tb,
            b => b_tb,
            alu_result => alu_result_tb,
            zero => zero_tb,
            overload => overload_tb
        );
        
    process 
    begin
        
        
--add
        a_tb <= X"00000001";
        b_tb <= X"00000002";
        alu_sel_tb <= "0000";
        wait for 40ns;
        assert (alu_result_tb /= X"00000003") report ("add failed") severity error;
        
        a_tb <= X"F0000000";
        b_tb <= X"10000000";
        wait for 40ns;
        assert (overload_tb /= '1') report ("add overload failed") severity error;
        
--sub
        alu_sel_tb <= "0001";
        wait for 40ns;
        assert (alu_result_tb /= X"E0000000") report ("sub failed") severity error;
        
        a_tb <= X"00000001";
        b_tb <= X"00000002";
        wait for 40ns;
        assert (overload_tb /= '1') report ("sub overload failed") severity error; 
        
--sll(shift left logical)
        a_tb <= X"00000001";
        b_tb <= X"00000002";
        alu_sel_tb <= "0010";
        wait for 40ns;
        assert (alu_result_tb /= X"00000100") report ("sll failed") severity error;
   
--slt(set less than)
        a_tb <= X"00000001";
        b_tb <= X"00000002";
        alu_sel_tb <= "0011";
        wait for 40ns;
        assert (alu_result_tb(0) /= '1') report ("slt failed") severity error;
        
        a_tb <= X"00000002";
        b_tb <= X"00000001";
        alu_sel_tb <= "0011";
        wait for 40ns;
        assert (alu_result_tb(0) /= '0') report ("slt failed") severity error;
        
--sltu(set less than signed)
        a_tb <= X"FFFFFFFE"; --  -1 in 2's complement
        b_tb <= X"00000001"; -- +1
        alu_sel_tb <= "0100";
        wait for 40ns;
        assert (alu_result_tb(0) /= '1') report ("sltu failed") severity error;
       
--xor
        a_tb <= X"0000000A";
        b_tb <= X"00000005";
        alu_sel_tb <= "0101";
        wait for 40ns;
        assert (alu_result_tb /= X"0000000F") report ("xor failed") severity error;
    
--srl(shift right logical)
        a_tb <= X"10000000";
        b_tb <= X"00000001";
        alu_sel_tb <= "0110";
        wait for 40ns;
        assert (alu_result_tb /= X"01000000") report ("srl failed") severity error;
    
--sra(shift right arithmetric)
        a_tb <= X"10000000";
        b_tb <= X"00000001";
        alu_sel_tb <= "0111";
        wait for 40ns;
        assert (alu_result_tb /= X"01000000") report ("sra failed") severity error;
    
--or
        alu_sel_tb <= "1000";
        wait for 40ns;
        assert (alu_result_tb /= X"10000001") report ("or failed") severity error;
        
--and
        a_tb <= X"11000000";
        b_tb <= X"01000001";
        alu_sel_tb <= "1001";
        wait for 40ns;
        assert (alu_result_tb /= X"01000000") report ("and failed") severity error;
        
        
--zero
        a_tb <= X"00000001";
        b_tb <= X"00000001";
        alu_sel_tb <= "0001";
        assert (zero_tb /= '0') report ("zero failed") severity error;
         
    end process;
    
end Behavioral;
