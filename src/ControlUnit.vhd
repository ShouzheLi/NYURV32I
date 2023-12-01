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
    -- 状态和信号定义
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
    -- 其他信号定义...
    signal instr : std_logic_vector(31 downto 0);
    
    signal alu_zero, alu_overload : STD_LOGIC;
    signal alu_a, alu_b, alu_result : STD_LOGIC_VECTOR(31 downto 0);
    
    signal write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal write_addr : STD_LOGIC_VECTOR(4 downto 0);
    signal reg_write : STD_LOGIC;
    
    -- 信号用于连接数据存储器实例
    signal mem_read_data : STD_LOGIC_VECTOR(31 downto 0);
    
    -- PC 模块实例化
    component ProgramCounter is
        Port (
            pc : out std_logic_vector(31 downto 0);
            clk : in std_logic;
            rst : in std_logic;
            pc_next : in std_logic_vector(31 downto 0)
        );
    end component;
    
    -- 指令内存模块实例化
    component InstructionMemory is
        Port (
            addr : in STD_LOGIC_VECTOR(31 downto 0);
            instr : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- 指令提取模块实例化
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

    -- 实例化数据存储器组件
    component data_memory is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            readcontrol : in STD_LOGIC_VECTOR(2 downto 0);
            writecontrol : in STD_LOGIC_VECTOR(2 downto 0);
            address : in STD_LOGIC_VECTOR(31 downto 0);
            writedata : in STD_LOGIC_VECTOR(31 downto 0);
            read_data : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    -- Define signal types for instruction types and control signals
    type Instruction_Type is record
        R : std_logic;
        Ii : std_logic;
        S : std_logic;
        L : std_logic;
        B : std_logic;
        auipc : std_logic;
        lui : std_logic;
        jal : std_logic;
        jalr : std_logic;
        halt : std_logic;
    end record;

    type Control_Signals_Type is record
        immsrc : std_logic_vector(2 downto 0);
        sel_A : std_logic;
        sel_B : std_logic;
        wb_sel : std_logic_vector(1 downto 0);
        reg_wr : std_logic;
        hlt : std_logic;
    end record;
    
    signal Instruction : Instruction_Type;
    signal Control : Control_Signals_Type;
    
begin
    -- PC 模块实例化
    P_C : ProgramCounter Port Map (
        pc => PC,
        clk => clk,
        rst => rst,
        pc_next => PCNext
    );
    
    -- 指令内存实例化
    InstMem : InstructionMemory Port Map (
        addr => PC,
        instr => instr
    );
    
        -- 实例化指令提取模块
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
            write_addr => write_addr
            -- 如果需要，还需要连接读取端口
    );
    
    -- 实例化数据存储器
    data_mem_instance : data_memory
        port map (
            clk => clk,
            rst => rst,
            readcontrol => readcontrol,
            writecontrol => writecontrol,
            address => aluresult,  -- 假设aluresult是计算出的有效地址
            writedata => srcB,     -- 假设srcB是要写入的数据
            read_data => mem_read_data  -- 读出的数据将被存放在这个信号中
        );

    -- FSM 实现
    process (clk, rst)
    begin
        if rst = '1' then
            -- 重置控制信号
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
        
            -- 重置逻辑
            State <= IFI;
        elsif rising_edge(clk) then
            case State is
                when IFI =>
                    -- 取指逻辑
                    -- ... (从 datapath.v 提取和转换)

                    -- instr 已由指令内存模块提供
                    PCPlus4 <= PC + "00000000000000000000000000000100"; -- 计算 PC + 4

