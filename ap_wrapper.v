module ap_wrapper (
    input iClk,
    input iReset_n,
    input iChip_select_n,
    input iRead_n,
    input iWrite_n,
    input [4:0] iAddress,
    input [31:0] iWriteData,
    output [31:0] oReadData
);

wire start; 
wire [3:0] round_cnt = 4'd6; 
wire [63:0] x0, x1, x2, x3, x4;
wire [63:0] x0_o, x1_o, x2_o, x3_o, x4_o;

ap_csr CSR (
    .iClk           (iClk         ),
    .iReset_n       (iReset_n     ),
    .iChip_select_n (iChip_select_n),
    .iWrite_n       (iWrite_n     ),
    .iRead_n        (iRead_n      ),
    .iAddress       (iAddress     ),
    .iWriteData     (iWriteData   ),
    .oReadData      (oReadData    ),
    .x0             (x0           ),
    .x1             (x1           ),
    .x2             (x2           ),
    .x3             (x3           ),
    .x4             (x4           ),
    .start          (start        ),
    .x0_o           (x0_o         ),
    .x1_o           (x1_o         ),
    .x2_o           (x2_o         ),
    .x3_o           (x3_o         ),
    .x4_o           (x4_o         )
);

ap_core CORE (
    .iClk       (iClk       ),
    .iReset_n   (iReset_n   ),
    .start      (start      ),
    .round_cnt  (round_cnt  ),
    .x0_i       (x0         ),
    .x1_i       (x1         ),
    .x2_i       (x2         ),
    .x3_i       (x3         ),
    .x4_i       (x4         ),
    .x0_o       (x0_o       ),
    .x1_o       (x1_o       ),
    .x2_o       (x2_o       ),
    .x3_o       (x3_o       ),
    .x4_o       (x4_o       )
);

endmodule
