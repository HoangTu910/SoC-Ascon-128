module ap_csr (
    input iClk,
    input iReset_n,
    input iChip_select_n,
    input iRead_n,
    input iWrite_n,
    input [4:0] iAddress,
    input [31:0] iWriteData,
    output reg [31:0] oReadData,
    output reg [63:0] x0, x1, x2, x3, x4,
    output reg start,
    input [63:0] x0_o, x1_o, x2_o, x3_o, x4_o
);
    always @(posedge iClk or negedge iReset_n) begin
        if (!iReset_n) begin
            x0 <= 64'd0;
            x1 <= 64'd0;
            x2 <= 64'd0;
            x3 <= 64'd0;
            x4 <= 64'd0;
            start <= 1'b0;
        end else if (!iChip_select_n && !iWrite_n) begin
            case (iAddress)
                5'd1:  x0[63:32]  <= iWriteData;
                5'd2:  x0[31:0] <= iWriteData;
                5'd3:  x1[63:32]  <= iWriteData;
                5'd4:  x1[31:0] <= iWriteData;
                5'd5:  x2[63:32]  <= iWriteData;
                5'd6:  x2[31:0] <= iWriteData;
                5'd7:  x3[63:32]  <= iWriteData;
                5'd8:  x3[31:0] <= iWriteData;
                5'd9:  x4[63:32]  <= iWriteData;
                5'd10: begin 
                            x4[31:0] <= iWriteData; 
                            start <= 1'b1;
                end
                default: ; 
            endcase
        end
    end

    always @(posedge iClk or negedge iReset_n) begin
        if (!iReset_n) begin
            oReadData <= 32'd0;
        end else if (!iChip_select_n && !iRead_n && start) begin
            case (iAddress)
                5'd11: oReadData = x0_o[63:32];
                5'd12: oReadData = x0_o[31:0];
                5'd13: oReadData = x1_o[63:32];
                5'd14: oReadData = x1_o[31:0];
                5'd15: oReadData = x2_o[63:32];
                5'd16: oReadData = x2_o[31:0];
                5'd17: oReadData = x3_o[63:32];
                5'd18: oReadData = x3_o[31:0];
                5'd19: oReadData = x4_o[63:32];
                5'd20: oReadData = x4_o[31:0];
                default: oReadData <= 32'd0; 
            endcase
        end else begin
            oReadData <= 32'd0; 
        end
    end

endmodule
