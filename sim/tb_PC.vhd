----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/11/29 23:21:07
-- Design Name: 
-- Module Name: tb_alu - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PC_tb is
--  Port ( );
end PC_tb;

architecture Behavioral of PC_tb is

-- initialize the declared signal for testing
    signal clk_tb, rst_tb, pc_enable_tb : STD_LOGIC;
    signal pc_out_tb : STD_LOGIC_VECTOR (31 downto 0);
    
    
    constant period : time := 20ns;
    
    component ProgramCounter
        port(
            clk : in STD_LOGIC; -- ??????
            rst : in STD_LOGIC; -- ??λ???
            pc_out : out STD_LOGIC_VECTOR(31 downto 0); -- PC??????
            pc_enable : in STD_LOGIC -- PC????????
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
    
    TestPC : 
        ProgramCounter port map(
            clk => clk_tb,
            rst => rst_tb,
            pc_enable => pc_enable_tb,
            pc_out => pc_out_tb
            
        );
        
    process 
    begin
        --switch on reset, off enable
        rst_tb <= '1';
        pc_enable_tb <= '0';
        wait for 40ns;
        --reset on, enable on
        rst_tb <= '1';
        pc_enable_tb <= '1';
        wait for 40ns;
        --reset off, enable off
        rst_tb <= '0';
        pc_enable_tb <= '0';
        wait for 40ns;
        --reset off, enable on
        rst_tb <= '0';
        pc_enable_tb <= '1';
        wait for 40ns;
        
        
         
    end process;
    
end Behavioral;
