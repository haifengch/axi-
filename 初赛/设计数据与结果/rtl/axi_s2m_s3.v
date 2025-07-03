
module axi_s2m_s3
#(parameter MASTER_ID   = 0            // for reference
          , W_CID       = 4            // Channel ID width
          , W_ID        = 4            // ID width
          , W_ADDR      = 32           // address width
          , W_DATA      = 32           // data width
          , W_STRB      = (W_DATA/8)   // data strobe width
          , W_SID       = W_CID+W_ID   // slave ID
 )
(
      input   wire                      AXI_RSTn
    , input   wire                      AXI_CLK

    , input   wire  [2-1:0]             M_MID
    , output  reg   [W_ID-1:0]          M_BID
    , output  reg   [ 1:0]              M_BRESP
    , output  reg                       M_BVALID
    , input   wire                      M_BREADY
    , output  reg   [W_SID-1:0]         M_RSID
    , output  reg   [W_DATA-1:0]        M_RDATA
    , output  reg   [ 1:0]              M_RRESP
    , output  reg                       M_RLAST
    , output  reg                       M_RVALID
    , input   wire                      M_RREADY

    , input   wire   [W_SID-1:0]        S0_BID
    , input   wire   [ 1:0]             S0_BRESP
    , input   wire                      S0_BVALID
    , output  wire                      S0_BREADY
    , input   wire   [W_SID-1:0]        S0_RID
    , input   wire   [W_DATA-1:0]       S0_RDATA
    , input   wire   [ 1:0]             S0_RRESP
    , input   wire                      S0_RLAST
    , input   wire                      S0_RVALID
    , output  wire                      S0_RREADY

    , input   wire   [W_SID-1:0]        S1_BID
    , input   wire   [ 1:0]             S1_BRESP
    , input   wire                      S1_BVALID
    , output  wire                      S1_BREADY
    , input   wire   [W_SID-1:0]        S1_RID
    , input   wire   [W_DATA-1:0]       S1_RDATA
    , input   wire   [ 1:0]             S1_RRESP
    , input   wire                      S1_RLAST
    , input   wire                      S1_RVALID
    , output  wire                      S1_RREADY

    , input   wire   [W_SID-1:0]        S2_BID
    , input   wire   [ 1:0]             S2_BRESP
    , input   wire                      S2_BVALID
    , output  wire                      S2_BREADY
    , input   wire   [W_SID-1:0]        S2_RID
    , input   wire   [W_DATA-1:0]       S2_RDATA
    , input   wire   [ 1:0]             S2_RRESP
    , input   wire                      S2_RLAST
    , input   wire                      S2_RVALID
    , output  wire                      S2_RREADY

    , input   wire   [W_SID-1:0]        SD_BID
    , input   wire   [ 1:0]             SD_BRESP
    , input   wire                      SD_BVALID
    , output  wire                      SD_BREADY
    , input   wire   [W_SID-1:0]        SD_RID
    , input   wire   [W_DATA-1:0]       SD_RDATA
    , input   wire   [ 1:0]             SD_RRESP
    , input   wire                      SD_RLAST
    , input   wire                      SD_RVALID
    , output  wire                      SD_RREADY

    , input wire [2:0]                  r_order_grant
);

localparam NUM=3;

wire [NUM:0] BSELECT, RSELECT;
wire [NUM:0] RSELECT_in;
wire [NUM:0] BGRANT, RGRANT;

//-------------------decode-------------------------
assign BSELECT[0] = (S0_BID[W_ID+1:W_ID] == M_MID);
assign BSELECT[1] = (S1_BID[W_ID+1:W_ID] == M_MID);
assign BSELECT[2] = (S2_BID[W_ID+1:W_ID] == M_MID);
assign BSELECT[3] = (SD_BID[W_ID+1:W_ID] == M_MID);

assign RSELECT[0] = (S0_RID[W_ID+1:W_ID] == M_MID);//2-bit MID
assign RSELECT[1] = (S1_RID[W_ID+1:W_ID] == M_MID);
assign RSELECT[2] = (S2_RID[W_ID+1:W_ID] == M_MID);
assign RSELECT[3] = (SD_RID[W_ID+1:W_ID] == M_MID);

