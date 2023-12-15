`timescale 1ns / 1ps

module rc5_decryption(
    input wire clk,
    input wire rst,
    input wire [63:0] din,
    output reg [63:0] dout
);
  
    // Define ROM array
    reg [31:0] ROM[1:26];
    initial begin
        ROM[2]  = 32'h46F8E8C5;
        ROM[3]  = 32'h460C6085;
        ROM[4]  = 32'h70F83B8A;
        ROM[5]  = 32'h284B8303;
        ROM[6]  = 32'h513E1454;
        ROM[7]  = 32'hF621ED22;
        ROM[8]  = 32'h3125065D;
        ROM[9]  = 32'h11A83A5D;
        ROM[10] = 32'hD427686B;
        ROM[11] = 32'h713AD82D;
        ROM[12] = 32'h4B792F99;
        ROM[13] = 32'h2799A4DD;
        ROM[14] = 32'hA7901C49;
        ROM[15] = 32'hDEDE871A;
        ROM[16] = 32'h36C03196;
        ROM[17] = 32'hA7EFC249;
        ROM[18] = 32'h61A78BB8;
        ROM[19] = 32'h3B0A1D2B;
        ROM[20] = 32'h4DBFCA76;
        ROM[21] = 32'hAE162167;
        ROM[22] = 32'h30D76B0A;
        ROM[23] = 32'h43192304;
        ROM[24] = 32'hF6CC1431;
        ROM[25] = 32'h65046380;
    end

    // Define state types
    parameter IDLE = 0, DECODE = 1, OUTPUT = 2;
    reg [1:0] state;

    reg [31:0] a_reg, b_reg, a_rot, b_rot, a, b, ab_xor, ba_xor;
    integer i_cnt;
    integer rotate_by_a;
    integer rotate_by_b;

    // Next state logic
    always @(posedge clk or posedge rst) begin

        if (rst) begin
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    // Initialize decode process
                    // Assuming din is already present
                    i_cnt = 12 ;
                    a_reg <= din[63:32];
                    b_reg <= din[31:0];
                    rotate_by_a = 0;
                    rotate_by_b = 0;
                    a_rot =0;
                    b_rot = 0;
                    a = 0;
                    b = 0;
                    ab_xor =0;
                    ba_xor =0;
                    state <= DECODE;
                end
                DECODE: begin
                    // Decode logic
                    // Implement the RC5 decryption steps here


                    // Placeholder for the actual RC5 decode logic
                    a = a_reg;
                    b = b_reg;
                    
                    // execute decode
                    b_rot = b - ROM[i_cnt * 2 + 1];
                    rotate_by_a = a & 31;
                    // right rotate b_rot get ba_xor
                    ba_xor = (b_rot >> rotate_by_a) | (b_rot << (32 - rotate_by_a)); 

                    //ba_xor xor a 
                    b_reg = a ^ ba_xor; 
                    
                    a_rot = a - ROM[i_cnt * 2 ];
                    rotate_by_b = b_reg & 31;
                    // right rotate a_rot
                    ab_xor = (a_rot >> rotate_by_b) | (a_rot << (32 - rotate_by_b)); // right_rotation
                    a_reg = ab_xor ^ b_reg;

                    //get next state
                    if (i_cnt >= 1) begin
                        i_cnt <= i_cnt - 1;
                        state <= DECODE;
                    end else begin
                        state <=  OUTPUT;
                    end
                end
                OUTPUT: begin
                    i_cnt <= 12; // Reset the counter for the next input
                    state <= IDLE;
                    dout = {a, b};
                end
                default: begin
                    // Handle undefined states
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
