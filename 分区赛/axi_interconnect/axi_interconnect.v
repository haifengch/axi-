`define APB_CFG
module axi_interconnect
      #(parameter W_CID  = 4           // Channel ID width
                , W_ID   = 4           // ID width
                , W_ADDR = 32          // address width
                , W_LEN  = 8           // burst len
                , W_DATA = 32          // data width
                , W_STRB = (W_DATA/8)  // data strobe width
                , W_SID  = (W_CID+W_ID)// slave ID
       )
(
       input   wire                      AXI_RSTn
     , input   wire                      AXI_CLK

    //AXI from master
     , input   wire  [W_ID-1:0]          M_AXI_AWID     [0:2]
     , input   wire  [W_ADDR-1:0]        M_AXI_AWADDR   [0:2]
     , input   wire  [W_LEN-1:0]         M_AXI_AWLEN    [0:2]
     , input   wire  [2:0]               M_AXI_AWSIZE   [0:2]
     , input   wire  [1:0]               M_AXI_AWBURST  [0:2]
     , input   wire                      M_AXI_AWVALID  [0:2]
     , output  wire                      M_AXI_AWREADY  [0:2]

     , input   wire  [W_ID-1:0]          M_AXI_WID      [0:2]
     , input   wire  [W_DATA-1:0]        M_AXI_WDATA    [0:2]
     , input   wire  [W_STRB-1:0]        M_AXI_WSTRB    [0:2]
     , input   wire                      M_AXI_WLAST    [0:2]
     , input   wire                      M_AXI_WVALID   [0:2]
     , output  wire                      M_AXI_WREADY   [0:2]

     , output  wire  [W_ID-1:0]          M_AXI_BID      [0:2]
     , output  wire  [1:0]               M_AXI_BRESP    [0:2]
     , output  wire                      M_AXI_BVALID   [0:2]
     , input   wire                      M_AXI_BREADY   [0:2]

     , input   wire  [W_ID-1:0]          M_AXI_ARID     [0:2]
     , input   wire  [W_ADDR-1:0]        M_AXI_ARADDR   [0:2]
     , input   wire  [W_LEN-1:0]         M_AXI_ARLEN    [0:2]
     , input   wire  [2:0]               M_AXI_ARSIZE   [0:2]
     , input   wire  [1:0]               M_AXI_ARBURST  [0:2]
     , input   wire                      M_AXI_ARVALID  [0:2]
     , output  wire                      M_AXI_ARREADY  [0:2]

     , output  wire  [W_ID-1:0]          M_AXI_RID      [0:2]
     , output  wire  [W_DATA-1:0]        M_AXI_RDATA    [0:2]
     , output  wire  [1:0]               M_AXI_RRESP    [0:2]
     , output  wire                      M_AXI_RLAST    [0:2]
     , output  wire                      M_AXI_RVALID   [0:2]
     , input   wire                      M_AXI_RREADY   [0:2]
     
     //AXI to slaver
     , output  wire   [W_SID-1:0]        S_AXI_AWID     [0:2]
     , output  wire   [W_ADDR-1:0]       S_AXI_AWADDR   [0:2]
     , output  wire   [W_LEN-1:0]        S_AXI_AWLEN    [0:2]
     , output  wire   [2:0]              S_AXI_AWSIZE   [0:2]
     , output  wire   [1:0]              S_AXI_AWBURST  [0:2]
     , output  wire                      S_AXI_AWVALID  [0:2]
     , input   wire                      S_AXI_AWREADY  [0:2]

     , output  wire   [W_SID-1:0]        S_AXI_WID      [0:2]
     , output  wire   [W_DATA-1:0]       S_AXI_WDATA    [0:2]
     , output  wire   [W_STRB-1:0]       S_AXI_WSTRB    [0:2]
     , output  wire                      S_AXI_WLAST    [0:2]
     , output  wire                      S_AXI_WVALID   [0:2]
     , input   wire                      S_AXI_WREADY   [0:2]

     , input   wire   [W_SID-1:0]        S_AXI_BID      [0:2]
     , input   wire   [1:0]              S_AXI_BRESP    [0:2]
     , input   wire                      S_AXI_BVALID   [0:2]
     , output  wire                      S_AXI_BREADY   [0:2]

     , output  wire   [W_SID-1:0]        S_AXI_ARID     [0:2]
     , output  wire   [W_ADDR-1:0]       S_AXI_ARADDR   [0:2]
     , output  wire   [W_LEN-1:0]        S_AXI_ARLEN    [0:2]
     , output  wire   [2:0]              S_AXI_ARSIZE   [0:2]
     , output  wire   [1:0]              S_AXI_ARBURST  [0:2]
     , output  wire                      S_AXI_ARVALID  [0:2]
     , input   wire                      S_AXI_ARREADY  [0:2]

     , input   wire   [W_SID-1:0]        S_AXI_RID      [0:2]
     , input   wire   [W_DATA-1:0]       S_AXI_RDATA    [0:2]
     , input   wire   [1:0]              S_AXI_RRESP    [0:2]
     , input   wire                      S_AXI_RLAST    [0:2]
     , input   wire                      S_AXI_RVALID   [0:2]
     , output  wire                      S_AXI_RREADY   [0:2]

     //APB config port
     `ifdef APB_CFG
     , input  wire                     pwrite 
     , input  wire                     psel 
     , input  wire                     penable 
     , input  wire    [W_ADDR-1:0]     paddr 
     , input  wire    [W_DATA-1:0]     pwdata 
     , output reg     [W_DATA-1:0]     prdata
     `endif
);

wire [W_ID-1:0]       M_AWID    [0:2] ;
wire [W_ADDR-1:0]     M_AWADDR  [0:2] ;
wire [W_LEN-1:0]      M_AWLEN   [0:2] ;
wire [2:0]            M_AWSIZE  [0:2] ;
wire [1:0]            M_AWBURST [0:2] ;
wire                  M_AWVALID [0:2] ;
wire                  M_AWREADY [0:2] ;
wire [W_ID-1:0]       M_WID     [0:2] ;
wire [W_DATA-1:0]     M_WDATA   [0:2] ;
wire [W_STRB-1:0]     M_WSTRB   [0:2] ;
wire                  M_WLAST   [0:2] ;
wire                  M_WVALID  [0:2] ;
wire                  M_WREADY  [0:2] ;
wire [W_ID-1:0]       M_BID     [0:2] ;
wire [1:0]            M_BRESP   [0:2] ;
wire                  M_BVALID  [0:2] ;
wire                  M_BREADY  [0:2] ;

wire [W_ID-1:0]       M_ARID    [0:2] ;
wire [W_ADDR-1:0]     M_ARADDR  [0:2] ;
wire [W_LEN-1:0]      M_ARLEN   [0:2] ;
wire [2:0]            M_ARSIZE  [0:2] ;
wire [1:0]            M_ARBURST [0:2] ;
wire                  M_ARVALID [0:2] ;
wire                  M_ARREADY [0:2] ;
wire [W_SID-1:0]      M_RSID    [0:2] ;
wire [W_DATA-1:0]     M_RDATA   [0:2] ;
wire [1:0]            M_RRESP   [0:2] ;
wire                  M_RLAST   [0:2] ;
wire                  M_RVALID  [0:2] ;
wire                  M_RREADY  [0:2] ;

wire [W_SID-1:0]      S_AWID    [0:2] ;
wire [W_ADDR-1:0]     S_AWADDR  [0:2] ;
wire [W_LEN-1:0]      S_AWLEN   [0:2] ;
wire [2:0]            S_AWSIZE  [0:2] ;
wire [1:0]            S_AWBURST [0:2] ;
wire                  S_AWVALID [0:2] ;
wire                  S_AWREADY [0:2] ;
wire [W_SID-1:0]      S_WID     [0:2] ;
wire [W_DATA-1:0]     S_WDATA   [0:2] ;
wire [W_STRB-1:0]     S_WSTRB   [0:2] ;
wire                  S_WLAST   [0:2] ;
wire                  S_WVALID  [0:2] ;
wire                  S_WREADY  [0:2] ;
wire [W_SID-1:0]      S_BID     [0:2] ;
wire [1:0]            S_BRESP   [0:2] ;
wire                  S_BVALID  [0:2] ;
wire                  S_BREADY  [0:2] ;

wire [W_SID-1:0]      S_ARID    [0:2] ;
wire [W_ADDR-1:0]     S_ARADDR  [0:2] ;
wire [W_LEN-1:0]      S_ARLEN   [0:2] ;
wire [2:0]            S_ARSIZE  [0:2] ;
wire [1:0]            S_ARBURST [0:2] ;
wire                  S_ARVALID [0:2] ;
wire                  S_ARREADY [0:2] ;
wire [W_SID-1:0]      S_RID     [0:2] ;
wire [W_DATA-1:0]     S_RDATA   [0:2] ;
wire [1:0]            S_RRESP   [0:2] ;
wire                  S_RLAST   [0:2] ;
wire                  S_RVALID  [0:2] ;
wire                  S_RREADY  [0:2] ;

//for cross 4k process
wire      [W_ID-1:0]       c4k_arid    [0:2];
wire      [W_ADDR-1:0]     c4k_araddr  [0:2];
wire      [W_LEN-1:0]      c4k_arlen   [0:2];
wire      [2:0]            c4k_arsize  [0:2];
wire      [1:0]            c4k_arburst [0:2];
wire                       c4k_arvalid [0:2];
wire                       c4k_arready [0:2];
wire      [W_ID-1:0]       c4k_awid    [0:2];
wire      [W_ADDR-1:0]     c4k_awaddr  [0:2];
wire      [W_LEN-1:0]      c4k_awlen   [0:2];
wire      [2:0]            c4k_awsize  [0:2];
wire      [1:0]            c4k_awburst [0:2];
wire                       c4k_awvalid [0:2];
wire                       c4k_awready [0:2];

//-------for r reorder-------
wire [2:0] s_push_srid_rdy    ;
wire [7:0] ar_sid_buffer [0:3];
wire [2:0] r_order_grant      ;

wire       m0_rsid_clr_rdy    ;
wire       m1_rsid_clr_rdy    ;
wire       m2_rsid_clr_rdy    ;

wire [2:0] S_ARREADY_in       ;
wire [2:0] M_RREADY_in        ;

wire [2:0] fifo_ar_sx_vld     ;
wire [2:0] fifo_r_mx_vld      ;


//-------for w reorder-------
wire [2:0] s_push_swid_rdy    ;
wire [7:0] aw_sid_buffer [0:3];
wire [2:0] w_order_grant      ;

wire       s0_wsid_clr_rdy    ;
wire       s1_wsid_clr_rdy    ;
wire       s2_wsid_clr_rdy    ;

wire [2:0] S_AWREADY_in       ;
wire [2:0] S_WREADY_in        ;

wire [2:0] fifo_aw_sx_vld     ;
wire [2:0] fifo_w_sx_vld      ;

//-------for r reorder-------
assign S_ARREADY_in[0] = S_ARREADY[0] & s_push_srid_rdy[0];
assign S_ARREADY_in[1] = S_ARREADY[1] & s_push_srid_rdy[1];
assign S_ARREADY_in[2] = S_ARREADY[2] & s_push_srid_rdy[2];

assign fifo_ar_sx_vld[0] = S_ARVALID[0] & s_push_srid_rdy[0];
assign fifo_ar_sx_vld[1] = S_ARVALID[1] & s_push_srid_rdy[1];
assign fifo_ar_sx_vld[2] = S_ARVALID[2] & s_push_srid_rdy[2];

assign M_RREADY_in[0] = M_RREADY[0] & m0_rsid_clr_rdy;
assign M_RREADY_in[1] = M_RREADY[1] & m1_rsid_clr_rdy;
assign M_RREADY_in[2] = M_RREADY[2] & m2_rsid_clr_rdy;

assign fifo_r_mx_vld[0]  = M_RVALID[0] & m0_rsid_clr_rdy;
assign fifo_r_mx_vld[1]  = M_RVALID[1] & m1_rsid_clr_rdy;
assign fifo_r_mx_vld[2]  = M_RVALID[2] & m2_rsid_clr_rdy;

//-------for w reorder-------
assign S_AWREADY_in[0] = S_AWREADY[0] & s_push_swid_rdy[0];
assign S_AWREADY_in[1] = S_AWREADY[1] & s_push_swid_rdy[1];
assign S_AWREADY_in[2] = S_AWREADY[2] & s_push_swid_rdy[2];

assign fifo_aw_sx_vld[0] = S_AWVALID[0] & s_push_swid_rdy[0];
assign fifo_aw_sx_vld[1] = S_AWVALID[1] & s_push_swid_rdy[1];
assign fifo_aw_sx_vld[2] = S_AWVALID[2] & s_push_swid_rdy[2];

assign S_WREADY_in[0] = S_WREADY[0] & s0_wsid_clr_rdy;
assign S_WREADY_in[1] = S_WREADY[1] & s1_wsid_clr_rdy;
assign S_WREADY_in[2] = S_WREADY[2] & s2_wsid_clr_rdy;

assign fifo_w_sx_vld[0]  = S_WVALID[0] & s0_wsid_clr_rdy;
assign fifo_w_sx_vld[1]  = S_WVALID[1] & s1_wsid_clr_rdy;
assign fifo_w_sx_vld[2]  = S_WVALID[2] & s2_wsid_clr_rdy;

`ifdef APB_CFG
//---------for apb config---------------
wire [2:0] aw_decode_err;
wire [2:0] ar_decode_err;
wire       arbiter_type ;
wire       slaver0_en;
wire       slaver1_en;
wire       slaver2_en;
`endif

genvar i;
//--------------------CROSS 4K PROCESS---------------

generate
    for (i = 0; i < 3; i++) begin:mx_cross_4k_if
        cross_4k_if #()
        mx_cross_4k_if(
            .clk                       (AXI_CLK         ),
            .rst_n                     (AXI_RSTn        ),
            // input
            .m_axi_arid                (M_AXI_ARID   [i]),
            .m_axi_araddr              (M_AXI_ARADDR [i]),
            .m_axi_arlen               (M_AXI_ARLEN  [i]),
            .m_axi_arsize              (M_AXI_ARSIZE [i]),
            .m_axi_arburst             (M_AXI_ARBURST[i]),
            .m_axi_arvalid             (M_AXI_ARVALID[i]),
            .m_axi_arready             (M_AXI_ARREADY[i]),

            .m_axi_awid                (M_AXI_AWID   [i]),
            .m_axi_awaddr              (M_AXI_AWADDR [i]),
            .m_axi_awlen               (M_AXI_AWLEN  [i]),
            .m_axi_awsize              (M_AXI_AWSIZE [i]),
            .m_axi_awburst             (M_AXI_AWBURST[i]),
            .m_axi_awvalid             (M_AXI_AWVALID[i]),
            .m_axi_awready             (M_AXI_AWREADY[i]),
            // output
            .s_axi_arid                (c4k_arid   [i]  ),
            .s_axi_araddr              (c4k_araddr [i]  ),
            .s_axi_arlen               (c4k_arlen  [i]  ),
            .s_axi_arsize              (c4k_arsize [i]  ),
            .s_axi_arburst             (c4k_arburst[i]  ),
            .s_axi_arvalid             (c4k_arvalid[i]  ),
            .s_axi_arready             (c4k_arready[i]  ),

            .s_axi_awid                (c4k_awid   [i]  ),
            .s_axi_awaddr              (c4k_awaddr [i]  ),
            .s_axi_awlen               (c4k_awlen  [i]  ),
            .s_axi_awsize              (c4k_awsize [i]  ),
            .s_axi_awburst             (c4k_awburst[i]  ),
            .s_axi_awvalid             (c4k_awvalid[i]  ),
            .s_axi_awready             (c4k_awready[i]  )
        );
    end
endgenerate

//---------------------AR_* fifo----------------------
//axi_interconnect slave interface, signals from mst
generate
    for (i = 0; i < 3; i = i + 1) begin:fifo_ar_mx
        axi_fifo_sync #(.FDW(4+32+8+3+2), .FAW(2)) //fifo depth == 4
        u_fifo_ar_mx(
              .rstn     (AXI_RSTn)
            , .clr      (1'b0   )
            , .clk      (AXI_CLK   )
            , .wr_rdy   (c4k_arready[i])
            , .wr_vld   (c4k_arvalid[i])
            , .wr_din   ({c4k_arid[i], c4k_araddr[i], c4k_arlen[i], c4k_arsize[i], c4k_arburst[i]})
            , .rd_rdy   (M_ARREADY[i])
            , .rd_vld   (M_ARVALID[i])
            , .rd_dout  ({M_ARID[i], M_ARADDR[i], M_ARLEN[i], M_ARSIZE[i], M_ARBURST[i]})
        );
    end
endgenerate
//axi_interconnect master interface, signals to slv
generate
    for (i = 0; i < 3; i = i + 1) begin:fifo_ar_sx
        axi_fifo_sync #(.FDW(8+32+8+3+2), .FAW(2))
        u_fifo_ar_sx(
              .rstn     (AXI_RSTn)
            , .clr      (1'b0   )
            , .clk      (AXI_CLK   )
            , .wr_rdy   (S_ARREADY[i])
            , .wr_vld   (fifo_ar_sx_vld[i])
            , .wr_din   ({S_ARID[i], S_ARADDR[i], S_ARLEN[i], S_ARSIZE[i], S_ARBURST[i]})
            , .rd_rdy   (S_AXI_ARREADY[i])
            , .rd_vld   (S_AXI_ARVALID[i])
            , .rd_dout  ({S_AXI_ARID[i], S_AXI_ARADDR[i], S_AXI_ARLEN[i], S_AXI_ARSIZE[i], S_AXI_ARBURST[i]})
        );
    end
endgenerate
//---------------------R_* fifo----------------------
//axi_interconnect slave interface, signals from slv
generate
    for (i = 0; i < 3; i = i + 1) begin:fifo_r_sx
        axi_fifo_sync #(.FDW(8+32+2+1), .FAW(2))
        u_fifo_r_sx(
              .rstn     (AXI_RSTn)
            , .clr      (1'b0   )
            , .clk      (AXI_CLK   )
            , .wr_rdy   (S_AXI_RREADY[i])
            , .wr_vld   (S_AXI_RVALID[i])
            , .wr_din   ({S_AXI_RID[i], S_AXI_RDATA[i], S_AXI_RRESP[i], S_AXI_RLAST[i]})
            , .rd_rdy   (S_RREADY[i])
            , .rd_vld   (S_RVALID[i])
            , .rd_dout  ({S_RID[i], S_RDATA[i], S_RRESP[i], S_RLAST[i]})
        );
    end
endgenerate
//axi_interconnect master interface, signals to mst
generate
    for (i = 0; i < 3; i = i + 1) begin:fifo_r_mx
        axi_fifo_sync #(.FDW(4+32+2+1), .FAW(2))
        u_fifo_r_mx(
            .rstn     (AXI_RSTn)
          , .clr      (1'b0   )
          , .clk      (AXI_CLK   )
          , .wr_rdy   (M_RREADY[i])
          , .wr_vld   (fifo_r_mx_vld[i])
          , .wr_din   ({M_RSID[i][3:0], M_RDATA[i], M_RRESP[i], M_RLAST[i]})
          , .rd_rdy   (M_AXI_RREADY[i])
          , .rd_vld   (M_AXI_RVALID[i])
          , .rd_dout  ({M_AXI_RID[i], M_AXI_RDATA[i], M_AXI_RRESP[i], M_AXI_RLAST[i]})
      );
    end
endgenerate


//---------------------AW_* fifo----------------------
//axi slave interface, signals from master
generate
    for (i = 0; i < 3; i = i + 1) begin:fifo_aw_mx
        axi_fifo_sync #(.FDW(4+32+8+3+2), .FAW(2))
        u_fifo_aw_mx(
              .rstn     (AXI_RSTn)
            , .clr      (1'b0   )
            , .clk      (AXI_CLK   )
            , .wr_rdy   (c4k_awready[i])
            , .wr_vld   (c4k_awvalid[i])
            , .wr_din   ({c4k_awid[i], c4k_awaddr[i], c4k_awlen[i], c4k_awsize[i], c4k_awburst[i]})

            , .rd_rdy   (M_AWREADY[i])
            , .rd_vld   (M_AWVALID[i])
            , .rd_dout  ({M_AWID[i], M_AWADDR[i], M_AWLEN[i], M_AWSIZE[i], M_AWBURST[i]})
        );
    end
endgenerate
//axi master interface, signals to slaver
generate
    for (i = 0; i < 3; i = i + 1) begin:fifo_aw_sx
        axi_fifo_sync #(.FDW(8+32+8+3+2), .FAW(2))
        u_fifo_aw_sx(
              .rstn     (AXI_RSTn)
            , .clr      (1'b0   )
            , .clk      (AXI_CLK   )
            , .wr_rdy   (S_AWREADY[i])
            , .wr_vld   (fifo_aw_sx_vld[i]/*S_AWVALID[i]*/)
            , .wr_din   ({S_AWID[i], S_AWADDR[i], S_AWLEN[i], S_AWSIZE[i], S_AWBURST[i]})
            , .rd_rdy   (S_AXI_AWREADY[i])
            , .rd_vld   (S_AXI_AWVALID[i])
            , .rd_dout  ({S_AXI_AWID[i], S_AXI_AWADDR[i], S_AXI_AWLEN[i], S_AXI_AWSIZE[i], S_AXI_AWBURST[i]})
        );
    end
endgenerate

//---------------------W_* fifo----------------------
generate
    for (i = 0; i < 3; i = i + 1) begin:fifo_w_mx
        axi_fifo_sync #(.FDW(4+32+4+1), .FAW(2))
        u_fifo_w_mx(
              .rstn     (AXI_RSTn)
            , .clr      (1'b0   )
            , .clk      (AXI_CLK   )
            , .wr_rdy   (M_AXI_WREADY[i])
            , .wr_vld   (M_AXI_WVALID[i])
            , .wr_din   ({M_AXI_WID[i], M_AXI_WDATA[i], M_AXI_WSTRB[i], M_AXI_WLAST[i]})
            , .rd_rdy   (M_WREADY[i])
            , .rd_vld   (M_WVALID[i])
            , .rd_dout  ({M_WID[i], M_WDATA[i], M_WSTRB[i], M_WLAST[i]})
        );
    end
endgenerate
generate
    for (i = 0; i < 3; i = i + 1) begin:fifo_w_sx
        axi_fifo_sync #(.FDW(8+32+4+1), .FAW(2))
        u_fifo_w_sx(
              .rstn     (AXI_RSTn)
            , .clr      (1'b0   )
            , .clk      (AXI_CLK   )
            , .wr_rdy   (S_WREADY[i])
            , .wr_vld   (fifo_w_sx_vld[i]/*S_WVALID[i]*/)
            , .wr_din   ({S_WID[i], S_WDATA[i], S_WSTRB[i], S_WLAST[i]})
            , .rd_rdy   (S_AXI_WREADY[i])
            , .rd_vld   (S_AXI_WVALID[i])
            , .rd_dout  ({S_AXI_WID[i], S_AXI_WDATA[i], S_AXI_WSTRB[i], S_AXI_WLAST[i]})
        );
    end
endgenerate

//---------------------B_* fifo----------------------
generate
    for (i = 0; i < 3; i = i + 1) begin:fifo_b_sx
        axi_fifo_sync #(.FDW(8+2), .FAW(2))
        u_fifo_b_sx(
              .rstn     (AXI_RSTn)
            , .clr      (1'b0   )
            , .clk      (AXI_CLK   )
            , .wr_rdy   (S_AXI_BREADY[i])
            , .wr_vld   (S_AXI_BVALID[i])
            , .wr_din   ({S_AXI_BID[i], S_AXI_BRESP[i]})
            , .rd_rdy   (S_BREADY[i])
            , .rd_vld   (S_BVALID[i])
            , .rd_dout  ({S_BID[i], S_BRESP[i]})
        );
    end
endgenerate
generate
    for (i = 0; i < 3; i = i + 1) begin:fifo_b_mx
        axi_fifo_sync #(.FDW(4+2), .FAW(2))
        u_fifo_b_mx(
              .rstn     (AXI_RSTn)
            , .clr      (1'b0   )
            , .clk      (AXI_CLK   )
            , .wr_rdy   (M_BREADY[i])
            , .wr_vld   (M_BVALID[i])
            , .wr_din   ({M_BID[i], M_BRESP[i]})
            , .rd_rdy   (M_AXI_BREADY[i])
            , .rd_vld   (M_AXI_BVALID[i])
            , .rd_dout  ({M_AXI_BID[i], M_AXI_BRESP[i]})
        );
    end
endgenerate

axi_crossbar #(
)
    u_axi_crossbar(
      .AXI_RSTn                           (AXI_RSTn                    )
    , .AXI_CLK                            (AXI_CLK                     )

    , .M0_MID                             (2'b01                       )
    , .M0_AWID                            (M_AWID    [0]               )
    , .M0_AWADDR                          (M_AWADDR  [0]               )
    , .M0_AWLEN                           (M_AWLEN   [0]               )
    , .M0_AWSIZE                          (M_AWSIZE  [0]               )
    , .M0_AWBURST                         (M_AWBURST [0]               )
    , .M0_AWVALID                         (M_AWVALID [0]               )
    , .M0_AWREADY                         (M_AWREADY [0]               )
    , .M0_WID                             (M_WID     [0]               )
    , .M0_WDATA                           (M_WDATA   [0]               )
    , .M0_WSTRB                           (M_WSTRB   [0]               )
    , .M0_WLAST                           (M_WLAST   [0]               )
    , .M0_WVALID                          (M_WVALID  [0]               )
    , .M0_WREADY                          (M_WREADY  [0]               )
    , .M0_BID                             (M_BID     [0]               )
    , .M0_BRESP                           (M_BRESP   [0]               )
    , .M0_BVALID                          (M_BVALID  [0]               )
    , .M0_BREADY                          (M_BREADY  [0]               )

    , .M0_ARID                            (M_ARID    [0]               )
    , .M0_ARADDR                          (M_ARADDR  [0]               )
    , .M0_ARLEN                           (M_ARLEN   [0]               )
    , .M0_ARSIZE                          (M_ARSIZE  [0]               )
    , .M0_ARBURST                         (M_ARBURST [0]               )
    , .M0_ARVALID                         (M_ARVALID [0]               )
    , .M0_ARREADY                         (M_ARREADY [0]               )
    , .M0_RSID                            (M_RSID    [0]               )
    , .M0_RDATA                           (M_RDATA   [0]               )
    , .M0_RRESP                           (M_RRESP   [0]               )
    , .M0_RLAST                           (M_RLAST   [0]               )
    , .M0_RVALID                          (M_RVALID  [0]               )
    , .M0_RREADY                          (M_RREADY_in[0]              )

    , .M1_MID                             (2'b10                       )
    , .M1_AWID                            (M_AWID    [1]               )
    , .M1_AWADDR                          (M_AWADDR  [1]               )
    , .M1_AWLEN                           (M_AWLEN   [1]               )
    , .M1_AWSIZE                          (M_AWSIZE  [1]               )
    , .M1_AWBURST                         (M_AWBURST [1]               )
    , .M1_AWVALID                         (M_AWVALID [1]               )
    , .M1_AWREADY                         (M_AWREADY [1]               )
    , .M1_WID                             (M_WID     [1]               )
    , .M1_WDATA                           (M_WDATA   [1]               )
    , .M1_WSTRB                           (M_WSTRB   [1]               )
    , .M1_WLAST                           (M_WLAST   [1]               )
    , .M1_WVALID                          (M_WVALID  [1]               )
    , .M1_WREADY                          (M_WREADY  [1]               )
    , .M1_BID                             (M_BID     [1]               )
    , .M1_BRESP                           (M_BRESP   [1]               )
    , .M1_BVALID                          (M_BVALID  [1]               )
    , .M1_BREADY                          (M_BREADY  [1]               )

    , .M1_ARID                            (M_ARID    [1]               )
    , .M1_ARADDR                          (M_ARADDR  [1]               )
    , .M1_ARLEN                           (M_ARLEN   [1]               )
    , .M1_ARSIZE                          (M_ARSIZE  [1]               )
    , .M1_ARBURST                         (M_ARBURST [1]               )
    , .M1_ARVALID                         (M_ARVALID [1]               )
    , .M1_ARREADY                         (M_ARREADY [1]               )
    , .M1_RSID                            (M_RSID    [1]               )
    , .M1_RDATA                           (M_RDATA   [1]               )
    , .M1_RRESP                           (M_RRESP   [1]               )
    , .M1_RLAST                           (M_RLAST   [1]               )
    , .M1_RVALID                          (M_RVALID  [1]               )
    , .M1_RREADY                          (M_RREADY_in[1]              )

    , .M2_MID                             (2'b11                       )
    , .M2_AWID                            (M_AWID    [2]               )
    , .M2_AWADDR                          (M_AWADDR  [2]               )
    , .M2_AWLEN                           (M_AWLEN   [2]               )
    , .M2_AWSIZE                          (M_AWSIZE  [2]               )
    , .M2_AWBURST                         (M_AWBURST [2]               )
    , .M2_AWVALID                         (M_AWVALID [2]               )
    , .M2_AWREADY                         (M_AWREADY [2]               )
    , .M2_WID                             (M_WID     [2]               )
    , .M2_WDATA                           (M_WDATA   [2]               )
    , .M2_WSTRB                           (M_WSTRB   [2]               )
    , .M2_WLAST                           (M_WLAST   [2]               )
    , .M2_WVALID                          (M_WVALID  [2]               )
    , .M2_WREADY                          (M_WREADY  [2]               )
    , .M2_BID                             (M_BID     [2]               )
    , .M2_BRESP                           (M_BRESP   [2]               )
    , .M2_BVALID                          (M_BVALID  [2]               )
    , .M2_BREADY                          (M_BREADY  [2]               )

    , .M2_ARID                            (M_ARID    [2]               )
    , .M2_ARADDR                          (M_ARADDR  [2]               )
    , .M2_ARLEN                           (M_ARLEN   [2]               )
    , .M2_ARSIZE                          (M_ARSIZE  [2]               )
    , .M2_ARBURST                         (M_ARBURST [2]               )
    , .M2_ARVALID                         (M_ARVALID [2]               )
    , .M2_ARREADY                         (M_ARREADY [2]               )
    , .M2_RSID                            (M_RSID    [2]               )
    , .M2_RDATA                           (M_RDATA   [2]               )
    , .M2_RRESP                           (M_RRESP   [2]               )
    , .M2_RLAST                           (M_RLAST   [2]               )
    , .M2_RVALID                          (M_RVALID  [2]               )
    , .M2_RREADY                          (M_RREADY_in[2]              )

    , .S0_AWID                            (S_AWID    [0]               )
    , .S0_AWADDR                          (S_AWADDR  [0]               )
    , .S0_AWLEN                           (S_AWLEN   [0]               )
    , .S0_AWSIZE                          (S_AWSIZE  [0]               )
    , .S0_AWBURST                         (S_AWBURST [0]               )
    , .S0_AWVALID                         (S_AWVALID [0]               )
    , .S0_AWREADY                         (S_AWREADY_in[0]             )
    , .S0_WID                             (S_WID     [0]               )
    , .S0_WDATA                           (S_WDATA   [0]               )
    , .S0_WSTRB                           (S_WSTRB   [0]               )
    , .S0_WLAST                           (S_WLAST   [0]               )
    , .S0_WVALID                          (S_WVALID  [0]               )
    , .S0_WREADY                          (S_WREADY_in[0]              )
    , .S0_BID                             (S_BID     [0]               )
    , .S0_BRESP                           (S_BRESP   [0]               )
    , .S0_BVALID                          (S_BVALID  [0]               )
    , .S0_BREADY                          (S_BREADY  [0]               )

    , .S0_ARID                            (S_ARID    [0]               )
    , .S0_ARADDR                          (S_ARADDR  [0]               )
    , .S0_ARLEN                           (S_ARLEN   [0]               )
    , .S0_ARSIZE                          (S_ARSIZE  [0]               )
    , .S0_ARBURST                         (S_ARBURST [0]               )
    , .S0_ARVALID                         (S_ARVALID [0]               )
    , .S0_ARREADY                         (S_ARREADY_in[0]             )
    , .S0_RID                             (S_RID     [0]               )
    , .S0_RDATA                           (S_RDATA   [0]               )
    , .S0_RRESP                           (S_RRESP   [0]               )
    , .S0_RLAST                           (S_RLAST   [0]               )
    , .S0_RVALID                          (S_RVALID  [0]               )
    , .S0_RREADY                          (S_RREADY  [0]               )

    , .S1_AWID                            (S_AWID    [1]               )
    , .S1_AWADDR                          (S_AWADDR  [1]               )
    , .S1_AWLEN                           (S_AWLEN   [1]               )
    , .S1_AWSIZE                          (S_AWSIZE  [1]               )
    , .S1_AWBURST                         (S_AWBURST [1]               )
    , .S1_AWVALID                         (S_AWVALID [1]               )
    , .S1_AWREADY                         (S_AWREADY_in[1]             )
    , .S1_WID                             (S_WID     [1]               )
    , .S1_WDATA                           (S_WDATA   [1]               )
    , .S1_WSTRB                           (S_WSTRB   [1]               )
    , .S1_WLAST                           (S_WLAST   [1]               )
    , .S1_WVALID                          (S_WVALID  [1]               )
    , .S1_WREADY                          (S_WREADY_in[1]              )
    , .S1_BID                             (S_BID     [1]               )
    , .S1_BRESP                           (S_BRESP   [1]               )
    , .S1_BVALID                          (S_BVALID  [1]               )
    , .S1_BREADY                          (S_BREADY  [1]               )
    , .S1_ARID                            (S_ARID    [1]               )
    , .S1_ARADDR                          (S_ARADDR  [1]               )
    , .S1_ARLEN                           (S_ARLEN   [1]               )
    , .S1_ARSIZE                          (S_ARSIZE  [1]               )
    , .S1_ARBURST                         (S_ARBURST [1]               )
    , .S1_ARVALID                         (S_ARVALID [1]               )
    , .S1_ARREADY                         (S_ARREADY_in[1]             )
    , .S1_RID                             (S_RID     [1]               )
    , .S1_RDATA                           (S_RDATA   [1]               )
    , .S1_RRESP                           (S_RRESP   [1]               )
    , .S1_RLAST                           (S_RLAST   [1]               )
    , .S1_RVALID                          (S_RVALID  [1]               )
    , .S1_RREADY                          (S_RREADY  [1]               )

    , .S2_AWID                            (S_AWID    [2]               )
    , .S2_AWADDR                          (S_AWADDR  [2]               )
    , .S2_AWLEN                           (S_AWLEN   [2]               )
    , .S2_AWSIZE                          (S_AWSIZE  [2]               )
    , .S2_AWBURST                         (S_AWBURST [2]               )
    , .S2_AWVALID                         (S_AWVALID [2]               )
    , .S2_AWREADY                         (S_AWREADY_in[2]             )
    , .S2_WID                             (S_WID     [2]               )
    , .S2_WDATA                           (S_WDATA   [2]               )
    , .S2_WSTRB                           (S_WSTRB   [2]               )
    , .S2_WLAST                           (S_WLAST   [2]               )
    , .S2_WVALID                          (S_WVALID  [2]               )
    , .S2_WREADY                          (S_WREADY_in[2]              )
    , .S2_BID                             (S_BID     [2]               )
    , .S2_BRESP                           (S_BRESP   [2]               )
    , .S2_BVALID                          (S_BVALID  [2]               )
    , .S2_BREADY                          (S_BREADY  [2]               )
    , .S2_ARID                            (S_ARID    [2]               )
    , .S2_ARADDR                          (S_ARADDR  [2]               )
    , .S2_ARLEN                           (S_ARLEN   [2]               )
    , .S2_ARSIZE                          (S_ARSIZE  [2]               )
    , .S2_ARBURST                         (S_ARBURST [2]               )
    , .S2_ARVALID                         (S_ARVALID [2]               )
    , .S2_ARREADY                         (S_ARREADY_in[2]             )
    , .S2_RID                             (S_RID     [2]               )
    , .S2_RDATA                           (S_RDATA   [2]               )
    , .S2_RRESP                           (S_RRESP   [2]               )
    , .S2_RLAST                           (S_RLAST   [2]               )
    , .S2_RVALID                          (S_RVALID  [2]               )
    , .S2_RREADY                          (S_RREADY  [2]               )

    , .r_order_grant                      (r_order_grant               ) //input   wire  [7:0]  [0:3]    
    , .w_order_grant                      (w_order_grant               )

`ifdef APB_CFG
    //APB Config
    , .arbiter_type                       (arbiter_type                )
    , .aw_decode_err                      (aw_decode_err               )
    , .ar_decode_err                      (ar_decode_err               )
    , .slaver0_en                         (slaver0_en                  )
    , .slaver1_en                         (slaver1_en                  )
    , .slaver2_en                         (slaver2_en                  )
