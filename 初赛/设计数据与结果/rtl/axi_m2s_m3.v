//---------------------------------------------------------------------------
module axi_m2s_m3
#(parameter SLAVE_ID      = 0             // for reference
          , ADDR_BASE     = 32'h0
          , ADDR_LENGTH   = 12            // effective addre bits
          , W_CID         = 4             // Channel ID width
          , W_ID          = 4             // ID width
          , W_ADDR        = 32            // address width
          , W_DATA        = 32            // data width
          , W_STRB        = (W_DATA/8)    // data strobe width
          , W_SID         = W_CID+W_ID    // slave ID
          , NUM_MASTER    = 3
          , SLAVE_DEFAULT = 1'b0  // default-salve when 1
 )
(
       input   wire                      AXI_RSTn
     , input   wire                      AXI_CLK

     , input   wire  [2-1:0]             M0_MID
     , input   wire  [W_ID-1:0]          M0_AWID
     , input   wire  [W_ADDR-1:0]        M0_AWADDR
     , input   wire  [7:0]               M0_AWLEN
     , input   wire  [2:0]               M0_AWSIZE
     , input   wire  [1:0]               M0_AWBURST
     , input   wire                      M0_AWVALID
     , output  wire                      M0_AWREADY
     , input   wire  [W_ID-1:0]          M0_WID
     , input   wire  [W_DATA-1:0]        M0_WDATA
     , input   wire  [W_STRB-1:0]        M0_WSTRB
     , input   wire                      M0_WLAST
     , input   wire                      M0_WVALID
     , output  wire                      M0_WREADY
     , input   wire  [W_ID-1:0]          M0_ARID
     , input   wire  [W_ADDR-1:0]        M0_ARADDR
     , input   wire  [7:0]               M0_ARLEN
     , input   wire  [2:0]               M0_ARSIZE
     , input   wire  [1:0]               M0_ARBURST
     , input   wire                      M0_ARVALID
     , output  wire                      M0_ARREADY

     , input   wire  [2-1:0]             M1_MID
     , input   wire  [W_ID-1:0]          M1_AWID
     , input   wire  [W_ADDR-1:0]        M1_AWADDR
     , input   wire  [7:0]               M1_AWLEN
     , input   wire  [2:0]               M1_AWSIZE
     , input   wire  [1:0]               M1_AWBURST
     , input   wire                      M1_AWVALID
     , output  wire                      M1_AWREADY
     , input   wire  [W_ID-1:0]          M1_WID
     , input   wire  [W_DATA-1:0]        M1_WDATA
     , input   wire  [W_STRB-1:0]        M1_WSTRB
     , input   wire                      M1_WLAST
     , input   wire                      M1_WVALID
     , output  wire                      M1_WREADY
     , input   wire  [W_ID-1:0]          M1_ARID
     , input   wire  [W_ADDR-1:0]        M1_ARADDR
     , input   wire  [7:0]               M1_ARLEN
     , input   wire  [2:0]               M1_ARSIZE
     , input   wire  [1:0]               M1_ARBURST
     , input   wire                      M1_ARVALID
     , output  wire                      M1_ARREADY

     , input   wire  [2-1:0]             M2_MID
     , input   wire  [W_ID-1:0]          M2_AWID
     , input   wire  [W_ADDR-1:0]        M2_AWADDR
     , input   wire  [7:0]               M2_AWLEN
     , input   wire  [2:0]               M2_AWSIZE
     , input   wire  [1:0]               M2_AWBURST
     , input   wire                      M2_AWVALID
     , output  wire                      M2_AWREADY
     , input   wire  [W_ID-1:0]          M2_WID
     , input   wire  [W_DATA-1:0]        M2_WDATA
     , input   wire  [W_STRB-1:0]        M2_WSTRB
     , input   wire                      M2_WLAST
     , input   wire                      M2_WVALID
     , output  wire                      M2_WREADY
     , input   wire  [W_ID-1:0]          M2_ARID
     , input   wire  [W_ADDR-1:0]        M2_ARADDR
     , input   wire  [7:0]               M2_ARLEN
     , input   wire  [2:0]               M2_ARSIZE
     , input   wire  [1:0]               M2_ARBURST
     , input   wire                      M2_ARVALID
     , output  wire                      M2_ARREADY

     , output  reg    [W_SID-1:0]        S_AWID
     , output  reg    [W_ADDR-1:0]       S_AWADDR
     , output  reg    [7:0]              S_AWLEN
     , output  reg    [2:0]              S_AWSIZE
     , output  reg    [1:0]              S_AWBURST
     , output  reg                       S_AWVALID
     , input   wire                      S_AWREADY
     , output  reg    [W_SID-1:0]        S_WID
     , output  reg    [W_DATA-1:0]       S_WDATA
     , output  reg    [W_STRB-1:0]       S_WSTRB
     , output  reg                       S_WLAST
     , output  reg                       S_WVALID
     , input   wire                      S_WREADY
     , output  reg    [W_SID-1:0]        S_ARID
     , output  reg    [W_ADDR-1:0]       S_ARADDR
     , output  reg    [7:0]              S_ARLEN
     , output  reg    [2:0]              S_ARSIZE
     , output  reg    [1:0]              S_ARBURST
     , output  reg                       S_ARVALID
     , input   wire                      S_ARREADY

     , output  wire  [NUM_MASTER-1:0]    AWSELECT_OUT
     , output  wire  [NUM_MASTER-1:0]    ARSELECT_OUT
     , input   wire  [NUM_MASTER-1:0]    AWSELECT_IN
     , input   wire  [NUM_MASTER-1:0]    ARSELECT_IN

     , input   wire  [2:0]               w_order_grant
);

