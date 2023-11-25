library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- ���Ƶ�Ԫ��ʵ������
entity ControlUnit is
    Port (
        clk : in STD_LOGIC; -- ʱ���ź�
        rst : in STD_LOGIC; -- ��λ�ź�
        opcode : in STD_LOGIC_VECTOR(5 downto 0); -- ������
        alu_op : out STD_LOGIC_VECTOR(3 downto 0); -- ALU������
        reg_dst : out STD_LOGIC; -- �Ĵ���Ŀ�ĵؿ���
        reg_write : out STD_LOGIC; -- �Ĵ���д����
        alu_src : out STD_LOGIC; -- ALUԴ����
        pc_enable : out STD_LOGIC -- ���������ʹ�ܿ���
    );
end ControlUnit;

-- ���Ƶ�Ԫ����Ϊ����
architecture Behavioral of ControlUnit is
    -- FSM��״̬����
    type State_Type is (FETCH, DECODE, EXECUTE, WRITEBACK);
    signal state : State_Type;

begin
    -- FSM�Ĺ���
    process(clk, rst)
    begin
        if rst = '1' then
            -- �����λ�źű�����
            state <= FETCH; -- ����ΪFETCH״̬
        elsif rising_edge(clk) then
            -- ���ݵ�ǰ״̬�Ͳ�������������һ��״̬
            case state is
                when FETCH =>
                    state <= DECODE; -- ��FETCH״̬ת��DECODE״̬
                when DECODE =>
                    -- ������Ը��ݲ��������ִ��ʲô����
                    case opcode is
                        when "000000" =>
                            state <= EXECUTE; -- ��Ӧĳ���ض�ָ���ִ��
                        -- ��Ӹ���Ĳ�����Ͷ�Ӧ��״̬ת��
                        when others =>
                            state <= FETCH; -- Ĭ�Ϸ���FETCH״̬
                    end case;
                when EXECUTE =>
                    state <= WRITEBACK; -- ��EXECUTE״̬ת��WRITEBACK״̬
                when WRITEBACK =>
                    state <= FETCH; -- ��WRITEBACK״̬����FETCH״̬
                when others =>
                    state <= FETCH; -- Ĭ��״̬
            end case;
        end if;
    end process;

    -- �����źŵ�����
    process(state)
    begin
        -- ���ݵ�ǰ״̬������������źŵ�Ĭ��ֵ
        alu_op <= "0000";
        reg_dst <= '0';
        reg_write <= '0';
        alu_src <= '0';
        pc_enable <= '0';
        
        -- ���ݵ�ǰ״̬�Ͳ��������ɿ����ź�
        case state is
            when FETCH =>
                pc_enable <= '1'; -- ��FETCH״̬ʹ��PC
            when DECODE =>
                -- ��DECODE״̬���ݲ��������ÿ����ź�
                case opcode is
                    when "000000" =>
                        -- ��Ӧĳ���ض�ָ��
                        alu_src <= '1';
                        alu_op <= "0010"; -- ����ALUִ�мӷ�����
                    -- ��Ӹ���Ĳ�����Ͷ�Ӧ�Ŀ����ź�����
                    when others =>
                        -- Ĭ������µĿ����ź�����
                end case;
            when EXECUTE =>
                -- ��EXECUTE״̬���ÿ����ź�
            when WRITEBACK =>
                reg_write <= '1'; -- ��WRITEBACK״̬ʹ�ܼĴ���д����
            when others =>
                -- Ĭ������µĿ����ź�����
        end case;
    end process;
end Behavioral;
