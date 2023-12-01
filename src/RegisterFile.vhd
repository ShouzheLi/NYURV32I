library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
    Port (
        clk : in STD_LOGIC;
        we3 : in STD_LOGIC;
        rst : in STD_LOGIC;
        a1 : in STD_LOGIC_VECTOR(4 downto 0);
        a2 : in STD_LOGIC_VECTOR(4 downto 0);
        a3 : in STD_LOGIC_VECTOR(4 downto 0);
        wd3 : in STD_LOGIC_VECTOR(31 downto 0);
        rd1 : out STD_LOGIC_VECTOR(31 downto 0);
        rd2 : out STD_LOGIC_VECTOR(31 downto 0)
    );
end register_file;

architecture Behavioral of register_file is
    type reg_file_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal reg_file : reg_file_array := (others => (others => '0'));

begin
    -- Write process
    process(clk, rst)
    begin
        if rising_edge(rst) then
            for i in 0 to 31 loop
                reg_file(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk) then
            if we3 = '1' and a3 /= "00000" then -- Writing wd3 to a3 only if a3 is not zero as reg 0 is hardwired to 0
                reg_file(to_integer(unsigned(a3))) <= wd3;
            end if;
        end if;
    end process;
    
    -- Read process
    rd1 <= reg_file(to_integer(unsigned(a1)));
    rd2 <= reg_file(to_integer(unsigned(a2)));

end Behavioral;
