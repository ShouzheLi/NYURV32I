-- VHDL Translation of the Verilog RV32I module
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity RV32I is
    Port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        Result      : out STD_LOGIC_VECTOR(31 downto 0);
        zero        : out STD_LOGIC;
        overload    : out STD_LOGIC;
        hlt         : out STD_LOGIC
    );
end RV32I;

architecture Behavioral of RV32I is

    -- Component declarations for datapath and controller
    -- These should be defined according to the actual definition of datapath and controller.
    component datapath
        Port (
            opcode      : in STD_LOGIC_VECTOR(6 downto 0);
            funct3      : in STD_LOGIC_VECTOR(2 downto 0);
            funct7      : in STD_LOGIC_VECTOR(6 downto 0);
            Result      : out STD_LOGIC_VECTOR(31 downto 0);
            rst         : in STD_LOGIC;
            clk         : in STD_LOGIC;
            reg_wr      : in STD_LOGIC;
            sel_A       : in STD_LOGIC;
            sel_B       : in STD_LOGIC;
            wb_sel      : in STD_LOGIC_VECTOR(1 downto 0);
            immsrc      : in STD_LOGIC_VECTOR(2 downto 0);
            alu_op      : in STD_LOGIC_VECTOR(3 downto 0);
            br_type     : in STD_LOGIC_VECTOR(2 downto 0);
            readcontrol : in STD_LOGIC_VECTOR(2 downto 0);
            writecontrol: in STD_LOGIC_VECTOR(2 downto 0);
            zero        : out STD_LOGIC;
            overload    : out STD_LOGIC
        );
    end component;

    component controller
        Port (
            immsrc       : out STD_LOGIC_VECTOR(2 downto 0);
            alu_op       : out STD_LOGIC_VECTOR(3 downto 0);
            br_type      : out STD_LOGIC_VECTOR(2 downto 0);
            readcontrol  : out STD_LOGIC_VECTOR(2 downto 0);
            writecontrol : out STD_LOGIC_VECTOR(2 downto 0);
            reg_wr       : out STD_LOGIC;
            sel_A        : out STD_LOGIC;
            sel_B        : out STD_LOGIC;
            hlt          : out STD_LOGIC;
            wb_sel       : out STD_LOGIC_VECTOR(1 downto 0);
            opcode       : in STD_LOGIC_VECTOR(6 downto 0);
            funct3       : in STD_LOGIC_VECTOR(2 downto 0);
            funct7       : in STD_LOGIC_VECTOR(6 downto 0);
            rst          : in STD_LOGIC
        );
    end component;

    -- Signal declarations
    signal opcode       : STD_LOGIC_VECTOR(6 downto 0);
    signal funct3       : STD_LOGIC_VECTOR(2 downto 0);
    signal funct7       : STD_LOGIC_VECTOR(6 downto 0);
    signal instr        : STD_LOGIC_VECTOR(31 downto 0);
    signal br_taken     : STD_LOGIC;
    signal resultsrc    : STD_LOGIC;
    signal reg_wr       : STD_LOGIC;
    signal sel_A        : STD_LOGIC;
    signal sel_B        : STD_LOGIC;
    signal alu_op       : STD_LOGIC_VECTOR(3 downto 0);
    signal immsrc       : STD_LOGIC_VECTOR(2 downto 0);
    signal br_type      : STD_LOGIC_VECTOR(2 downto 0);
    signal readcontrol  : STD_LOGIC_VECTOR(2 downto 0);
    signal writecontrol : STD_LOGIC_VECTOR(2 downto 0);
    signal wb_sel       : STD_LOGIC_VECTOR(1 downto 0);

begin

    -- Instance of datapath
    dp : datapath
        Port map (
            opcode      => opcode,
            funct3      => funct3,
            funct7      => funct7,
            Result      => Result,
            rst         => rst,
            clk         => clk,
            reg_wr      => reg_wr,
            sel_A       => sel_A,
            sel_B       => sel_B,
            wb_sel      => wb_sel,
            immsrc      => immsrc,
            alu_op      => alu_op,
            br_type     => br_type,
            readcontrol => readcontrol,
            writecontrol=> writecontrol,
            zero        => zero,
            overload    => overload
        );

    -- Instance of controller
    con : controller
        Port map (
            immsrc       => immsrc,
            alu_op       => alu_op,
            br_type      => br_type,
            readcontrol  => readcontrol,
            writecontrol => writecontrol,
            reg_wr       => reg_wr,
            sel_A        => sel_A,
            sel_B        => sel_B,
            hlt          => hlt,
            wb_sel       => wb_sel,
            opcode       => opcode,
            funct3       => funct3,
            funct7       => funct7,
            rst          => rst
        );

end Behavioral;
