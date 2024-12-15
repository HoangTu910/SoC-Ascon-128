module ap_core (
    input iClk,
    input iReset_n,
    input start,
    input wire [3:0] round_cnt,        
    input wire [63:0] x0_i, x1_i, x2_i, x3_i, x4_i, 
    output reg [63:0] x0_o, x1_o, x2_o, x3_o, x4_o
);
    parameter UROL = 6;
    
    reg [63:0] x0_aff1 [UROL-1:0], x0_chi [UROL-1:0], x0_aff2 [UROL-1:0];
    reg [63:0] x1_aff1 [UROL-1:0], x1_chi [UROL-1:0], x1_aff2 [UROL-1:0];
    reg [63:0] x2_aff1 [UROL-1:0], x2_chi [UROL-1:0], x2_aff2 [UROL-1:0];
    reg [63:0] x3_aff1 [UROL-1:0], x3_chi [UROL-1:0], x3_aff2 [UROL-1:0];
    reg [63:0] x4_aff1 [UROL-1:0], x4_chi [UROL-1:0], x4_aff2 [UROL-1:0];

    reg [63:0] x0 [UROL:0], x1 [UROL:0], x2 [UROL:0], x3 [UROL:0], x4 [UROL:0];
    reg [3:0] t [UROL-1:0];
    reg [2:0] current_round;

    localparam IDLE = 2'b00;
    localparam PROCESS = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state;

    always@(posedge iClk or negedge iReset_n) begin
        if (!iReset_n) begin
            state <= IDLE;
            current_round <= 0;
            x0[0] <= 64'd0;
            x1[0] <= 64'd0;
            x2[0] <= 64'd0;
            x3[0] <= 64'd0;
            x4[0] <= 64'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        x0[0] <= x0_i;
                        x1[0] <= x1_i;
                        x2[0] <= x2_i;
                        x3[0] <= x3_i;
                        x4[0] <= x4_i;
                        current_round <= 0;
                        state <= PROCESS;
                    end
                end
                PROCESS: begin
                    if (current_round < UROL) begin
                        // Processing logic for each round
                        t[current_round] = (4'hC) - (round_cnt - current_round);
                        // 1st affine layer
                        x0_aff1[current_round] = x0[current_round] ^ x4[current_round];
                        x1_aff1[current_round] = x1[current_round];
                        x2_aff1[current_round] = x2[current_round] ^ x1[current_round] ^ {(4'hF - t[current_round]), t[current_round]};
                        x3_aff1[current_round] = x3[current_round];
                        x4_aff1[current_round] = x4[current_round] ^ x3[current_round];

                        // Non-linear chi layer
                        x0_chi[current_round] = x0_aff1[current_round] ^ ((~x1_aff1[current_round]) & x2_aff1[current_round]);
                        x1_chi[current_round] = x1_aff1[current_round] ^ ((~x2_aff1[current_round]) & x3_aff1[current_round]);
                        x2_chi[current_round] = x2_aff1[current_round] ^ ((~x3_aff1[current_round]) & x4_aff1[current_round]);
                        x3_chi[current_round] = x3_aff1[current_round] ^ ((~x4_aff1[current_round]) & x0_aff1[current_round]);
                        x4_chi[current_round] = x4_aff1[current_round] ^ ((~x0_aff1[current_round]) & x1_aff1[current_round]);

                        // 2nd affine layer
                        x0_aff2[current_round] = x0_chi[current_round] ^ x4_chi[current_round];
                        x1_aff2[current_round] = x1_chi[current_round] ^ x0_chi[current_round];
                        x2_aff2[current_round] = ~x2_chi[current_round];
                        x3_aff2[current_round] = x3_chi[current_round] ^ x2_chi[current_round];
                        x4_aff2[current_round] = x4_chi[current_round];

                        // Linear transformation
                        x0[current_round + 1] = x0_aff2[current_round] ^ {x0_aff2[current_round][18:0], x0_aff2[current_round][63:19]} ^ {x0_aff2[current_round][27:0], x0_aff2[current_round][63:28]};
                        x1[current_round + 1] = x1_aff2[current_round] ^ {x1_aff2[current_round][60:0], x1_aff2[current_round][63:61]} ^ {x1_aff2[current_round][38:0], x1_aff2[current_round][63:39]};
                        x2[current_round + 1] = x2_aff2[current_round] ^ {x2_aff2[current_round][0:0], x2_aff2[current_round][63:1]} ^ {x2_aff2[current_round][5:0], x2_aff2[current_round][63:6]};
                        x3[current_round + 1] = x3_aff2[current_round] ^ {x3_aff2[current_round][9:0], x3_aff2[current_round][63:10]} ^ {x3_aff2[current_round][16:0], x3_aff2[current_round][63:17]};
                        x4[current_round + 1] = x4_aff2[current_round] ^ {x4_aff2[current_round][6:0], x4_aff2[current_round][63:7]} ^ {x4_aff2[current_round][40:0], x4_aff2[current_round][63:41]};

                        current_round <= current_round + 1;
                    end else begin
                        state <= DONE;
                    end
                end
                DONE: begin
                    x0_o <= x0[UROL];
                    x1_o <= x1[UROL];
                    x2_o <= x2[UROL];
                    x3_o <= x3[UROL];
                    x4_o <= x4[UROL];
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
