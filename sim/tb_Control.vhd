LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY Control_Unit_tb IS
END Control_Unit_tb;

ARCHITECTURE behavior OF Control_Unit_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT Control_Unit
    PORT(
         hlt : OUT  std_logic;
         rst : IN  std_logic;
         clk : IN  std_logic
    );
    END COMPONENT;
   
    --Inputs
    signal rst : std_logic := '0';
    signal clk : std_logic := '0';

    --Outputs
    signal hlt : std_logic;

    -- Clock period definitions
    constant clk_period : time := 10 ns;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
   uut: Control_Unit PORT MAP (
          hlt => hlt,
          rst => rst,
          clk => clk
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin       
        -- hold reset state for 100 ns.
        wait for 100 ns;  
        rst <= '1';
        wait for clk_period*10;
        
        -- release reset
        rst <= '0';
        wait for clk_period*10;
        
        -- Check for pass/fail condition
        if hlt = '1' then
            report "Test fail: hlt signal is asserted unexpectedly." severity error;
        else
            report "Test pass: hlt signal is not asserted, as expected." severity note;
        end if;

        -- End the simulation
        assert FALSE report "End of simulation" severity note;
        wait;
    end process;

END;
