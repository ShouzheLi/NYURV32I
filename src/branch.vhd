library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity branch_determining_unit is
    Port (
        a : in STD_LOGIC_VECTOR(31 downto 0);
        b : in STD_LOGIC_VECTOR(31 downto 0);
        branch_type : in STD_LOGIC_VECTOR(2 downto 0);
        branch_taken : out STD_LOGIC
    );
end entity branch_determining_unit;

architecture Behavioral of branch_determining_unit is
begin
    process(a, b, branch_type)
    begin
        case branch_type is
            when "000" =>  -- beq
                if a = b then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;

            when "001" =>  -- bne
                if a /= b then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;

            when "010" =>  -- no jump
                branch_taken <= '0';

            when "011" =>  -- jal and jalr instruction
                branch_taken <= '1';

            when "100" =>  -- blt
                if signed(a) < signed(b) then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;

            when "101" =>  -- bge
                if signed(a) >= signed(b) then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;

            when "110" =>  -- bltu
                if unsigned(a) < unsigned(b) then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;

            when "111" =>  -- bgeu
                if unsigned(a) >= unsigned(b) then
                    branch_taken <= '1';
                else
                    branch_taken <= '0';
                end if;

            when others =>
                branch_taken <= '0';
        end case;
    end process;
end Behavioral;
