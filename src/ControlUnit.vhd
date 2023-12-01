library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control_Unit is
    Port (
--        immsrc : out STD_LOGIC_VECTOR(2 downto 0);
--        alu_op : out STD_LOGIC_VECTOR(3 downto 0);
--        br_type : out STD_LOGIC_VECTOR(2 downto 0);
--        readcontrol : out STD_LOGIC_VECTOR(2 downto 0);
--        writecontrol : out STD_LOGIC_VECTOR(2 downto 0);
--        reg_wr : out STD_LOGIC;
--        sel_A : out STD_LOGIC;
--        sel_B : out STD_LOGIC;
        hlt : out STD_LOGIC;
--        wb_sel : out STD_LOGIC_VECTOR(1 downto 0);
--        opcode : in STD_LOGIC_VECTOR(6 downto 0);
--        funct3 : in STD_LOGIC_VECTOR(2 downto 0);
--        funct7 : in STD_LOGIC_VECTOR(6 downto 0);
        rst : in STD_LOGIC;
        clk : in STD_LOGIC
    );


end Control_Unit;

architecture Behavioral of Control_Unit is
    -- ״̬���źŶ���
    type State_Type is (IFI, ID, EX, MEM, WB);
    signal State : State_Type;
    signal PC, PCNext, PCPlus4, immext, srcA, rd1, rd2, srcB, rdata, aluresult : std_logic_vector(31 downto 0);
    signal opcode : std_logic_vector(6 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
    signal br_taken, reg_wr, sel_A, sel_B : std_logic;
    signal immsrc, br_type, readcontrol, writecontrol : std_logic_vector(2 downto 0);
    signal wb_sel : std_logic_vector(1 downto 0);
    signal alu_op : std_logic_vector(3 downto 0);
    -- �����źŶ���...
    signal instr : std_logic_vector(31 downto 0);
    
    signal alu_zero, alu_overload : STD_LOGIC;
    signal alu_a, alu_b, alu_result : STD_LOGIC_VECTOR(31 downto 0);
    
    signal write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal write_addr : STD_LOGIC_VECTOR(4 downto 0);
    signal reg_write : STD_LOGIC;
    
    -- PC ģ��ʵ����
    component ProgramCounter is
        Port (
            pc : out std_logic_vector(31 downto 0);
            clk : in std_logic;
            rst : in std_logic;
            pc_next : in std_logic_vector(31 downto 0)
        );
    end component;
    
    -- ָ���ڴ�ģ��ʵ����
    component InstructionMemory is
        Port (
            addr : in STD_LOGIC_VECTOR(31 downto 0);
            instr : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- ָ����ȡģ��ʵ����
    component instruction_fetch is
        Port (
            instr : in std_logic_vector(31 downto 0);
            opcode : out std_logic_vector(6 downto 0);
            rd : out std_logic_vector(4 downto 0);
            funct3 : out std_logic_vector(2 downto 0);
            rs1 : out std_logic_vector(4 downto 0);
            rs2 : out std_logic_vector(4 downto 0);
            funct7 : out std_logic_vector(6 downto 0);
            imm : out std_logic_vector(24 downto 0)
        );
    end component;
    
    -- ALU component declaration
    component alu is
        Port (
            a : in STD_LOGIC_VECTOR(31 downto 0);
            b : in STD_LOGIC_VECTOR(31 downto 0);
            alu_sel : in STD_LOGIC_VECTOR(3 downto 0);
            alu_result : out STD_LOGIC_VECTOR(31 downto 0);
            zero : out STD_LOGIC;
            overload : out STD_LOGIC
        );
    end component;
    
    -- Branch determining unit component declaration
    component branch_determining_unit is
        Port (
            a : in STD_LOGIC_VECTOR(31 downto 0);
            b : in STD_LOGIC_VECTOR(31 downto 0);
            branch_type : in STD_LOGIC_VECTOR(2 downto 0);
            branch_taken : out STD_LOGIC
        );
    end component;
    
    component register_file is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        reg_write : in STD_LOGIC;
        write_data : in STD_LOGIC_VECTOR(31 downto 0);
        write_addr : in STD_LOGIC_VECTOR(4 downto 0);
        read_data1 : out STD_LOGIC_VECTOR(31 downto 0);
        read_data2 : out STD_LOGIC_VECTOR(31 downto 0)
    );
end component;
    
begin
    -- PC ģ��ʵ����
    P_C : ProgramCounter Port Map (
        pc => PC,
        clk => clk,
        rst => rst,
        pc_next => PCNext
    );
    
    -- ָ���ڴ�ʵ����
    InstMem : InstructionMemory Port Map (
        addr => PC,
        instr => instr
    );
    
        -- ʵ����ָ����ȡģ��
    InstFetch: instruction_fetch Port Map (
        instr => instr,
        opcode => opcode,
        rd => rdata,
        funct3 => funct3,
        rs1 => rd1,
        rs2 => rd2,
        funct7 => funct7,
        imm => immsrc
    );
    
        -- Instance of ALU
    alu_instance : alu
        Port Map (
            a => alu_a,
            b => alu_b,
            alu_sel => alu_op,
            alu_result => alu_result,
            zero => alu_zero,
            overload => alu_overload
        );
    
    -- Instance of Branch Determining Unit
    branch_unit_instance : branch_determining_unit
        Port Map (
            a => srcA,
            b => srcB,
            branch_type => br_type,
            branch_taken => br_taken
        );
        
    
    -- Instance of Register File for write back operation
    reg_file_instance : register_file
        Port Map (
            clk => clk,
            rst => rst,
            reg_write => reg_write,
            write_data => write_data,
            write_addr => write_addr,
            -- �����Ҫ������Ҫ���Ӷ�ȡ�˿�
        );

    -- FSM ʵ��
    process (clk, rst)
    begin
        if rst = '1' then
            -- ���ÿ����ź�
            immsrc <= (others => '0');
            alu_op <= (others => '0');
            br_type <= (others => '0');
            readcontrol <= (others => '0');
            writecontrol <= (others => '0');
            reg_wr <= '0';
            sel_A <= '0';
            sel_B <= '0';
            hlt <= '0';
            wb_sel <= (others => '0');
        
            -- �����߼�
            State <= IFI;
        elsif rising_edge(clk) then
            case State is
                when IFI =>
                    -- ȡָ�߼�
                    -- ... (�� datapath.v ��ȡ��ת��)

                    -- instr ����ָ���ڴ�ģ���ṩ
                    PCPlus4 <= PC + "00000000000000000000000000000100"; -- ���� PC + 4

--                    -- ������һ�� PC ֵ
--                    if br_taken = '1' then
--                    -- ����з�֧������� PCNext
--                    -- ע�⣺������Ҫ�������ķ�֧�߼��������֧Ŀ���ַ
--                    -- ����: PCNext <= ��֧Ŀ���ַ;
--                    else
--                        PCNext <= PCPlus4;
--                    end if;

                    -- ����״̬��ת�Ƶ���һ���׶�
                    State <= ID; -- ת������׶�
                when ID =>
                    -- �����߼�
                    -- ... (�� controller.v ��ȡ��ת��)
                    
                    case opcode is
                        when "0010011" =>  -- I-type Arithmetic
                            immsrc <= "001"; -- ������Դ
                            alu_op <= "0000"; -- ALU ���������磺ADD��
                            reg_wr <= '1'; -- �Ĵ���д��
                            sel_A <= '0'; -- ѡ�� A Դ
                            sel_B <= '1'; -- ѡ�� B Դ����������
                            wb_sel <= "01"; -- д��ѡ��
                            -- ���������ź�...
                
                        when "0110011" =>  -- R-type Arithmetic
                            immsrc <= "000"; -- ������Դ
                            -- ALU �������� funct3 �� funct7
                            if funct7 = "0100000" and funct3 = "000" then
                                alu_op <= "0001"; -- ���磺SUB
                            else
                                alu_op <= "0000"; -- ���磺ADD
                            end if;
                            reg_wr <= '1'; -- �Ĵ���д��
                            sel_A <= '0'; -- ѡ�� A Դ
                            sel_B <= '0'; -- ѡ�� B Դ���Ĵ�����
                            wb_sel <= "00"; -- д��ѡ��
                            -- ���������ź�...
                
                        -- ����ָ������...
                        when others =>
                            -- Ĭ�Ͽ����ź�
                            immsrc <= (others => '0');
                            alu_op <= (others => '0');
                            br_type <= (others => '0');
                            readcontrol <= (others => '0');
                            writecontrol <= (others => '0');
                            reg_wr <= '0';
                            sel_A <= '0';
                            sel_B <= '0';
                            hlt <= '0';
                            wb_sel <= (others => '0');
                    end case;
                    state <= EX;
                when EX =>
                    -- ִ���߼�
                    -- ... (�� datapath.v ��ȡ��ת��)
                        -- ����ָ������ѡ��ALU����
                        -- ���磬���ָ���Ǽӷ���������ALU��ѡ���ź�Ϊ�ӷ�
                        alu_op <= 0; -- ������׶εõ���ALU������
                        -- ����ALU�Ĳ�����
                        alu_a <= srcA; -- �����ǼĴ����������������
                        alu_b <= srcB; -- �����ǼĴ����������������
                    
                        -- ������֧����
                        -- ���磬���ָ���Ƿ�ָ֧������÷�֧��Ԫ�����벢��ȡ�����
                        br_taken <= 0; -- ��֧��Ԫ�����
                    
                        -- ���ָ����Ҫ�����ڴ棬�������ڴ���ʵĿ����ź�
                        -- ���ָ����Ҫд�ؽ����������д�ؽ׶εĿ����ź�
                    
                        -- ��ִ�����Ҫ�Ĳ�����ת����һ��״̬
                        -- ����з�֧�ҷ�֧�����ɣ��������Ҫ����PCֵ
                        if br_taken = '1' then
                            -- ����PCֵΪ��֧Ŀ���ַ
                            PC <= 0;
                        end if;
                    
                        -- ���ݵ�ǰָ�����Ҫ��ת����һ���׶�
                        state <= MEM; -- ת���ڴ���ʽ׶Σ��������ָ���Ҫ�����ڴ棬��ֱ��ת��д�ؽ׶�
                when MEM =>
                    -- �洢�������߼�
                    -- ... (�� datapath.v ��ȡ��ת��)
                        -- �洢�������߼�
                    if readcontrol /= "000" then
                        -- ���� readcontrol �źţ������ݴ洢����ȡ����
                        -- ����ȡ�����ݷ����һ���ڲ��źţ��Ա���д�ؽ׶�ʹ��
                    elsif writecontrol /= "000" then
                        -- ���� writecontrol �źţ�������д�����ݴ洢��
                        -- д������ݿ�������ALU�Ľ����������Դ
                    end if;
                    
                    -- ����ɴ洢�����ʺ�ת����һ��״̬
                    state <= WB; -- ת��д�ؽ׶�
                when WB =>
                    -- д���߼�
                    -- ... (�� datapath.v ��ȡ��ת��)
                            -- Write back logic
                    reg_write <= '1';  -- Enable writing to the register file
                    write_addr <= destination_register;  -- ����Ŀ��Ĵ�����ַ
                    -- write_data is already selected by the mux_wb_instance
                    -- ...
            
                    -- �����д�ز�����ת����һ��״̬������״̬��
                    -- ...
                    state <= IFI;
                when others =>
                    State <= IFI;
            end case;
        end if;
    end process;

    -- �����߼�ʵ��
    -- ...

end Behavioral;

