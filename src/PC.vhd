library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- �����������ʵ������
entity ProgramCounter is
    Port (
        clk : in STD_LOGIC; -- ʱ���ź�
        rst : in STD_LOGIC; -- ��λ�ź�
        pc_out : out STD_LOGIC_VECTOR(31 downto 0); -- PC����ź�
        pc_enable : in STD_LOGIC -- PCʹ���ź�
    );
end ProgramCounter;

-- �������������Ϊ����
architecture Behavioral of ProgramCounter is
    -- PC�ڲ��ź�
    signal pc : STD_LOGIC_VECTOR(31 downto 0) := x"01000000"; -- ��ʼ����Ϊָ������ʼ��ַ
begin
    -- ʱ���źŵĴ������
    process(clk, rst)
    begin
        -- �����λ�źű�����
        if rst = '1' then
            pc <= x"01000000"; -- PC����Ϊ��ʼ��ַ
        -- ���ʱ���źŵ������ص���
        elsif rising_edge(clk) then
            -- ���PCʹ���ź�Ϊ����״̬
            if pc_enable = '1' then
                -- ��PCֵ�Զ�����4���ٶ�ָ���СΪ4�ֽ�
                pc <= std_logic_vector(unsigned(pc) + 4);
            end if;
        end if;
    end process;

    -- ���ڲ�PC�źŵĵ�ǰֵ���
    pc_out <= pc;
end Behavioral;
