module tb_ap_wrapper;

    reg iClk;
    reg iReset_n;
    reg iChip_select_n;
    reg iRead_n;
    reg iWrite_n;
    reg [4:0] iAddress;
    reg [31:0] iWriteData;
    wire [31:0] oReadData;

    // Instantiate the wrapper
    ap_wrapper uut (
        .iClk(iClk),
        .iReset_n(iReset_n),
        .iChip_select_n(iChip_select_n),
        .iRead_n(iRead_n),
        .iWrite_n(iWrite_n),
        .iAddress(iAddress),
        .iWriteData(iWriteData),
        .oReadData(oReadData)
    );

    // Clock generation
    initial begin
        iClk = 0;
        forever #5 iClk = ~iClk; // 10ns clock period
    end

    // Testbench procedure
    initial begin
        // Initialization
        iReset_n = 0;
        iChip_select_n = 1;
        iRead_n = 1;
        iWrite_n = 1;
        iAddress = 0;
        iWriteData = 0;
        #20;
        
        // Deassert reset
        iReset_n = 1;
        #10;
        iRead_n = 1;
        iWrite_n = 0;
        write_to_csr(5'd1, 32'h01234567);  // x0[31:0] (part of 64'h0123456789ABCDEF)
        write_to_csr(5'd2, 32'h89ABCDEF);  // x0[63:32]
        
        write_to_csr(5'd3, 32'hFEDCBA98);  // x1[31:0] (part of 64'hFEDCBA9876543210)
        write_to_csr(5'd4, 32'h76543210);  // x1[63:32]

        write_to_csr(5'd5, 32'h12345678);  // x2[31:0] (part of 64'h1234567890ABCDEF)
        write_to_csr(5'd6, 32'h90ABCDEF);  // x2[63:32]
        
        write_to_csr(5'd7, 32'hA1B2C3D4);  // x3[31:0] (part of 64'hA1B2C3D4E5F60789)
        write_to_csr(5'd8, 32'hE5F60789);  // x3[63:32]
        
        write_to_csr(5'd9, 32'h11111111);  // x4[31:0] (part of 64'h1111111111111111)
        write_to_csr(5'd10, 32'h11111111); // x4[63:32]
        #100;
        iRead_n = 0;
        iWrite_n = 1;
        read_from_csr(5'd11); // x0_o[31:0]
        read_from_csr(5'd12); // x0_o[63:32]
        read_from_csr(5'd13); // x1_o[31:0]
        read_from_csr(5'd14); // x1_o[63:32]
        read_from_csr(5'd15); // x2_o[31:0]
        read_from_csr(5'd16); // x2_o[63:32]
        read_from_csr(5'd17); // x3_o[31:0]
        read_from_csr(5'd18); // x3_o[63:32]
        read_from_csr(5'd19); // x4_o[31:0]
        read_from_csr(5'd20); // x4_o[63:32]
        #20;

        // Finish simulation
        $stop;
    end

    // Task to perform a write operation
    task write_to_csr(input [4:0] address, input [31:0] data);
        begin
            iChip_select_n = 0;  // Enable chip select
            iWrite_n = 0;        // Write operation
            iAddress = address;
            iWriteData = data;
            #10;
            iWrite_n = 1;        // End write
            iChip_select_n = 1;  // Disable chip select
            #10;
        end
    endtask

    // Task to perform a read operation
    task read_from_csr(input [4:0] address);
        begin
            iChip_select_n = 0;  // Enable chip select
            iRead_n = 0;         // Read operation
            iAddress = address;
            #10;
            $display("Read Address %d: Data = %h", address, oReadData);
            iRead_n = 1;         // End read
            iChip_select_n = 1;  // Disable chip select
            #10;
        end
    endtask

endmodule
