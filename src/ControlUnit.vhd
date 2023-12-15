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
        clk : in STD_LOGIC;    -- Clock signal
        Result : out STD_LOGIC_VECTOR(31 downto 0);
        zero : out STD_LOGIC;
        overload : out STD_LOGIC
    );
end Control_Unit;

architecture Behavioral of Control_Unit is
    -- Definition of states and signals
    type State_Type is (IFI, ID, EX, ALU_result,MEM, WB);
    signal State : State_Type;
    signal immext,  rd1, rd2, rdata : std_logic_vector(31 downto 0);
    signal PC : std_logic_vector(31 downto 0):= x"01000000" ;
    signal PCPlus4 : std_logic_vector(31 downto 0):= x"01000000" ;
    signal aluresult : std_logic_vector(31 downto 0);
    signal PCNext : std_logic_vector(31 downto 0) := x"01000000";
    signal srcA, srcB: std_logic_vector(31 downto 0) ;
    signal opcode : std_logic_vector(6 downto 0);
    signal funct3 : std_logic_vector(2 downto 0);
    signal funct7 : std_logic_vector(6 downto 0);
    signal reg_wr : std_logic;
    signal br_taken: std_logic:= '0' ;
    signal immsrc, br_type, readcontrol, writecontrol : std_logic_vector(2 downto 0);
