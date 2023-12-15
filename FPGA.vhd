library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- New entity that uses the Control_Unit
entity FPGA is
    Port (
        --inputs
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        --output
        FinalResult : out STD_LOGIC_VECTOR(15 downto 0)
    );
end FPGA;

architecture Behavioral of FPGA is

    -- Signal to capture the Result from Control_Unit
    signal Result_Value : STD_LOGIC_VECTOR(31 downto 0);
    signal Result_Value_Use : STD_LOGIC_VECTOR(31 downto 0);
    --signal hlt_Value : STD_LOGIC;
    --signal zero_Value : STD_LOGIC;
    --signal overload_Value : STD_LOGIC;
    
    -- Elements for slowclock
    signal slow_clock : STD_LOGIC := '0';
    signal counter : integer := 0;
    
    -- Component declaration for Control_Unit
    component Control_Unit is
        Port (
            --hlt : out STD_LOGIC;
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            Result : out STD_LOGIC_VECTOR(31 downto 0)
            --zero : out STD_LOGIC;
            --overload : out STD_LOGIC
        );
    end component;
    
begin

    -- Instantiation of Control_Unit
    ControlUnit_Instance : Control_Unit
        Port Map (
            clk => slow_clock,
            rst => rst,
            --hlt => hlt_Value,
            Result => Result_Value_Use
            --zero => zero_Value,
            --overload => overload_Value
        );
        
    --slow clock
    process(clk)
    begin
        if rising_edge(clk) then
        --50000000
            if counter = 50000000 then
                slow_clock <= '1';
                counter <= 0;  -- Reset counter
            else 
                slow_clock <= '0';
                counter <= counter + 1;  -- Increment counter
            end if;     
        end if; 
    end process;

-- Set Result to 16 bits

-- LEDs Logic
    process(clk, rst)
    begin
        if rst = '1' then  -- Asynchronous active-low reset
            Result_Value <= (others => '1'); -- Set all bits to '1'
        else
            --if slow_clock = '1' then
                Result_Value <= Result_Value_Use; -- Decrement Result_Value when slow_clock is '1'
            --end if;
        end if;
    end process;

    
    FinalResult <= std_logic_vector(Result_Value(15 downto 0));


end Behavioral;
