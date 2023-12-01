library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Correct library for signed operations

entity sign_extend is
    Port (
        instr : in STD_LOGIC_VECTOR(31 downto 7); -- Instruction bits input
        immsrc : in STD_LOGIC_VECTOR(2 downto 0); -- Immediate source type
        immext : out STD_LOGIC_VECTOR(31 downto 0) -- Extended immediate output
    );
end sign_extend;

architecture Behavioral of sign_extend is
begin
    process(instr, immsrc)
    begin
        case immsrc is
            when "000" =>  -- I-type
                immext <= std_logic_vector(signed('0' & instr(31 downto 20)));
            when "001" =>  -- S-type (stores)
                immext <= std_logic_vector(signed('0' & instr(31 downto 25) & instr(11 downto 7)));
            when "010" =>  -- B-type (branches)
                immext <= std_logic_vector(signed('0' & instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'));
            when "011" =>  -- U-type
                immext <= std_logic_vector(signed(instr(31 downto 12)) & "000000000000");
            when "100" =>  -- J-type
                immext <= std_logic_vector(signed('0' & instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'));
            when others =>
                immext <= (others => '0');  -- undefined
        end case;
    end process;
end Behavioral;
