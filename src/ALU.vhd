library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ALU的实体声明
entity ALU is
    Port (
        alu_ctrl : in STD_LOGIC_VECTOR (3 downto 0); -- ALU控制信号
        operand_a : in STD_LOGIC_VECTOR (31 downto 0); -- 操作数A
        operand_b : in STD_LOGIC_VECTOR (31 downto 0); -- 操作数B
        result : out STD_LOGIC_VECTOR (31 downto 0); -- 运算结果
        zero : out STD_LOGIC -- 零标志信号
    );
end ALU;

-- ALU的行为描述
architecture Behavioral of ALU is
begin
    process(alu_ctrl, operand_a, operand_b)
    variable temp_result : STD_LOGIC_VECTOR (31 downto 0);
    variable is_zero : STD_LOGIC;
    begin
        case alu_ctrl is
            when "0000" => -- ADD
                temp_result := std_logic_vector(signed(operand_a) + signed(operand_b));
            when "0001" => -- SUB
                temp_result := std_logic_vector(signed(operand_a) - signed(operand_b));
            when "0010" => -- AND
                temp_result := operand_a and operand_b;
            when "0011" => -- OR
                temp_result := operand_a or operand_b;
            when "0100" => -- XOR
                temp_result := operand_a xor operand_b;
            when "0101" => -- SLL
                temp_result := std_logic_vector(shift_left(unsigned(operand_a), to_integer(unsigned(operand_b(4 downto 0)))));
            when "0110" => -- SRL
                temp_result := std_logic_vector(shift_right(unsigned(operand_a), to_integer(unsigned(operand_b(4 downto 0)))));
            when "0111" => -- SRA
                temp_result := std_logic_vector(shift_right(signed(operand_a), to_integer(unsigned(operand_b(4 downto 0)))));
            -- 请根据指令集继续添加其他运算
            when others =>
                temp_result := (others => '0');
        end case;
        
        -- Check if the result is zero
        is_zero := '1';
        for i in temp_result'range loop
            if temp_result(i) = '1' then
                is_zero := '0';
                exit; -- Exit the loop early if a '1' is found
            end if;
         end loop;
    
        result <= temp_result;
        zero <= is_zero; -- Set the zero flag based on the loop result
    end process;
end Behavioral;
