library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- 控制单元的实体声明
entity ControlUnit is
    Port (
        clk : in STD_LOGIC; -- 时钟信号
        rst : in STD_LOGIC; -- 复位信号
        opcode : in STD_LOGIC_VECTOR(5 downto 0); -- 操作码
        alu_op : out STD_LOGIC_VECTOR(3 downto 0); -- ALU操作码
        reg_dst : out STD_LOGIC; -- 寄存器目的地控制
        reg_write : out STD_LOGIC; -- 寄存器写控制
        alu_src : out STD_LOGIC; -- ALU源控制
        pc_enable : out STD_LOGIC -- 程序计数器使能控制
    );
end ControlUnit;

-- 控制单元的行为描述
architecture Behavioral of ControlUnit is
    -- FSM的状态定义
    type State_Type is (FETCH, DECODE, EXECUTE, WRITEBACK);
    signal state : State_Type;

begin
    -- FSM的过程
    process(clk, rst)
    begin
        if rst = '1' then
            -- 如果复位信号被激活
            state <= FETCH; -- 设置为FETCH状态
        elsif rising_edge(clk) then
            -- 根据当前状态和操作码来决定下一个状态
            case state is
                when FETCH =>
                    state <= DECODE; -- 从FETCH状态转到DECODE状态
                when DECODE =>
                    -- 这里可以根据操作码决定执行什么操作
                    case opcode is
                        when "000000" =>
                            state <= EXECUTE; -- 对应某条特定指令的执行
                        -- 添加更多的操作码和对应的状态转换
                        when others =>
                            state <= FETCH; -- 默认返回FETCH状态
                    end case;
                when EXECUTE =>
                    state <= WRITEBACK; -- 从EXECUTE状态转到WRITEBACK状态
                when WRITEBACK =>
                    state <= FETCH; -- 从WRITEBACK状态返回FETCH状态
                when others =>
                    state <= FETCH; -- 默认状态
            end case;
        end if;
    end process;

    -- 控制信号的生成
    process(state)
    begin
        -- 根据当前状态设置输出控制信号的默认值
        alu_op <= "0000";
        reg_dst <= '0';
        reg_write <= '0';
        alu_src <= '0';
        pc_enable <= '0';
        
        -- 根据当前状态和操作码生成控制信号
        case state is
            when FETCH =>
                pc_enable <= '1'; -- 在FETCH状态使能PC
            when DECODE =>
                -- 在DECODE状态根据操作码设置控制信号
                case opcode is
                    when "000000" =>
                        -- 对应某条特定指令
                        alu_src <= '1';
                        alu_op <= "0010"; -- 例如ALU执行加法操作
                    -- 添加更多的操作码和对应的控制信号设置
                    when others =>
                        -- 默认情况下的控制信号设置
                end case;
            when EXECUTE =>
                -- 在EXECUTE状态设置控制信号
            when WRITEBACK =>
                reg_write <= '1'; -- 在WRITEBACK状态使能寄存器写操作
            when others =>
                -- 默认情况下的控制信号设置
        end case;
    end process;
end Behavioral;