reg  [NUM_MASTER-1:0] AWSELECT  ;
reg  [NUM_MASTER-1:0] ARSELECT  ;
reg  [NUM_MASTER-1:0] WSELECT   ;
wire [2:0]            WSELECT_in;
wire [NUM_MASTER-1:0] AWGRANT, WGRANT, ARGRANT;

assign  AWSELECT_OUT = AWSELECT;
assign  ARSELECT_OUT = ARSELECT;

//-----------------------decode------------------------------------
always @ ( * ) begin
 if (SLAVE_DEFAULT=='h0) begin
     AWSELECT[0] = (M0_AWADDR[W_ADDR-1 : ADDR_LENGTH] == ADDR_BASE[W_ADDR-1 : ADDR_LENGTH]);
     AWSELECT[1] = (M1_AWADDR[W_ADDR-1 : ADDR_LENGTH] == ADDR_BASE[W_ADDR-1 : ADDR_LENGTH]);
     AWSELECT[2] = (M2_AWADDR[W_ADDR-1 : ADDR_LENGTH] == ADDR_BASE[W_ADDR-1 : ADDR_LENGTH]);

     WSELECT[0]  = (M0_WID[3 : 2] == ADDR_BASE[14 : 13] + 1'b1);
     WSELECT[1]  = (M1_WID[3 : 2] == ADDR_BASE[14 : 13] + 1'b1);
     WSELECT[2]  = (M2_WID[3 : 2] == ADDR_BASE[14 : 13] + 1'b1);
  
     ARSELECT[0] = (M0_ARADDR[W_ADDR-1 : ADDR_LENGTH] == ADDR_BASE[W_ADDR-1 : ADDR_LENGTH]);
     ARSELECT[1] = (M1_ARADDR[W_ADDR-1 : ADDR_LENGTH] == ADDR_BASE[W_ADDR-1 : ADDR_LENGTH]);
     ARSELECT[2] = (M2_ARADDR[W_ADDR-1 : ADDR_LENGTH] == ADDR_BASE[W_ADDR-1 : ADDR_LENGTH]);
 end else begin
     AWSELECT = ~AWSELECT_IN & {M2_AWVALID,M1_AWVALID,M0_AWVALID};
     ARSELECT = ~ARSELECT_IN & {M2_ARVALID,M1_ARVALID,M0_ARVALID};
 end
end

assign WSELECT_in = WSELECT & w_order_grant;

wire [NUM_MASTER-1:0] AWVALID_ALL = {M2_AWVALID  , M1_AWVALID  , M0_AWVALID  };
wire [NUM_MASTER-1:0] AWREADY_ALL = {M2_AWREADY  , M1_AWREADY  , M0_AWREADY  };

wire [NUM_MASTER-1:0] ARVALID_ALL = {M2_ARVALID  , M1_ARVALID  , M0_ARVALID  };
wire [NUM_MASTER-1:0] ARREADY_ALL = {M2_ARREADY  , M1_ARREADY  , M0_ARREADY  };

wire [NUM_MASTER-1:0] WVALID_ALL  = {M2_WVALID   , M1_WVALID   , M0_WVALID   };
wire [NUM_MASTER-1:0] WREADY_ALL  = {M2_WREADY   , M1_WREADY   , M0_WREADY   };
wire [NUM_MASTER-1:0] WLAST_ALL   = {M2_WLAST    , M1_WLAST    , M0_WLAST    };

//----------------------arbiter-------------------------
axi_arbiter_m2s_m3 #( .W_CID (W_CID)
                     , .W_ID (W_ID )
                   )
u_axi_arbiter_m2s_m3 (
    .AXI_RSTn (AXI_RSTn          ) //input
  , .AXI_CLK  (AXI_CLK           ) //input

  , .AWSELECT (AWSELECT          ) //input
  , .AWVALID  (AWVALID_ALL       ) //input
  , .AWREADY  (AWREADY_ALL       ) //input 
  , .AWGRANT  (AWGRANT           ) //output

  , .WSELECT  (WSELECT_in        )
  , .WVALID   (WVALID_ALL        ) //input
  , .WREADY   (WREADY_ALL        ) //input
  , .WLAST    (WLAST_ALL         ) //input
  , .WGRANT   (WGRANT            ) //output

  , .ARSELECT (ARSELECT          ) //input
  , .ARVALID  (ARVALID_ALL       ) //input
  , .ARREADY  (ARREADY_ALL       ) //input
  , .ARGRANT  (ARGRANT           ) //output

);

localparam NUM_AW_WIDTH = W_SID + W_ADDR + 8 + 3 + 2 + 1;  //S_AWID S_AWADDR S_AWLEN S_AWLOCK S_AWSIZE S_AWBURST S_AWVALID
localparam NUM_W_WIDTH = W_SID + W_DATA + W_STRB + 1 + 1;//S_WID S_WDATA S_WSTRB S_WLAST S_WVALID
localparam NUM_AR_WIDTH = W_SID + W_ADDR + 8 + 3 + 2 + 1;  //S_ARID S_ARADDR S_ARLEN S_ARLOCK S_ARSIZE S_ARBURST S_ARVALID

wire [NUM_AW_WIDTH-1:0] bus_aw [0:NUM_MASTER-1];
wire [NUM_W_WIDTH-1 :0] bus_w  [0:NUM_MASTER-1];
wire [NUM_AR_WIDTH-1:0] bus_ar [0:NUM_MASTER-1];

assign M0_AWREADY = AWGRANT[0] & S_AWREADY;
assign M1_AWREADY = AWGRANT[1] & S_AWREADY;
assign M2_AWREADY = AWGRANT[2] & S_AWREADY;

assign M0_WREADY  = WGRANT [0] & S_WREADY;
assign M1_WREADY  = WGRANT [1] & S_WREADY;
assign M2_WREADY  = WGRANT [2] & S_WREADY;

assign M0_ARREADY = ARGRANT[0] & S_ARREADY;
assign M1_ARREADY = ARGRANT[1] & S_ARREADY;
assign M2_ARREADY = ARGRANT[2] & S_ARREADY;

assign bus_aw[0] = {ADDR_BASE[14:13]+1'b1, M0_MID, M0_AWID, M0_AWADDR, M0_AWLEN, M0_AWSIZE, M0_AWBURST, M0_AWVALID};
assign bus_aw[1] = {ADDR_BASE[14:13]+1'b1, M1_MID, M1_AWID, M1_AWADDR, M1_AWLEN, M1_AWSIZE, M1_AWBURST, M1_AWVALID};
assign bus_aw[2] = {ADDR_BASE[14:13]+1'b1, M2_MID, M2_AWID, M2_AWADDR, M2_AWLEN, M2_AWSIZE, M2_AWBURST, M2_AWVALID};

//Format of S_WID: {2-bit slv_addr}, {2-bit mst_ID}, {4-bit M_WID: 2_bit_slv + 2_bit_ID}
//Possible values : {00, 01, 10    }, {01, 10, 11 }, {2-bit slv: 00, 01, 10; 2-bit ID:01, 10, 11}
assign bus_w[0]  = {M0_WID[3:2], M0_MID, M0_WID, M0_WDATA, M0_WSTRB, M0_WLAST, M0_WVALID};
assign bus_w[1]  = {M1_WID[3:2], M1_MID, M1_WID, M1_WDATA, M1_WSTRB, M1_WLAST, M1_WVALID};
assign bus_w[2]  = {M2_WID[3:2], M2_MID, M2_WID, M2_WDATA, M2_WSTRB, M2_WLAST, M2_WVALID};

//Format of S_ARID: {2-bit slv_addr}, {2-bit mst_ID}, {4-bit M_ARID}
//Possible values : {00, 01, 10    }, {01, 10, 11  }, {4'h1, 4'h2, ..., 4'hf}
assign bus_ar[0] = {ADDR_BASE[14:13]+1'b1, M0_MID, M0_ARID, M0_ARADDR, M0_ARLEN, M0_ARSIZE, M0_ARBURST, M0_ARVALID};
assign bus_ar[1] = {ADDR_BASE[14:13]+1'b1, M1_MID, M1_ARID, M1_ARADDR, M1_ARLEN, M1_ARSIZE, M1_ARBURST, M1_ARVALID};
assign bus_ar[2] = {ADDR_BASE[14:13]+1'b1, M2_MID, M2_ARID, M2_ARADDR, M2_ARLEN, M2_ARSIZE, M2_ARBURST, M2_ARVALID};

//-------------------router--------------------------
`define S_AWBUS {S_AWID, S_AWADDR, S_AWLEN, S_AWSIZE, S_AWBURST, S_AWVALID}
always @ ( AWGRANT, bus_aw[0], bus_aw[1], bus_aw[2] ) begin
     case (AWGRANT)
         3'h1:   `S_AWBUS = bus_aw[0];
         3'h2:   `S_AWBUS = bus_aw[1];
         3'h4:   `S_AWBUS = bus_aw[2];
         default:`S_AWBUS = 'h0;
     endcase
end

`define S_WBUS {S_WID, S_WDATA, S_WSTRB, S_WLAST, S_WVALID}  
always @ ( WGRANT, bus_w[0], bus_w[1], bus_w[2] ) begin
     case (WGRANT)
         3'h1:   `S_WBUS = bus_w[0];
         3'h2:   `S_WBUS = bus_w[1];
         3'h4:   `S_WBUS = bus_w[2];
         default:`S_WBUS = 'h0;
     endcase
end

`define S_ARBUS {S_ARID, S_ARADDR, S_ARLEN, S_ARSIZE, S_ARBURST, S_ARVALID}
always @ ( ARGRANT, bus_ar[0], bus_ar[1], bus_ar[2] ) begin
     case (ARGRANT)
         3'h1:   `S_ARBUS = bus_ar[0];
         3'h2:   `S_ARBUS = bus_ar[1];
         3'h4:   `S_ARBUS = bus_ar[2];
         default:`S_ARBUS = 'h0;
     endcase
end
endmodule