assign RSELECT_in = RSELECT & {1'b1,r_order_grant};

//-------------arbiter-----------------------
axi_arbiter_s2m_s3 #(.NUM(NUM))
u_axi_arbiter_stom_s3 (
    .AXI_RSTn (AXI_RSTn  )
  , .AXI_CLK  (AXI_CLK   )

  , .BSELECT  (BSELECT)
  , .BVALID   ({SD_BVALID,S2_BVALID,S1_BVALID,S0_BVALID})
  , .BREADY   ({SD_BREADY,S2_BREADY,S1_BREADY,S0_BREADY})
  , .BGRANT   (BGRANT )

  , .RSELECT  (RSELECT_in)
  , .RVALID   ({SD_RVALID,S2_RVALID,S1_RVALID,S0_RVALID})
  , .RREADY   ({SD_RREADY,S2_RREADY,S1_RREADY,S0_RREADY})
  , .RLAST    ({SD_RLAST,S2_RLAST,S1_RLAST,S0_RLAST})
  , .RGRANT   (RGRANT )
);

localparam NUM_B_WIDTH = W_ID+2+1 ; // M_BID M_BRESP M_BVALID
localparam NUM_R_WIDTH = W_SID+W_DATA+2+1+1; // M_RSID M_RDATA M_RRESP M_RLAST M_RVALID

wire [NUM_B_WIDTH-1:0] bus_b [0:NUM];
wire [NUM_R_WIDTH-1:0] bus_r [0:NUM];

assign bus_b[0] = {  S0_BID[W_ID-1:0], S0_BRESP, S0_BVALID};
assign bus_b[1] = {  S1_BID[W_ID-1:0], S1_BRESP, S1_BVALID};
assign bus_b[2] = {  S2_BID[W_ID-1:0], S2_BRESP, S2_BVALID};
assign bus_b[NUM] = {SD_BID[W_ID-1:0], SD_BRESP, SD_BVALID};

assign bus_r[0] = {  S0_RID, S0_RDATA, S0_RRESP, S0_RLAST, S0_RVALID};
assign bus_r[1] = {  S1_RID, S1_RDATA, S1_RRESP, S1_RLAST, S1_RVALID};
assign bus_r[2] = {  S2_RID, S2_RDATA, S2_RRESP, S2_RLAST, S2_RVALID};
assign bus_r[NUM] = {SD_RID, SD_RDATA, SD_RRESP, SD_RLAST, SD_RVALID};

//---------------------------router------------------------
`define M_BBUS {M_BID[W_ID-1:0], M_BRESP, M_BVALID }
always @ ( BGRANT, bus_b[0], bus_b[1], bus_b[2], bus_b[NUM] ) begin
    case (BGRANT)
        4'h1:   `M_BBUS = bus_b[0];
        4'h2:   `M_BBUS = bus_b[1];
        4'h4:   `M_BBUS = bus_b[2];
        4'h8:   `M_BBUS = bus_b[NUM];
        default:`M_BBUS = 'h0;
    endcase
end

`define M_RBUS {M_RSID, M_RDATA, M_RRESP, M_RLAST, M_RVALID}
always @ ( RGRANT, bus_r[0], bus_r[1], bus_r[2], bus_r[NUM] ) begin
    case (RGRANT)
        4'h1:   `M_RBUS = bus_r[0];
        4'h2:   `M_RBUS = bus_r[1];
        4'h4:   `M_RBUS = bus_r[2];
        4'h8:   `M_RBUS = bus_r[NUM];
        default:`M_RBUS = 'h0;
    endcase
end

assign S0_BREADY = BGRANT[0]   & M_BREADY;
assign S1_BREADY = BGRANT[1]   & M_BREADY;
assign S2_BREADY = BGRANT[2]   & M_BREADY;
assign SD_BREADY = BGRANT[NUM] & M_BREADY;

assign S0_RREADY = RGRANT[0]   & M_RREADY;
assign S1_RREADY = RGRANT[1]   & M_RREADY;
assign S2_RREADY = RGRANT[2]   & M_RREADY;
assign SD_RREADY = RGRANT[NUM] & M_RREADY;
endmodule