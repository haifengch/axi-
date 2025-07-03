
module axi_arbiter_m2s_m3
#(parameter W_CID = 4
          , W_ID  = 4
          , W_SID = (W_CID+W_ID)
          , NUM   = 3
          )
(
      input  wire                  AXI_RSTn
    , input  wire                  AXI_CLK

    , input  wire  [NUM-1:0]       AWSELECT
    , input  wire  [NUM-1:0]       AWVALID
    , input  wire  [NUM-1:0]       AWREADY
    , output wire  [NUM-1:0]       AWGRANT

    , input  wire  [NUM-1:0]       WSELECT
    , input  wire  [NUM-1:0]       WVALID
    , input  wire  [NUM-1:0]       WREADY
    , input  wire  [NUM-1:0]       WLAST
    , output wire  [NUM-1:0]       WGRANT

    , input  wire  [NUM-1:0]       ARSELECT
    , input  wire  [NUM-1:0]       ARVALID
    , input  wire  [NUM-1:0]       ARREADY
    , output wire  [NUM-1:0]       ARGRANT

    ,input   wire                  arbiter_type
);


//-----------------------------------------------------------
// read-address arbiter
localparam STAR_RUN = 'h0, STAR_WAIT = 'h1;
reg  [NUM-1:0] argrant_reg;
reg  [1:0]     stateAR = STAR_RUN;

always@(posedge AXI_CLK) begin
    if (!AXI_RSTn) begin
        argrant_reg <= 'h0;
        stateAR     <= STAR_RUN;
    end else begin
        case (stateAR)
            STAR_RUN: begin
                if (|ARGRANT) begin
                   // prevent the case that the granted-one is not completed due to ~ARREADY
                   // and new higher-priority-one joined, then things can go wrong.
                   if (~|(ARGRANT & ARREADY)) begin //ARREADY_ALL = {M2_ARREADY, M1_ARREADY, M0_ARREADY};
                       argrant_reg <= ARGRANT;
                       stateAR     <= STAR_WAIT;
                   end
                end
            end // STAR_RUN
            STAR_WAIT: begin //S_ARREADY=0
                if (|(ARGRANT & ARVALID & ARREADY)) begin
                    stateAR <= STAR_RUN;
                end
            end // STAR_WAIT
        endcase
    end
end

wire [2:0] ARREQ;
wire [2:0] ar_sel;
assign ARREQ = ARSELECT & ARVALID;

// round_robin_m2s u_arbiter_ar(
// .clk    (AXI_CLK ),
// .rst_n  (AXI_RSTn),
// .req    (ARREQ   ),
// .sel    (ar_sel  ) 
// );
rr_fixed_arbiter u_arbiter_ar(
.clk          (AXI_CLK      ),
.rst_n        (AXI_RSTn     ),
.arbiter_type (arbiter_type ),
.req          ({1'b0, ARREQ}),
.sel          (ar_sel       ) 
);


assign ARGRANT = (stateAR == STAR_RUN) ? ar_sel : argrant_reg;

//-----------------------------------------------------------
// write-address arbiter
localparam STAW_RUN = 'h0, STAW_WAIT = 'h1;
reg [NUM-1:0] awgrant_reg;
reg [1:0]     stateAW = STAW_RUN;

always @ (posedge AXI_CLK) begin
    if (!AXI_RSTn) begin
        awgrant_reg <=  'h0;
        stateAW     <= STAW_RUN;
    end else begin
    case (stateAW)
        STAW_RUN: begin
            if (|AWGRANT) begin
                if (~|(AWGRANT & AWREADY)) begin
                    awgrant_reg <= AWGRANT;
                    stateAW     <= STAW_WAIT;
                end
            end
        end // STAW_RUN
        STAW_WAIT: begin
            if (|(AWGRANT & AWVALID & AWREADY)) begin
                // awgrant_reg <= 'h0; 
                stateAW     <= STAW_RUN;
            end
        end // STAW_WAIT
        // default: begin
        //     awgrant_reg <=  'h0;
        //     stateAW     <= STAW_RUN;
        // end
    endcase
    end
end

wire [2:0] AWREQ;
wire [2:0] aw_sel;
assign AWREQ = AWSELECT & AWVALID;

// round_robin_m2s u_arbiter_aw(
// .clk    (AXI_CLK ),
// .rst_n  (AXI_RSTn),
// .req    (AWREQ   ),
// .sel    (aw_sel  ) 
// );
rr_fixed_arbiter u_arbiter_aw(
.clk          (AXI_CLK      ),
.rst_n        (AXI_RSTn     ),
.arbiter_type (arbiter_type ),
.req          ({1'b0, AWREQ}),
.sel          (aw_sel       ) 
);

assign AWGRANT = ((stateAW == STAW_RUN)) ? aw_sel : awgrant_reg;

//-----------------------------------------------------------
// write-data arbiter
localparam STW_RUN = 'h0, STW_WAIT = 'h1;
reg [NUM:0] wgrant_reg;
reg         stateW = STW_RUN;

always @ (posedge AXI_CLK) begin
    if (!AXI_RSTn) begin
        wgrant_reg  <= 'h0;
        stateW      <= STW_RUN;
    end else begin
        case (stateW)
        STW_RUN: begin
             if (|WGRANT) begin
                if (~|(WGRANT & WREADY/* & RLAST*/)) begin
                    wgrant_reg <= WGRANT;
                    stateW     <= STW_WAIT;
                end
             end
             end // STR_RUN
        STW_WAIT: begin
             if (|(WGRANT & WVALID & WREADY/* & RLAST*/)) begin
                //  wgrant_reg <= 'h0;
                 stateW     <= STW_RUN;
             end
             end // STR_WAIT
        endcase
    end
end

wire [2:0] WREQ;
wire [2:0] w_sel;

assign WREQ = WSELECT & WVALID;

// round_robin_m2s u_arbiter_w(
// .clk    (AXI_CLK ),
// .rst_n  (AXI_RSTn),
// .req    (WREQ    ),
// .sel    (w_sel   ) 
// );
rr_fixed_arbiter u_arbiter_w(
.clk          (AXI_CLK      ),
.rst_n        (AXI_RSTn     ),
.arbiter_type (arbiter_type ),
.req          ({1'b0, WREQ} ),
.sel          (w_sel        ) 
);

assign WGRANT = (stateW==STW_RUN) ? w_sel : wgrant_reg;

endmodule