--    signal wb_sel : std_logic_vector(1 downto 0);
    signal alu_op_sign : std_logic_vector(3 downto 0);
    
    -- Other signal definitions...
    signal instr : std_logic_vector(31 downto 0);
    signal rs2 : std_logic_vector(24 downto 20);
    signal rs1 : std_logic_vector(19 downto 15);
    signal rd : std_logic_vector(11 downto 7);
    signal imm : std_logic_vector(31 downto 7);
    
    -- inner calculation
    signal temp_Result : STD_LOGIC_VECTOR(31 downto 0);
    

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
    component instruction_memory is
        Port (
            pc : in STD_LOGIC_VECTOR(31 downto 0);
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
   
    component sign_extend is
        Port (
            instr : in STD_LOGIC_VECTOR(31 downto 7); -- Instruction bits input
            immsrc : in STD_LOGIC_VECTOR(2 downto 0); -- Immediate source type
            immext : out STD_LOGIC_VECTOR(31 downto 0) -- Extended immediate output
        );
    end component;
    

begin
    -- Instantiation of Program Counter
    P_C : ProgramCounter Port Map (
        pc => PC,
        clk => clk,
        rst => rst,
        pc_next => PCNext
    );

    -- Instantiation of Instruction Memory
    InstMem : instruction_memory Port Map (
        pc => PC,
        instr => instr
    );

    -- Inside your architecture, where you are mapping the instruction_fetch component
    InstFetch: instruction_fetch Port Map (
        instr => instr,
        opcode => opcode,               -- The opcode field is typically the first 7 bits
        rd => rd,                  -- The rd field is typically 5 bits
        funct3 => funct3,             -- The funct3 field is typically 3 bits
        rs1 => rs1,                -- The rs1 field is typically 5 bits
        rs2 => rs2,                -- The rs2 field is typically 5 bits
        funct7 => funct7,             -- The funct7 field is typically 7 bits
        imm => imm                -- Adjust the imm field according to your design needs
    );
    
         -- Instance of sign_extend 
    sign_extend_instance : sign_extend
        Port Map (
            instr => instr(31 downto 7), -- Instruction bits input
            immsrc => immsrc, -- Immediate source type
            immext => immext-- Extended immediate output
        );

        -- Instance of Register File for write back operation
    reg_file_instance : register_file
        Port Map (
            clk => clk,
            we3 => reg_wr,    -- reg_write signal in ControlUnit must connect to we3 in register_file
            rst => rst,
            a1 => rs1,   -- Make sure these signals exist in your ControlUnit architecture
            a2 => rs2,
            a3 => rd,
            wd3 => temp_Result,
            rd1 => rd1,     -- Make sure these signals exist in your ControlUnit architecture
            rd2 => rd2
        );

    -- Instance of ALU
    alu_instance : alu
        Port Map (
            a => srcA,
            b => srcB,
            alu_sel => alu_op_sign,
            alu_result => aluresult,
            zero => zero,
            overload => overload
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
    data_memory_instance : data_memory
        Port Map (
            clk => clk,
            rst => rst,
            readcontrol => readcontrol,
            writecontrol => writecontrol,
            address => aluresult,
            writedata => rd2,
            read_data => rdata
        );
        

    -- FSM implementation
    process (clk, rst)
        variable reg_wr_decode : STD_LOGIC := '0';
        variable wb_sel : std_logic_vector(1 downto 0);
        variable readcontrol_decode : std_logic_vector(2 downto 0);
        variable writecontrol_decode : std_logic_vector(2 downto 0);
        variable alu_op : std_logic_vector(3 downto 0);
        variable sel_A,sel_B: STD_LOGIC;
    begin
        if rst = '1' then
             --重置控制信号
--            immsrc <= (others => '1');
--            alu_op <= (others => '1');
--            br_type <= "010";
--            readcontrol <= (others => '1');
--            writecontrol <= (others => '1');
--            reg_wr <= '0';
--            sel_A <= '0';
--            sel_B <= '0';
--            hlt <= '0';
--            wb_sel <= (others => '1');
            --重置逻辑
            br_taken <= '0';
            PCNext <= x"01000000";
            State <= IFI;
        elsif rising_edge(clk) then
            case State is
                when IFI =>
                    
                   -- instr already provided by PC
                    PCPlus4 <= PC + "00000000000000000000000000000100"; -- 计算 PC
                    -- Index Logic
                    if br_taken = '0' then
                        PCNext <= PCPlus4;
                    else
                        PCNext <=  aluresult;
                    end if;
                    
                    
                    -- Next State
                    State <= ID; 
                when ID =>
                    
                    case opcode is
                        when "0010011" =>  -- I-type Arithmetic
                           
                            -- ALU operation based on funct3 and funct7
                            if funct3 = "000" then
                                alu_op := "0000"; -- ALU operation for ADDI
                            elsif funct3 = "010" then
                                alu_op := "0011"; -- ALU operation for SLTI
                            elsif funct3 = "011" then
                                alu_op := "0100"; -- ALU operation for SLTIU
                            elsif funct3 = "100" then
                                alu_op := "0101"; -- ALU operation for XORI
                            elsif funct3 = "110" then
                                alu_op := "1000"; -- ALU operation for ORI
                            elsif funct3 = "111" then
                                alu_op := "1001"; -- ALU operation for ANDI
                            elsif funct7 = "0000000" and funct3 = "001" then
                                alu_op := "0010"; -- ALU operation for SLLI
                            elsif funct7 = "0000000" and funct3 = "101" then
                                alu_op := "0110"; -- ALU operation for SRLI
                            elsif funct7 = "0100000" and funct3 = "101" then
                                alu_op := "0111"; -- ALU operation for SRAI
                            else
                                alu_op := "1111"; -- ALU operation for default Nah
                            end if;
                            
                            --Controller inner signals
                            immsrc <= "000"; --sign extend I type
                            sel_A := '1'; -- Select source A from register
                            sel_B := '1'; -- Select source B from immediate value
                            wb_sel := "01"; -- Write-back selection for ALU result
                            reg_wr_decode := '1'; -- Enable register write
                            br_type <= "010"; -- No branch
                            
                             -- No memory read or write for branch instructions
                            readcontrol_decode := "111";
                            writecontrol_decode := "111";
                
                        when "0110011" =>  -- R-type Arithmetic
                            
                            -- ALU operation based on funct3 and funct7
                            if funct7 = "0000000" and funct3 = "000" then
                                alu_op := "0000"; -- ALU operation for ADD
                            elsif funct7 = "0100000" and funct3 = "000" then
                                alu_op := "0001"; -- ALU operation for SUB
                            elsif funct7 = "0000000" and funct3 = "001" then
                                alu_op := "0010"; -- ALU operation for SLL
                            elsif funct7 = "0000000" and funct3 = "010" then
                                alu_op := "0011"; -- ALU operation for SLT
                            elsif funct7 = "0000000" and funct3 = "011" then
                                alu_op := "0100"; -- ALU operation for SLTU
                            elsif funct7 = "0000000" and funct3 = "100" then
                                alu_op := "0101"; -- ALU operation for XOR
                            elsif funct7 = "0000000" and funct3 = "101" then
                                alu_op := "0110"; -- ALU operation for SRL
                            elsif funct7 = "0100000" and funct3 = "101" then
                                alu_op := "0111"; -- ALU operation for SRA
                            elsif funct7 = "0000000" and funct3 = "110" then
                                alu_op := "1000"; -- ALU operation for OR
                            elsif funct7 = "0000000" and funct3 = "111" then
                                alu_op := "1001"; -- ALU operation for AND
                            else
                                alu_op := "1111"; -- ALU operation for default Nah
                            end if;
                            
                            --Controller inner signals
                            immsrc <= "111"; --sign extend I type
                            sel_A := '1'; -- Select source A from register
                            sel_B := '0'; -- Select source B from register
                            wb_sel := "01"; -- Write-back selection for ALU result
                            reg_wr_decode := '1'; -- Enable register write
                            br_type <= "010"; -- No branch.
                            
                             -- No memory read or write for branch instructions
                            readcontrol_decode := "111";
                            writecontrol_decode := "111";
                            
                       when "0000011" =>  -- Load instructions (assuming opcode "3" is for loads)
                            
                            alu_op := "0000"; -- ALU operation (e.g., ADD for calculating effective address)
                            readcontrol_decode := funct3; -- Read control for type of load (byte, halfword, word)
                            writecontrol_decode := "111"; -- No write operation for load instructions
                            
                            --Controller inner signals
                            immsrc <= "111"; --sign extend I type
                            sel_A := '1'; -- Select source A from register
                            sel_B := '1'; -- Select source B from immediate
                            wb_sel := "10"; -- Write-back selection for rdata
                            reg_wr_decode := '1'; -- Enable register write
                            br_type <= "010"; -- No branch.branch
                           
                
                        when "0100011" =>  -- Store instructions (assuming opcode "35" is for stores)
                            alu_op := "0000"; -- ALU operation for add to compare registers
                            writecontrol_decode := funct3; -- Write control for type of store (byte, halfword, word)
                            readcontrol_decode := "111"; -- No read operation for store instructions
                            
                            --Controller inner signals
                            immsrc <= "001"; --sign extend I type
                            sel_A := '1'; -- Select source A from register
                            sel_B := '1'; -- Select source B from register
                            wb_sel := "11"; -- None Write-back 
                            reg_wr <= '0'; -- Enable register write
                            br_type <= "010"; -- No branch.
                           
           
                         when "1100011" =>  -- Branch instructions (assuming opcode "99" is for branches)
                           
                            alu_op := "0000"; -- ALU operation for add to compare registers
                            -- No memory read or write for branch instructions
                            readcontrol_decode := "111";
                            writecontrol_decode := "111";
                            
                            --Controller inner signals
                            immsrc <= "010"; --sign extend I type
                            sel_A := '0'; -- Select source A from pc
                            sel_B := '1'; -- Select source B from immext
                            wb_sel := "11"; -- Write-back selection for ALU result
                            reg_wr_decode := '0'; -- Enable register write
                            br_type <= funct3; --  branch BY funct3.
                
                        when "0110111" =>  -- LUI instruction (assuming opcode "55" is for LUI)
                            
                            alu_op := "0000"; -- ALU operation for LUI (simply passing the immediate value)
                            -- No memory read or write for branch instructions
                            readcontrol_decode := "111";
                            writecontrol_decode := "111";
                           
                           --Controller inner signals
                            immsrc <= "011"; --sign extend I type
                            sel_A := '1'; -- Select source A from register
                            sel_B := '1'; -- Select source B from register
                            wb_sel := "01"; -- Write-back selection for ALU result
                            reg_wr_decode := '1'; -- Enable register write
                            br_type <= "010"; -- No branch.
                        
                        when "0010111" =>  -- AUIPC instruction 
                            
                            alu_op := "0000"; -- ALU operation for LUI (simply passing the immediate value)
                            -- No memory read or write for branch instructions
                            readcontrol_decode := "111";
                            writecontrol_decode := "111";
                           
                           --Controller inner signals
                            immsrc <= "011"; --sign extend I type
                            sel_A := '0'; -- Select source A from PC
                            sel_B := '1'; -- Select source B from register
                            wb_sel := "01"; -- Write-back selection for ALU result
                            reg_wr_decode := '1'; -- Enable register write
                            br_type <= "010"; -- No branch.
                            
                        when "1101111" =>  -- JAL instruction (assuming opcode "111" is for JAL)
                            
                            alu_op := "0000"; -- ALU operation for JAL (typically just adding offset to PC)
                            
                            -- No memory read or write for branch instructions
                            readcontrol_decode := "111";
                            writecontrol_decode := "111";
                            
                            --Controller inner signals
                            immsrc <= "100"; --sign extend I type
                            sel_A := '1'; -- Select source A from PC
                            sel_B := '1'; -- Select source B from register
                            wb_sel := "00"; -- Write-back selection for pcPLUS4
                            reg_wr <= '1'; -- Enable register write
                            br_type <= "011"; -- UNCOND branch
                
                        when "1100111" =>  -- JALR instruction (assuming opcode "103" is for JALR)
                            
                            alu_op := "0000"; -- ALU operation for JALR (adding offset to register value)
                            -- No memory read or write for branch instructions
                            readcontrol_decode := "111";
                            writecontrol_decode := "111";
                            
                            --Controller inner signals
                            immsrc <= "100"; --sign extend I type
                            sel_A := '0'; -- Select source A from PC
                            sel_B := '1'; -- Select source B from register
                            wb_sel := "00"; -- Write-back selection for pcPLUS4
                            reg_wr_decode := '1'; -- Enable register write
                            br_type <= "011"; -- UNCOND branch

                            
                        -- 其他指令类型...
                        when others =>
                            -- Default control signals for unrecognized opcode
                            alu_op := "1111"; -- ALU operation for JALR (adding offset to register value)
                            immsrc <= (others => '1');
                            br_type <= "010";
                            readcontrol_decode := (others => '1');
                            writecontrol_decode := (others => '1');
                            reg_wr_decode := '0';
                            sel_A := '0';
                            sel_B := '0';
                            hlt <= '1';
                            wb_sel := (others => '1');
                            -- Optionally set halt signal if invalid opcode
                            -- hlt <= '1';
                    end case;
                    
                     
                    state <= EX;
                when EX =>
                     -- Execute Logic
                    -- TO DO  process sel_A sel_B
                     if sel_A = '1' then
                        srcA <= rd1;
                     else
                        srcA <= PC;
                     end if;
                     
                     if sel_B = '1' then
                        srcB <= immext;
                     else
                        srcB <= rd2;
                     end if; 
                      
                                  
                    -- next state 
                    state <= ALU_result; 
                when ALU_result =>
                        
                    -- run alu
                    alu_op_sign <= alu_op;
                    
                    -- next state 
                    state <= MEM; 
                when MEM =>
                    if wb_sel = "10" then
                        
                        temp_Result <= rdata;
                    elsif wb_sel = "01" then
                        
                        temp_Result <= aluresult;
                    elsif wb_sel < "00" then
                        
                        temp_Result <= PCPlus4;
                    else
                        
                        temp_Result <= (others => '0');
                    end if;
                    -- late activate regwr
                    reg_wr <= reg_wr_decode;
                    readcontrol <= readcontrol_decode;
                    writecontrol <= writecontrol_decode;
                    -- Memory access logic
                    
                    -- Instruction Decode 
                    -- After completing the memory access, move to the next state.
                    state <= WB; -- Go to the Write Back stage.
                when WB =>
                    Result <= temp_Result;
                    
                    
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

