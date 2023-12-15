library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity rc5_encryption is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           din : in STD_LOGIC_VECTOR(63 downto 0);
           dout : out STD_LOGIC_VECTOR(63 downto 0));
end rc5_encryption;

architecture Behavioral of rc5_encryption is

    type ROM_TYPE is array (0 to 25) of unsigned(31 downto 0);
    constant ROM : ROM_TYPE := (
    0 => (others => '0'),
    1 => (others => '0'),
    2 => x"46F8E8C5",
    3 => x"460C6085",
    4 => x"70F83B8A",
    5 => x"284B8303",
    6 => x"513E1454",
    7 => x"F621ED22",
    8 => x"3125065D",
    9 => x"11A83A5D",
    10 => x"D427686B",
    11 => x"713AD82D",
    12 => x"4B792F99",
    13 => x"2799A4DD",
    14 => x"A7901C49",
    15 => x"DEDE871A",
    16 => x"36C03196",
    17 => x"A7EFC249",
    18 => x"61A78BB8",
    19 => x"3B0A1D2B",
    20 => x"4DBFCA76",
    21 => x"AE162167",
    22 => x"30D76B0A",
    23 => x"43192304",
    24 => x"F6CC1431",
    25 => x"65046380"
    );

    type STATE_TYPE is (IDLE, ENCODE, OUTPUT);
    signal state: STATE_TYPE;

    signal a_reg, b_reg, a_rot, b_rot, a, b, ab_xor, ba_xor : unsigned(31 downto 0);
    signal temp1,temp2 : unsigned(4 downto 0);
    signal i_cnt : integer range 1 to 12 := 1;

    

begin

    -- State machine process
    state_machine : process(clk, rst)
    
    -- generate variable value that we want blocking assignment for each loop
    variable  a_reg_v, b_reg_v, a_rot_v, b_rot_v, a_v, b_v, ab_xor_v, ba_xor_v : unsigned(31 downto 0);
    variable temp1_v,temp2_v : unsigned(4 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= IDLE;
            else
                
                case state is
                    when IDLE =>
                       -- Reset logic
                        i_cnt <= 1; -- Reset the counter
                        a_rot <= (others => '0');
                        b_rot <= (others => '0');
                        a <= (others => '0');
                        b <= (others => '0');
                        ab_xor <= (others => '0');
                        ba_xor <= (others => '0');
                        temp1 <= (others => '0');
                        temp2 <= (others => '0');

                        

                        a_rot_v := (others => '0');
                        b_rot_v := (others => '0');
                        a_v := (others => '0');
                        b_v := (others => '0');
                        ab_xor_v := (others => '0');
                        ba_xor_v := (others => '0');
                        temp1_v := (others => '0');
                        temp2_v := (others => '0');
                        

                        a_reg_v := unsigned(din(63 downto 32));
                        b_reg_v := unsigned(din(31 downto 0));
                        a_reg <= a_reg_v;
                        b_reg <= b_reg_v;
                        state <= ENCODE;

                    when ENCODE =>

                        -- Encoding logic
                        -- Implement the RC5 encryption steps here
                        -- XOR operations
                        ab_xor_v := a_reg_v xor b_reg_v;
                        
                        --left rotate ab_xor
                        temp1_v := b_reg_v(4 downto 0);
                        a_rot_v := ab_xor_v((31 - TO_INTEGER(temp1_v)) downto 0) & ab_xor_v(31 downto (32 - TO_INTEGER(temp1_v)));

                        -- Add rotated a to ROM value, mask to 32 bits
                        a_v := a_rot_v + rom(i_cnt * 2);
                        ba_xor_v := b_reg_v xor a_v;

                        --left rotate ba_xor
                        temp2_v := a_v(4 downto 0);
                        b_rot_v := ba_xor_v((31 - TO_INTEGER(temp2_v)) downto 0) & ba_xor_v(31 downto (32 - TO_INTEGER(temp2_v)));

                        -- Add rotated b to ROM value, mask to 32 bits
                        b_v := b_rot_v + rom(i_cnt * 2 + 1);

                        -- Mask a and b to 32 bits (This is actually not needed in VHDL because the size is already constrained)
                        a_reg_v := a_v;
                        b_reg_v := b_v;
                       
                        a_reg <= a_reg_v;
                        b_reg <= b_reg_v;
                        a_rot <= a_rot_v;
                        b_rot <= b_rot_v;
                        a <= a_v;
                        b <= b_v;
                        ab_xor <= ab_xor_v;
                        ba_xor <= ba_xor_v;
                        temp1 <= temp1_v;
                        temp2  <= temp2_v;
                        
                        if i_cnt < 12 then
                            i_cnt <= i_cnt + 1;
                            state <= ENCODE;
                        else 
                            state <= OUTPUT;
                        end if;
                        
                    when OUTPUT =>
                        -- Set output
                        dout <= std_logic_vector(a_reg) & std_logic_vector(b_reg); -- Combine the two 32-bit registers
                        state <= IDLE;
                    when others =>
                        state<= IDLE;
                        
                end case;
            end if;
        end if;
    end process state_machine;


end Behavioral;
