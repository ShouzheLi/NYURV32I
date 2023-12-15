`timescale 1ns / 1ps

module tb_rc5;

    // Inputs
    reg clk = 0;
    reg rst = 0;
    reg [63:0] din;
    reg [63:0] original_plaintext;

    // Outputs
    wire [63:0] dout_enc;
    wire [63:0] dout_dec;

    // Instantiate the Unit Under Test (UUT)
    rc5_encryption uut_enc (
        .clk(clk), 
        .rst(rst), 
        .din(din), 
        .dout(dout_enc)
    );

    rc5_decryption uut_dec (
        .clk(clk), 
        .rst(rst), 
        .din(dout_enc), // Chained encrypted output to decryption input
        .dout(dout_dec)
    );

    // File IO variables
    integer plaintext_file, ciphertext_file, errors;
    integer scan_file;
    integer loop = 1 ;
    reg [127:0] line_read; // Buffer for reading lines

    // Clock generation
    always #5 clk = ~clk; // 10ns clock period
    
    //some constants of decode we want to test
    localparam [63:0] CONSTANT_VALUE1 = 64'hacdf64045cc137dc;
    localparam [63:0] CONSTANT_VALUE2 = 64'h550fce19d9753d8e;
    localparam [63:0] CONSTANT_VALUE3 = 64'hf84373d4d70d585c;
    localparam [63:0] CONSTANT_VALUE4 = 64'hc01227ee72c7a98c;
    localparam [63:0] CONSTANT_VALUE5 = 64'h40cf078a51c2d8f2;
    // Test stimulus
    initial begin
        // Initialize
        errors = 0;

        // Open files
        plaintext_file = $fopen("instruction.mem", "r");
        ciphertext_file = $fopen("ciphertexts.txt", "w");
        
        // Check for file open errors
        if (plaintext_file == 0) begin
            $display("Error: could not open plaintexts instruction.mem");
            $finish;
        end
        if (ciphertext_file == 0) begin
            $display("Error: could not open ciphertexts.txt");
            $finish;
        end

        // Apply reset
        rst = 1;
        #20; // Wait for 20ns
        rst = 0;
        #20

        // Read from plaintext file, encrypt, decrypt, and compare
        while (!$feof(plaintext_file)) begin
            scan_file = $fscanf(plaintext_file, "%x\n", din); // Read a line
            original_plaintext = din; // Store original plaintext
            #610; // Wait for encryption and decryption to complete
            
            //test the correctness of encode 
            //for this test I will test five code generation that see if they matach the outout in python file
            if (loop == 1) begin
                //test 1 input
                if (dout_enc !== CONSTANT_VALUE1) begin
                    $display("Error: Mismatch found. index: %x", loop);
                end
            end else if (loop == 2) begin
                //test 2 input
                if (dout_enc !== CONSTANT_VALUE2) begin
                    $display("Error: Mismatch found. index: %x", loop);
                end
            end else if (loop == 3) begin
                //test 3 input
                if (dout_enc !== CONSTANT_VALUE3) begin
                    $display("Error: Mismatch found. index: %x", loop);
                end
            end else if (loop == 4) begin
                //test 4 input
                if (dout_enc !== CONSTANT_VALUE4) begin
                    $display("Error: Mismatch found. index: %x", loop);
                end
            end else if (loop == 5) begin
                //test 5 input
                if (dout_enc !== CONSTANT_VALUE5) begin
                    $display("Error: Mismatch found. index: %x", loop);
                end
            end 
            loop = loop + 1 ;
            
            // test the correctness of encode-decode combination
            // for this test I would loop through every test and see if decode return the same as din
            if (dout_dec !== original_plaintext) begin
                // If the decrypted text does not match the original plaintext
                $display("Error: Mismatch found. Original: %x, Decrypted: %x", original_plaintext, dout_dec);
                errors = errors + 1;
            end
            $fwrite(ciphertext_file, "%x\n", dout_enc); // Write the encrypted data
            #20; // Wait for some time before the next operation
        end
        
        // Close files
        $fclose(plaintext_file);
        $fclose(ciphertext_file);

        // Check for errors
        if (errors > 0) begin
            $display("Simulation failed with %d errors.", errors);
        end else begin
            $display("Simulation passed with no errors.");
        end

        // Finish the simulation
        $finish;
    end

endmodule