--                    -- 计算下一个 PC 值
--                    if br_taken = '1' then
--                    -- 如果有分支，则更新 PCNext
--                    -- 注意：这里需要根据您的分支逻辑来计算分支目标地址
--                    -- 例如: PCNext <= 分支目标地址;
--                    else
--                        PCNext <= PCPlus4;
--                    end if;

                    -- 更新状态以转移到下一个阶段
                    State <= ID; -- 转到译码阶段
                when ID =>
                    -- 译码逻辑
                    -- ... (从 controller.v 提取和转换)
                    
                    case opcode is
                        when "0010011" =>  -- I-type Arithmetic
                            immsrc <= "001"; -- Immediate source for I-type instructions
                            alu_op <= "0000"; -- ALU operation for ADD
                            reg_wr <= '1'; -- Enable register write
                            sel_A <= '0'; -- Select source A from register
                            sel_B <= '1'; -- Select source B from immediate value
                            wb_sel <= "01"; -- Write-back selection for ALU result
                            -- Other control signals...
                
                        when "0110011" =>  -- R-type Arithmetic
                            immsrc <= "000"; -- No immediate for R-type instructions
                            -- ALU operation based on funct3 and funct7
                            if funct7 = "0100000" and funct3 = "000" then
                                alu_op <= "0001"; -- ALU operation for SUB
                            else
                                alu_op <= "0000"; -- ALU operation for ADD
                            end if;
                            reg_wr <= '1'; -- Enable register write
                            sel_A <= '0'; -- Select source A from register
                            sel_B <= '0'; -- Select source B from register
                            wb_sel <= "00"; -- Write-back selection for ALU result
                            -- Other control signals...
                            
                       when "0000011" =>  -- Load instructions (assuming opcode "3" is for loads)
                            immsrc <= "001"; -- Load instructions use I-type immediates
                            alu_op <= "0000"; -- ALU operation (e.g., ADD for calculating effective address)
                            reg_wr <= '1'; -- Enable register write for loading data into register
                            sel_A <= '0'; -- Select source A from register (base address)
                            sel_B <= '1'; -- Select source B from immediate (offset)
                            wb_sel <= "10"; -- Write-back selection for data from memory
                            readcontrol <= funct3; -- Read control for type of load (byte, halfword, word)
                            writecontrol <= "000"; -- No write operation for load instructions
                            -- Other control signals...
                            br_type <= "000"; -- No branch
                           
                
                        when "0100011" =>  -- Store instructions (assuming opcode "35" is for stores)
                            immsrc <= "010"; -- Store instructions use S-type immediates
                            alu_op <= "0000"; -- ALU operation (e.g., ADD for calculating effective address)
                            reg_wr <= '0'; -- Disable register write for store instructions
                            sel_A <= '0'; -- Select source A from register (base address)
                            sel_B <= '1'; -- Select source B from immediate (offset)
                            wb_sel <= "00"; -- No write-back to registers for store instructions
                            writecontrol <= funct3; -- Write control for type of store (byte, halfword, word)
                            readcontrol <= "000"; -- No read operation for store instructions
                            -- Other control signals...
                            br_type <= "000"; -- No branch
           
                         when "1100011" =>  -- Branch instructions (assuming opcode "99" is for branches)
                            immsrc <= "010"; -- Branch instructions use B-type immediates
                            alu_op <= "0010"; -- ALU operation for SUB to compare registers
                            reg_wr <= '0'; -- No register write for branch instructions
                            sel_A <= '0'; -- Select source A from register
                            sel_B <= '0'; -- Select source B from register
                            br_type <= funct3; -- Branch type based on funct3 (BEQ, BNE, BLT, etc.)
                            wb_sel <= "00"; -- No write-back for branch instructions
                            -- No memory read or write for branch instructions
                            readcontrol <= "000";
                            writecontrol <= "000";
                
                        when "0110111" =>  -- LUI instruction (assuming opcode "55" is for LUI)
                            immsrc <= "011"; -- LUI uses U-type immediate
                            alu_op <= "1010"; -- ALU operation for LUI (simply passing the immediate value)
                            reg_wr <= '1'; -- Enable register write for LUI instruction
                            sel_A <= '0'; -- Not used for LUI
                            sel_B <= '1'; -- Select source B as immediate value
                            wb_sel <= "01"; -- Write-back selection for ALU result (which is immediate for LUI)
                            -- No memory read or write for LUI
                            readcontrol <= "000";
                            writecontrol <= "000";
                            -- No branch for LUI
                            br_type <= "000";
                            
                        when "1101111" =>  -- JAL instruction (assuming opcode "111" is for JAL)
                            immsrc <= "100"; -- JAL uses J-type immediates
                            alu_op <= "1011"; -- ALU operation for JAL (typically just adding offset to PC)
                            reg_wr <= '1'; -- Enable register write for JAL instruction (link register)
                            sel_A <= '0'; -- Select source A from PC
                            sel_B <= '1'; -- Select source B as immediate value
                            wb_sel <= "11"; -- Write-back selection for PC + 4 (return address)
                            -- No memory read or write for JAL
                            readcontrol <= "000";
                            writecontrol <= "000";
                            -- No branch type needed for JAL
                            br_type <= "000";
                
                        when "1100111" =>  -- JALR instruction (assuming opcode "103" is for JALR)
                            immsrc <= "001"; -- JALR uses I-type immediates
                            alu_op <= "1011"; -- ALU operation for JALR (adding offset to register value)
                            reg_wr <= '1'; -- Enable register write for JALR instruction (link register)
                            sel_A <= '0'; -- Select source A from register (base address)
                            sel_B <= '1'; -- Select source B as immediate value
                            wb_sel <= "11"; -- Write-back selection for PC + 4 (return address)
                            -- No memory read or write for JALR
                            readcontrol <= "000";
                            writecontrol <= "000";
                            -- No branch type needed for JALR
                            br_type <= "000";

                            
                        -- 其他指令类型...
                        when others =>
                            -- Default control signals for unrecognized opcode
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
                            -- Optionally set halt signal if invalid opcode
                            -- hlt <= '1';
                    end case;
                    state <= EX;
                when EX =>
                    -- 执行逻辑
                    -- ... (从 datapath.v 提取和转换)
                    -- 根据指令类型选择ALU操作
                    -- 例如，如果指令是加法，则设置ALU的选择信号为加法