`endif
);


//{{ ******* READ TRANSACTION REORDER *********
sid_buffer u_ar_sid_buffer(
.clk             (AXI_CLK           ),     //input            
.rstn            (AXI_RSTn          ),     //input  

//--------------Write buffer------------
.s0_axid         (S_ARID    [0]     ),     //input [7:0]      
.s0_axid_vld     (S_ARVALID [0]     ),     //input            
.s0_fifo_rdy     (S_ARREADY [0]     ),     //input            
.s0_push_rdy     (s_push_srid_rdy[0]),     //output           
.s1_axid         (S_ARID    [1]     ),     //input [7:0]      
.s1_axid_vld     (S_ARVALID [1]     ),     //input            
.s1_fifo_rdy     (S_ARREADY [1]     ),     //input            
.s1_push_rdy     (s_push_srid_rdy[1]),     //output           
.s2_axid         (S_ARID    [2]     ),     //input [7:0]      
.s2_axid_vld     (S_ARVALID [2]     ),     //input            
.s2_fifo_rdy     (S_ARREADY [2]     ),     //input            
.s2_push_rdy     (s_push_srid_rdy[2]),     //output           

//------Clean buffer and ajust position--------
.last_0          (M_RLAST [0]       ),     //input            
.sid_0           (M_RSID  [0]       ),     //input [7:0]      
.sid_0_vld       (M_RVALID[0]       ),     //input            
.sid_0_clr_rdy   (m0_rsid_clr_rdy   ),     //output           
.last_1          (M_RLAST [1]       ),     //input            
.sid_1           (M_RSID  [1]       ),     //input [7:0]      
.sid_1_vld       (M_RVALID[1]       ),     //input            
.sid_1_clr_rdy   (m1_rsid_clr_rdy   ),     //output           
.last_2          (M_RLAST [2]       ),     //input            
.sid_2           (M_RSID  [2]       ),     //input [7:0]      
.sid_2_vld       (M_RVALID[2]       ),     //input            
.sid_2_clr_rdy   (m2_rsid_clr_rdy   ),     //output           
.sid_buffer      (ar_sid_buffer     )      //output reg [7:0] [0:3]
);

reorder ar_reorder(
.clk            (AXI_CLK       ),    //input            
.rstn           (AXI_RSTn      ),    //input            
        
.sid_0          (S_RID[0]      ),    //input [7:0]      
.sid_0_vld      (S_RVALID[0]   ),    //input            
.sid_1          (S_RID[1]      ),    //input [7:0]      
.sid_1_vld      (S_RVALID[1]   ),    //input            
.sid_2          (S_RID[2]      ),    //input [7:0]      
.sid_2_vld      (S_RVALID[2]   ),    //input            
.rob_buffer     (ar_sid_buffer ),    //input [7:0] [0:3]
.order_grant    (r_order_grant   )     //output reg [2:0]   
);
//}} ******* READ TRANSACTION REORDER *********


//{{ ******* WRITE TRANSACTION REORDER *********
sid_buffer u_aw_sid_buffer(
.clk           (AXI_CLK      ),     //input            
.rstn          (AXI_RSTn     ),     //input  

//--------------Write buffer------------
.s0_axid         (S_AWID    [0]     ),     //input [7:0]      
.s0_axid_vld     (S_AWVALID [0]     ),     //input            
.s0_fifo_rdy     (S_AWREADY [0]     ),     //input            
.s0_push_rdy     (s_push_swid_rdy[0]),     //output           
.s1_axid         (S_AWID    [1]     ),     //input [7:0]      
.s1_axid_vld     (S_AWVALID [1]     ),     //input            
.s1_fifo_rdy     (S_AWREADY [1]     ),     //input            
.s1_push_rdy     (s_push_swid_rdy[1]),     //output           
.s2_axid         (S_AWID    [2]     ),     //input [7:0]      
.s2_axid_vld     (S_AWVALID [2]     ),     //input            
.s2_fifo_rdy     (S_AWREADY [2]     ),     //input            
.s2_push_rdy     (s_push_swid_rdy[2]),     //output           

//------Clean buffer and ajust position--------
.last_0          (S_WLAST [0]       ),     //input            
.sid_0           (S_WID  [0]        ),     //input [7:0]      
.sid_0_vld       (S_WVALID[0]       ),     //input            
.sid_0_clr_rdy   (s0_wsid_clr_rdy   ),     //output           
.last_1          (S_WLAST [1]       ),     //input            
.sid_1           (S_WID  [1]        ),     //input [7:0]      
.sid_1_vld       (S_WVALID[1]       ),     //input            
.sid_1_clr_rdy   (s1_wsid_clr_rdy   ),     //output           
.last_2          (S_WLAST [2]       ),     //input            
.sid_2           (S_WID  [2]        ),     //input [7:0]      
.sid_2_vld       (S_WVALID[2]       ),     //input            
.sid_2_clr_rdy   (s2_wsid_clr_rdy   ),     //output           
.sid_buffer      (aw_sid_buffer     )      //output reg [7:0] [0:3]
);

reorder aw_reorder(
.clk         (AXI_CLK  ),    //    input            
.rstn        (AXI_RSTn ),    //    input            
        
.sid_0       ({M_WID[0][3:2], 2'b01, M_WID[0]}),    //input [7:0]      
.sid_0_vld   (M_WVALID[0]                     ),    //input            
.sid_1       ({M_WID[1][3:2], 2'b10, M_WID[1]}),    //input [7:0]      
.sid_1_vld   (M_WVALID[1]                     ),    //input            
.sid_2       ({M_WID[2][3:2], 2'b11, M_WID[2]}),    //input [7:0]      
.sid_2_vld   (M_WVALID[2]                     ),    //input            
.rob_buffer  (aw_sid_buffer                   ),    //input [7:0] [0:3]
.order_grant (w_order_grant                   )     //output reg [2:0]   
);
//}} ******* WRITE TRANSACTION REORDER *********

`ifdef APB_CFG
wire [31:0] aw_count, ar_count;
assign aw_count = |aw_sid_buffer[0] + |aw_sid_buffer[1] + |aw_sid_buffer[2] + |aw_sid_buffer[3];
assign ar_count = |ar_sid_buffer[0] + |ar_sid_buffer[1] + |ar_sid_buffer[2] + |ar_sid_buffer[3];
apb_regs_cfg u_apb_cfg(
      .clk                  (AXI_CLK )
    , .rst_n                (AXI_RSTn)
    
    , .pwrite               (pwrite  )
    , .psel                 (psel    )
    , .penable              (penable )
    , .paddr                (paddr   )
    , .pwdata               (pwdata  )
    , .prdata               (prdata  )
 
    , .aw_decode_err_reg    (|aw_decode_err  )
    , .ar_decode_err_reg    (|ar_decode_err  )
    , .aw_sid_buffer3       (aw_sid_buffer[3])
    , .aw_sid_buffer2       (aw_sid_buffer[2])
    , .aw_sid_buffer1       (aw_sid_buffer[1])
    , .aw_sid_buffer0       (aw_sid_buffer[0])
    , .ar_sid_buffer3       (ar_sid_buffer[3])
    , .ar_sid_buffer2       (ar_sid_buffer[2])
    , .ar_sid_buffer1       (ar_sid_buffer[1])
    , .ar_sid_buffer0       (ar_sid_buffer[0])
    , .aw_transation_count  (aw_count        )
    , .ar_transation_count  (ar_count        )
    , .arbiter_type         (arbiter_type    )
    , .slaver2_en           (slaver2_en      )
    , .slaver1_en           (slaver1_en      )
    , .slaver0_en           (slaver0_en      )
);
`endif
endmodule
