library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port (
        a : in STD_LOGIC_VECTOR(31 downto 0);
        b : in STD_LOGIC_VECTOR(31 downto 0);
        alu_sel : in STD_LOGIC_VECTOR(3 downto 0);
        alu_result : out STD_LOGIC_VECTOR(31 downto 0);
        zero : out STD_LOGIC;
        overload : out STD_LOGIC
    );
end entity alu;

architecture Behavioral of alu is
    signal temp_result : STD_LOGIC_VECTOR(31 downto 0); -- Internal signal for ALU result
    signal temp_a, temp_b : SIGNED(31 downto 0); -- Internal signals for operands
begin
    -- Assign internal signals for signed operations
    temp_a <= signed(a);
    temp_b <= signed(b);

    process(a, b, alu_sel)
    begin
        -- Default output
        temp_result <= (others => '0');
        overload <= '0';
        zero <= '0';

        case alu_sel is
            when "0000" =>  -- ADD
                temp_result <= std_logic_vector(temp_a + temp_b);
                -- Check for overflow
                if temp_a(31) = temp_b(31) and temp_result(31) /= temp_a(31) then
                    overload <= '1';
                end if;

            when "0001" =>  -- SUB
                temp_result <= std_logic_vector(temp_a - temp_b);
                -- Check for overflow
                if temp_a(31) /= temp_b(31) and temp_result(31) /= temp_a(31) then
                    overload <= '1';
                end if;

            when "0010" =>  -- SLL (Shift Left Logical)
                temp_result <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b(4 downto 0)))));
                overload <= '0';  -- Shift operations do not cause overflow
            
            when "0011" =>  -- SLT (Set Less Than)
                temp_result <= std_logic_vector(to_unsigned(0, 32));
                if temp_a < temp_b then
                    temp_result(0) <= '1';
                else 
                    temp_result(0) <= '0';
                end if;
                overload <= '0';  -- Comparison does not cause overflow
            
            when "0100" =>  -- SLTU (Set Less Than Signed)
                temp_result <= std_logic_vector(to_unsigned(0, 32));
                if unsigned(a) < unsigned(b) then
                    temp_result(0) <= '1';
                else 
                    temp_result(0) <= '0';
                end if;
                overload <= '0';  -- Comparison does not cause overflow
            
            when "0101" =>  -- XOR
                temp_result <= a xor b;
                overload <= '0';  -- Logical operation does not cause overflow
            
            when "0110" =>  -- SRL (Shift Right Logical)
                temp_result <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0)))));
                overload <= '0';  -- Shift operations do not cause overflow
            
            when "0111" =>  -- SRA (Shift Right Arithmetic)
                temp_result <= std_logic_vector(shift_right(signed(a), to_integer(unsigned(b(4 downto 0)))));
                overload <= '0';  -- Shift operations do not cause overflow
            
            when "1000" =>  -- OR
                temp_result <= a or b;
                overload <= '0';  -- Logical operation does not cause overflow
            
            when "1001" =>  -- AND
                temp_result <= a and b;
                overload <= '0';  -- Logical operation does not cause overflow
            
             when others =>
                 temp_result <= (others => '0');
                 overload <= '0';  -- Default case does not cause overflow
            
            -- Other cases remain the same...

        end case;

        -- Set zero flag
        if temp_result = "00000000000000000000000000000000" then
            zero <= '1';
        else
            zero <= '0';
        end if;
    end process;

    -- Assign the internal result to the output port
    alu_result <= temp_result;
end Behavioral;