--                        alu_op <= "0000"; -- 从译码阶段得到的ALU操作码
                    -- 设置ALU的操作数
                    alu_a <= srcA; -- 可能是寄存器的输出或立即数
                    alu_b <= srcB; -- 可能是寄存器的输出或立即数
                
                    -- 评估分支条件
                    -- 例如，如果指令是分支指令，则设置分支单元的输入并读取其输出
--                        br_taken <= 0; -- 分支单元的输出
                
                    -- 如果指令需要访问内存，则设置内存访问的控制信号
                    -- 如果指令需要写回结果，则设置写回阶段的控制信号
                
                    -- 在执行完必要的操作后，转到下一个状态
                    -- 如果有分支且分支被采纳，则可能需要更新PC值
                    if br_taken = '1' then
                        -- 更新PC值为分支目标地址
                        PC <= PCPlus4;
                    end if;
                
                    -- 根据当前指令的需要，转到下一个阶段
                    state <= MEM; -- 转到内存访问阶段，或者如果指令不需要访问内存，则直接转到写回阶段
                when MEM =>
                    -- Memory access logic
                    if readcontrol /= "000" then
                        -- If readcontrol is not "000", it indicates a read operation.
                        -- The actual reading happens in the data_memory component,
                        -- and the result is available in mem_read_data, which is connected to the read_data output of the data_memory instance.
                        -- Assuming mem_read_data is declared and connected properly, no additional logic is needed here.
                        -- However, if you need to handle the data differently based on the type of read (byte, halfword, word), you would add that logic here.
                    elsif writecontrol /= "000" then
                        -- If writecontrol is not "000", it indicates a write operation.
                        -- The actual writing happens in the data_memory component,
                        -- and the data to be written should be provided to the writedata input of the data_memory instance.
                        -- This value could be the result of the ALU operation or some other data source.
                        -- Since the data_memory instance should already be connected to the appropriate signals, no additional logic is needed here.
                    end if;
                    
                    -- After completing the memory access, move to the next state.
                    state <= WB; -- Go to the Write Back stage.
                when WB =>
                    -- 写回逻辑
                    -- ... (从 datapath.v 提取和转换)
                            -- Write back logic
                    reg_write <= '1';  -- Enable writing to the register file
--                    write_addr <= destination_register;  -- 设置目标寄存器地址
                    -- write_data is already selected by the mux_wb_instance
                    -- ...
            
                    -- 在完成写回操作后，转到下一个状态或重置状态机
                    -- ...
                    state <= IFI;
                when others =>
                    State <= IFI;
            end case;
        end if;
    end process;

    -- 其他逻辑实现
    -- ...

end Behavioral;

