library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- 程序计数器的实体声明
entity ProgramCounter is
    Port (
        clk : in STD_LOGIC; -- 时钟信号
        rst : in STD_LOGIC; -- 复位信号
        pc_out : out STD_LOGIC_VECTOR(31 downto 0); -- PC输出信号
        pc_enable : in STD_LOGIC -- PC使能信号
    );
end ProgramCounter;

-- 程序计数器的行为描述
architecture Behavioral of ProgramCounter is
    -- PC内部信号
    signal pc : STD_LOGIC_VECTOR(31 downto 0) := x"01000000"; -- 初始设置为指定的起始地址
begin
    -- 时钟信号的处理过程
    process(clk, rst)
    begin
        -- 如果复位信号被激活
        if rst = '1' then
            pc <= x"01000000"; -- PC设置为起始地址
        -- 如果时钟信号的上升沿到来
        elsif rising_edge(clk) then
            -- 如果PC使能信号为激活状态
            if pc_enable = '1' then
                -- 将PC值自动递增4，假定指令大小为4字节
                pc <= std_logic_vector(unsigned(pc) + 4);
            end if;
        end if;
    end process;

    -- 将内部PC信号的当前值输出
    pc_out <= pc;
end Behavioral;
