library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Control_Unit is
    Port (
        -- Uncomment below if these signals are used
        -- immsrc : out STD_LOGIC_VECTOR(2 downto 0);
        -- alu_op : out STD_LOGIC_VECTOR(3 downto 0);
        -- br_type : out STD_LOGIC_VECTOR(2 downto 0);
        -- readcontrol : out STD_LOGIC_VECTOR(2 downto 0);
        -- writecontrol : out STD_LOGIC_VECTOR(2 downto 0);
        -- reg_wr : out STD_LOGIC;
        -- sel_A : out STD_LOGIC;
        -- sel_B : out STD_LOGIC;
        hlt : out STD_LOGIC;  -- Halt signal
        -- wb_sel : out STD_LOGIC_VECTOR(1 downto 0);
        -- opcode : in STD_LOGIC_VECTOR(6 downto 0);
        -- funct3 : in STD_LOGIC_VECTOR(2 downto 0);
        -- funct7 : in STD_LOGIC_VECTOR(6 downto 0);
        rst : in STD_LOGIC;   -- Reset signal
        clk : in STD_LOGIC    -- Clock signal
    );
end Control_Unit;

architecture Behavioral of Control_Unit is
    -- Definition of states and signals
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
    -- Other signal definitions...
    signal instr : std_logic_vector(31 downto 0);

    signal alu_zero, alu_overload : STD_LOGIC;
    signal alu_a, alu_b, alu_result : STD_LOGIC_VECTOR(31 downto 0);

    signal write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal rd1_data : STD_LOGIC_VECTOR(31 downto 0);
    signal rd2_data : STD_LOGIC_VECTOR(31 downto 0);
    signal write_address : STD_LOGIC_VECTOR(31 downto 0);
    signal rd1_address : STD_LOGIC_VECTOR(31 downto 0);
    signal rd2_address : STD_LOGIC_VECTOR(31 downto 0);
    signal reg_write : STD_LOGIC;


    -- Instance declaration of Program Counter
    component ProgramCounter is
        Port (
            pc : out std_logic_vector(31 downto 0);
            clk : in std_logic;
            rst : in std_logic;
            pc_next : in std_logic_vector(31 downto 0)
        );
    end component;

    -- Instance declaration of Instruction Memory
    component InstructionMemory is
        Port (
            addr : in STD_LOGIC_VECTOR(31 downto 0);
            instr : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;

    -- Instance declaration of Instruction Fetch
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
        we3 : in STD_LOGIC;    -- This must match the write enable port in the actual entity
        rst : in STD_LOGIC;
        a1 : in STD_LOGIC_VECTOR(4 downto 0);    -- Read address 1
        a2 : in STD_LOGIC_VECTOR(4 downto 0);    -- Read address 2
        a3 : in STD_LOGIC_VECTOR(4 downto 0);    -- Write address
        wd3 : in STD_LOGIC_VECTOR(31 downto 0);  -- Write data
        rd1 : out STD_LOGIC_VECTOR(31 downto 0); -- Read data 1
        rd2 : out STD_LOGIC_VECTOR(31 downto 0)  -- Read data 2
    );
    end component;
    
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
    -- Instantiation of Program Counter
    P_C : ProgramCounter Port Map (
        pc => PC,
        clk => clk,
        rst => rst,
        pc_next => PCNext
    );

    -- Instantiation of Instruction Memory
    InstMem : InstructionMemory Port Map (
        addr => PC,
        instr => instr
    );

    -- Inside your architecture, where you are mapping the instruction_fetch component
    InstFetch: instruction_fetch Port Map (
        instr => instr,
        opcode => instr(6 downto 0),               -- The opcode field is typically the first 7 bits
        rd => instr(11 downto 7),                  -- The rd field is typically 5 bits
        funct3 => instr(14 downto 12),             -- The funct3 field is typically 3 bits
        rs1 => instr(19 downto 15),                -- The rs1 field is typically 5 bits
        rs2 => instr(24 downto 20),                -- The rs2 field is typically 5 bits
        funct7 => instr(31 downto 25),             -- The funct7 field is typically 7 bits
        imm => instr(31 downto 7)                  -- Adjust the imm field according to your design needs
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
    -- Instance of Register File for write back operation
    reg_file_instance : register_file
        Port Map (
            clk => clk,
            we3 => reg_write,    -- reg_write signal in ControlUnit must connect to we3 in register_file
            rst => rst,
            a1 => rd1_address(4 downto 0),   -- Make sure these signals exist in your ControlUnit architecture
            a2 => rd2_address(4 downto 0),
            a3 => write_address(4 downto 0),
            wd3 => write_data,
            rd1 => rd1_data,     -- Make sure these signals exist in your ControlUnit architecture
            rd2 => rd2_data
        );
    
    -- Instance of Register File for write back operation
    data_memory_instance : data_memory
        Port Map (
            clk => clk,
            rst => rst,
            readcontrol => readcontrol,
            writecontrol => writecontrol,
            address => write_address,
            writedata => write_data,
            read_data => rdata
        );

    -- FSM implementation
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
                    -- Index Logic

                    -- instr already provided by PC
                    PCPlus4 <= PC + "00000000000000000000000000000100"; -- 计算 PC + 4

                    -- count next PC


                    -- Next State
                    State <= ID; 
                when ID =>
                    -- Instruction Decode 
                    
                    case opcode is
                        when "0010011" =>  -- I-type Arithmetic
                            immsrc <= "001"; -- Immediate source for I-type instructions
                            -- ALU operation based on funct3 and funct7
                            if funct3 = "000" then
                                alu_op <= "0000"; -- ALU operation for ADDI
                            elsif funct3 = "010" then
                                alu_op <= "0011"; -- ALU operation for SLTI
                            elsif funct3 = "011" then
                                alu_op <= "0100"; -- ALU operation for SLTIU
                            elsif funct3 = "100" then
                                alu_op <= "0101"; -- ALU operation for XORI
                            elsif funct3 = "110" then
                                alu_op <= "1000"; -- ALU operation for ORI
                            elsif funct3 = "111" then
                                alu_op <= "1001"; -- ALU operation for ANDI
                            elsif funct7 = "0000000" and funct3 = "001" then
                                alu_op <= "0010"; -- ALU operation for SLLI
                            elsif funct7 = "0000000" and funct3 = "101" then
                                alu_op <= "0110"; -- ALU operation for SRLI
                            elsif funct7 = "0100000" and funct3 = "101" then
                                alu_op <= "0111"; -- ALU operation for SRAI
                            else
                                alu_op <= "1111"; -- ALU operation for default Nah
                            end if;
                            reg_wr <= '1'; -- Enable register write
                            sel_A <= '0'; -- Select source A from register
                            sel_B <= '1'; -- Select source B from immediate value
                            wb_sel <= "01"; -- Write-back selection for ALU result
                            -- Other control signals...
                
                        when "0110011" =>  -- R-type Arithmetic
                            immsrc <= "000"; -- No immediate for R-type instructions
                            -- ALU operation based on funct3 and funct7
                            if funct7 = "0000000" and funct3 = "000" then
                                alu_op <= "0000"; -- ALU operation for ADD
                            elsif funct7 = "0100000" and funct3 = "000" then
                                alu_op <= "0001"; -- ALU operation for SUB
                            elsif funct7 = "0000000" and funct3 = "001" then
                                alu_op <= "0010"; -- ALU operation for SLL
                            elsif funct7 = "0000000" and funct3 = "010" then
                                alu_op <= "0011"; -- ALU operation for SLT
                            elsif funct7 = "0000000" and funct3 = "011" then
                                alu_op <= "0100"; -- ALU operation for SLTU
                            elsif funct7 = "0000000" and funct3 = "100" then
                                alu_op <= "0101"; -- ALU operation for XOR
                            elsif funct7 = "0000000" and funct3 = "101" then
                                alu_op <= "0110"; -- ALU operation for SRL
                            elsif funct7 = "0100000" and funct3 = "101" then
                                alu_op <= "0111"; -- ALU operation for SRA
                            elsif funct7 = "0000000" and funct3 = "110" then
                                alu_op <= "1000"; -- ALU operation for OR
                            elsif funct7 = "0000000" and funct3 = "111" then
                                alu_op <= "1001"; -- ALU operation for AND
                            else
                                alu_op <= "1111"; -- ALU operation for default Nah
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
                    -- Execute Logic
                   
                    
                    alu_a <= srcA; -- alu_a is always the register
                    if sel_B = '0' then
                        alu_b <= srcB; -- alu_b from source B
                    else
                        alu_b <= "00000000000000000000" & instr(31 downto 20); -- alu_b from immediate 
                    end if;
                
                    -- TO DO (milestone 3)
                    -- BRANCH FOR CONNECTION 
--                        br_taken <= 0; 

--                    if br_taken = '1' then
--                        PC <= PCPlus4;
--                    end if;
                
                    -- next state 
                    state <= MEM; 
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
                    -- Write back logic
                    reg_write <= '1';  -- Enable writing to the register file
--                  write_addr <= destination_register;  
                    -- write_data is already selected by the mux_wb_instance
                    -- ...
            
                    -- to reset state 
                    -- ...
                    state <= IFI;
                when others =>
                    state <= IFI;
            end case;
        end if;
    end process;

    -- To Do other connection logic
    -- ...

end Behavioral;

