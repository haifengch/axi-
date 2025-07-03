//---------------------------------------------------------------------------
module axi_crossbar
      #(parameter W_CID      = 4               // Channel ID width
                , W_ID       = 4               // ID width
                , W_ADDR     = 32              // address width
                , W_DATA     = 32              // data width
                , W_STRB     = (W_DATA/8)      // data strobe width
                , W_SID      = (W_CID+W_ID)    // slave ID
                , ADDR_BASE0 = 32'h00001000 , ADDR_LENGTH0 = 12 // effective addre bits
                , ADDR_BASE1 = 32'h00002000 , ADDR_LENGTH1 = 12
                , ADDR_BASE2 = 32'h00003000 , ADDR_LENGTH2 = 12
                , NUM_MASTER = 3
                , NUM_SLAVE  = 3
       )
(
       input   wire                      AXI_RSTn
     , input   wire                      AXI_CLK

     //--------------------------------------------------------------
     , input   wire  [2-1:0]             M0_MID   //2'b01
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

     , output  wire  [W_ID-1:0]          M0_BID
     , output  wire  [1:0]               M0_BRESP
     , output  wire                      M0_BVALID
     , input   wire                      M0_BREADY

     , input   wire  [W_ID-1:0]          M0_ARID
     , input   wire  [W_ADDR-1:0]        M0_ARADDR
     , input   wire  [7:0]               M0_ARLEN
     , input   wire  [2:0]               M0_ARSIZE
     , input   wire  [1:0]               M0_ARBURST
     , input   wire                      M0_ARVALID
     , output  wire                      M0_ARREADY

     , output  wire  [W_SID-1:0]         M0_RSID
     , output  wire  [W_DATA-1:0]        M0_RDATA
     , output  wire  [1:0]               M0_RRESP
     , output  wire                      M0_RLAST
     , output  wire                      M0_RVALID
     , input   wire                      M0_RREADY

     //--------------------------------------------------------------
     , input   wire  [2-1:0]             M1_MID   //2'b10
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

     , output  wire  [W_ID-1:0]          M1_BID
     , output  wire  [1:0]               M1_BRESP
     , output  wire                      M1_BVALID
     , input   wire                      M1_BREADY

     , input   wire  [W_ID-1:0]          M1_ARID
     , input   wire  [W_ADDR-1:0]        M1_ARADDR
     , input   wire  [7:0]               M1_ARLEN
     , input   wire  [2:0]               M1_ARSIZE
     , input   wire  [1:0]               M1_ARBURST
     , input   wire                      M1_ARVALID
     , output  wire                      M1_ARREADY

     , output  wire  [W_SID-1:0]         M1_RSID
     , output  wire  [W_DATA-1:0]        M1_RDATA
     , output  wire  [1:0]               M1_RRESP
     , output  wire                      M1_RLAST
     , output  wire                      M1_RVALID
     , input   wire                      M1_RREADY

     //--------------------------------------------------------------
     , input   wire  [2-1:0]             M2_MID   //2'b11
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

     , output  wire  [W_ID-1:0]          M2_BID
     , output  wire  [1:0]               M2_BRESP
     , output  wire                      M2_BVALID
     , input   wire                      M2_BREADY

     , input   wire  [W_ID-1:0]          M2_ARID
     , input   wire  [W_ADDR-1:0]        M2_ARADDR
     , input   wire  [7:0]               M2_ARLEN
     , input   wire  [2:0]               M2_ARSIZE
     , input   wire  [1:0]               M2_ARBURST
     , input   wire                      M2_ARVALID
     , output  wire                      M2_ARREADY

     , output  wire  [W_SID-1:0]         M2_RSID
     , output  wire  [W_DATA-1:0]        M2_RDATA
     , output  wire  [1:0]               M2_RRESP
     , output  wire                      M2_RLAST
     , output  wire                      M2_RVALID
     , input   wire                      M2_RREADY

     //--------------------------------------------------------------
     , output  wire   [W_SID-1:0]        S0_AWID
     , output  wire   [W_ADDR-1:0]       S0_AWADDR
     , output  wire   [7:0]              S0_AWLEN
     , output  wire   [2:0]              S0_AWSIZE
     , output  wire   [1:0]              S0_AWBURST
     , output  wire                      S0_AWVALID
     , input   wire                      S0_AWREADY

     , output  wire   [W_SID-1:0]        S0_WID
     , output  wire   [W_DATA-1:0]       S0_WDATA
     , output  wire   [W_STRB-1:0]       S0_WSTRB
     , output  wire                      S0_WLAST
     , output  wire                      S0_WVALID
     , input   wire                      S0_WREADY

     , input   wire   [W_SID-1:0]        S0_BID
     , input   wire   [1:0]              S0_BRESP
     , input   wire                      S0_BVALID
     , output  wire                      S0_BREADY

     , output  wire   [W_SID-1:0]        S0_ARID
     , output  wire   [W_ADDR-1:0]       S0_ARADDR
     , output  wire   [7:0]              S0_ARLEN
     , output  wire   [2:0]              S0_ARSIZE
     , output  wire   [1:0]              S0_ARBURST
     , output  wire                      S0_ARVALID
     , input   wire                      S0_ARREADY

     , input   wire   [W_SID-1:0]        S0_RID
     , input   wire   [W_DATA-1:0]       S0_RDATA
     , input   wire   [1:0]              S0_RRESP
     , input   wire                      S0_RLAST
     , input   wire                      S0_RVALID
     , output  wire                      S0_RREADY

     //--------------------------------------------------------------
     , output  wire   [W_SID-1:0]        S1_AWID
     , output  wire   [W_ADDR-1:0]       S1_AWADDR
     , output  wire   [7:0]              S1_AWLEN
     , output  wire   [2:0]              S1_AWSIZE
     , output  wire   [1:0]              S1_AWBURST
     , output  wire                      S1_AWVALID
     , input   wire                      S1_AWREADY

     , output  wire   [W_SID-1:0]        S1_WID
     , output  wire   [W_DATA-1:0]       S1_WDATA
     , output  wire   [W_STRB-1:0]       S1_WSTRB
     , output  wire                      S1_WLAST
     , output  wire                      S1_WVALID
     , input   wire                      S1_WREADY

     , input   wire   [W_SID-1:0]        S1_BID
     , input   wire   [1:0]              S1_BRESP
     , input   wire                      S1_BVALID
     , output  wire                      S1_BREADY

     , output  wire   [W_SID-1:0]        S1_ARID
     , output  wire   [W_ADDR-1:0]       S1_ARADDR
     , output  wire   [7:0]              S1_ARLEN
     , output  wire   [2:0]              S1_ARSIZE
     , output  wire   [1:0]              S1_ARBURST
     , output  wire                      S1_ARVALID
     , input   wire                      S1_ARREADY
     
     , input   wire   [W_SID-1:0]        S1_RID
     , input   wire   [W_DATA-1:0]       S1_RDATA
     , input   wire   [1:0]              S1_RRESP
     , input   wire                      S1_RLAST
     , input   wire                      S1_RVALID
     , output  wire                      S1_RREADY

     //--------------------------------------------------------------
     , output  wire   [W_SID-1:0]        S2_AWID
     , output  wire   [W_ADDR-1:0]       S2_AWADDR
     , output  wire   [7:0]              S2_AWLEN
     , output  wire   [2:0]              S2_AWSIZE
     , output  wire   [1:0]              S2_AWBURST
     , output  wire                      S2_AWVALID
     , input   wire                      S2_AWREADY

     , output  wire   [W_SID-1:0]        S2_WID
     , output  wire   [W_DATA-1:0]       S2_WDATA
     , output  wire   [W_STRB-1:0]       S2_WSTRB
     , output  wire                      S2_WLAST
     , output  wire                      S2_WVALID
     , input   wire                      S2_WREADY

     , input   wire   [W_SID-1:0]        S2_BID
     , input   wire   [1:0]              S2_BRESP
     , input   wire                      S2_BVALID
     , output  wire                      S2_BREADY

     , output  wire   [W_SID-1:0]        S2_ARID
     , output  wire   [W_ADDR-1:0]       S2_ARADDR
     , output  wire   [7:0]              S2_ARLEN
     , output  wire   [2:0]              S2_ARSIZE
     , output  wire   [1:0]              S2_ARBURST
     , output  wire                      S2_ARVALID
     , input   wire                      S2_ARREADY

     , input   wire   [W_SID-1:0]        S2_RID
     , input   wire   [W_DATA-1:0]       S2_RDATA
     , input   wire   [1:0]              S2_RRESP
     , input   wire                      S2_RLAST
     , input   wire                      S2_RVALID
     , output  wire                      S2_RREADY

     //--------------For reorder----------------------
     , input   wire  [2:0]               r_order_grant
     , input   wire  [2:0]               w_order_grant

     //--------------For apb config------------------
     , input   wire  [0:0]               arbiter_type
     , output  wire  [2:0]               aw_decode_err
     , output  wire  [2:0]               ar_decode_err
     , input   wire                      slaver0_en
     , input   wire                      slaver1_en
     , input   wire                      slaver2_en
);

    // default slave signal
    wire  [W_SID-1:0]         SD_AWID     ;
    wire  [W_ADDR-1:0]        SD_AWADDR   ;
    wire  [7:0]               SD_AWLEN    ;
    wire  [2:0]               SD_AWSIZE   ;
    wire  [1:0]               SD_AWBURST  ;
    wire                      SD_AWVALID  ;
    wire                      SD_AWREADY  ;
    wire  [W_SID-1:0]         SD_WID      ;
    wire  [W_DATA-1:0]        SD_WDATA    ;
    wire  [W_STRB-1:0]        SD_WSTRB    ;
    wire                      SD_WLAST    ;
    wire                      SD_WVALID   ;
    wire                      SD_WREADY   ;
    wire  [W_SID-1:0]         SD_BID      ;
    wire  [1:0]               SD_BRESP    ;
    wire                      SD_BVALID   ;
    wire                      SD_BREADY   ;
    wire  [W_SID-1:0]         SD_ARID     ;
    wire  [W_ADDR-1:0]        SD_ARADDR   ;
    wire  [7:0]               SD_ARLEN    ;
    wire  [2:0]               SD_ARSIZE   ;
    wire  [1:0]               SD_ARBURST  ;
    wire                      SD_ARVALID  ;
    wire                      SD_ARREADY  ;
    wire  [W_SID-1:0]         SD_RID      ;
    wire  [W_DATA-1:0]        SD_RDATA    ;
    wire  [1:0]               SD_RRESP    ;
    wire                      SD_RLAST    ;
    wire                      SD_RVALID   ;
    wire                      SD_RREADY   ;

    // driven by axi_mtos_s
    wire M0_AWREADY_S0, M0_AWREADY_S1, M0_AWREADY_S2, M0_AWREADY_SD  ;
    wire M0_WREADY_S0 , M0_WREADY_S1 , M0_WREADY_S2 , M0_WREADY_SD   ;
    wire M0_ARREADY_S0, M0_ARREADY_S1, M0_ARREADY_S2, M0_ARREADY_SD  ;
    wire M1_AWREADY_S0, M1_AWREADY_S1, M1_AWREADY_S2, M1_AWREADY_SD  ;
    wire M1_WREADY_S0 , M1_WREADY_S1 , M1_WREADY_S2 , M1_WREADY_SD   ;
    wire M1_ARREADY_S0, M1_ARREADY_S1, M1_ARREADY_S2, M1_ARREADY_SD  ;
    wire M2_AWREADY_S0, M2_AWREADY_S1, M2_AWREADY_S2, M2_AWREADY_SD  ;
    wire M2_WREADY_S0 , M2_WREADY_S1 , M2_WREADY_S2 , M2_WREADY_SD   ;
    wire M2_ARREADY_S0, M2_ARREADY_S1, M2_ARREADY_S2, M2_ARREADY_SD  ;

    assign M0_AWREADY = M0_AWREADY_S0 | M0_AWREADY_S1 | M0_AWREADY_S2 | M0_AWREADY_SD  ;
    assign M0_WREADY  = M0_WREADY_S0  | M0_WREADY_S1  | M0_WREADY_S2  | M0_WREADY_SD   ;
    assign M0_ARREADY = M0_ARREADY_S0 | M0_ARREADY_S1 | M0_ARREADY_S2 | M0_ARREADY_SD  ;
    assign M1_AWREADY = M1_AWREADY_S0 | M1_AWREADY_S1 | M1_AWREADY_S2 | M1_AWREADY_SD  ;
    assign M1_WREADY  = M1_WREADY_S0  | M1_WREADY_S1  | M1_WREADY_S2  | M1_WREADY_SD   ;
    assign M1_ARREADY = M1_ARREADY_S0 | M1_ARREADY_S1 | M1_ARREADY_S2 | M1_ARREADY_SD  ;
    assign M2_AWREADY = M2_AWREADY_S0 | M2_AWREADY_S1 | M2_AWREADY_S2 | M2_AWREADY_SD  ;
    assign M2_WREADY  = M2_WREADY_S0  | M2_WREADY_S1  | M2_WREADY_S2  | M2_WREADY_SD   ;
    assign M2_ARREADY = M2_ARREADY_S0 | M2_ARREADY_S1 | M2_ARREADY_S2 | M2_ARREADY_SD  ;

    // driven by axi_stom_m
    wire S0_BREADY_M0, S0_BREADY_M1, S0_BREADY_M2;
    wire S0_RREADY_M0, S0_RREADY_M1, S0_RREADY_M2;
    wire S1_BREADY_M0, S1_BREADY_M1, S1_BREADY_M2;
    wire S1_RREADY_M0, S1_RREADY_M1, S1_RREADY_M2;
    wire S2_BREADY_M0, S2_BREADY_M1, S2_BREADY_M2;
    wire S2_RREADY_M0, S2_RREADY_M1, S2_RREADY_M2;
    wire SD_BREADY_M0, SD_BREADY_M1, SD_BREADY_M2;
    wire SD_RREADY_M0, SD_RREADY_M1, SD_RREADY_M2;

    assign S0_BREADY = S0_BREADY_M0 | S0_BREADY_M1 | S0_BREADY_M2;
    assign S0_RREADY = S0_RREADY_M0 | S0_RREADY_M1 | S0_RREADY_M2;
    assign S1_BREADY = S1_BREADY_M0 | S1_BREADY_M1 | S1_BREADY_M2;
    assign S1_RREADY = S1_RREADY_M0 | S1_RREADY_M1 | S1_RREADY_M2;
    assign S2_BREADY = S2_BREADY_M0 | S2_BREADY_M1 | S2_BREADY_M2;
    assign S2_RREADY = S2_RREADY_M0 | S2_RREADY_M1 | S2_RREADY_M2;
    assign SD_BREADY = SD_BREADY_M0 | SD_BREADY_M1 | SD_BREADY_M2;
    assign SD_RREADY = SD_RREADY_M0 | SD_RREADY_M1 | SD_RREADY_M2;

    // drivne by axi_mtos_m
    wire [NUM_MASTER-1:0] AWSELECT_OUT [0:NUM_SLAVE-1];
    wire [NUM_MASTER-1:0] ARSELECT_OUT [0:NUM_SLAVE-1];
    wire [NUM_MASTER-1:0] AWSELECT; // goes to default slave
    wire [NUM_MASTER-1:0] ARSELECT; // goes to default slave

    assign AWSELECT[0] = AWSELECT_OUT[0][0] | AWSELECT_OUT[1][0] | AWSELECT_OUT[2][0];
    assign AWSELECT[1] = AWSELECT_OUT[0][1] | AWSELECT_OUT[1][1] | AWSELECT_OUT[2][1];
    assign AWSELECT[2] = AWSELECT_OUT[0][2] | AWSELECT_OUT[1][2] | AWSELECT_OUT[2][2];
    assign ARSELECT[0] = ARSELECT_OUT[0][0] | ARSELECT_OUT[1][0] | ARSELECT_OUT[2][0];
    assign ARSELECT[1] = ARSELECT_OUT[0][1] | ARSELECT_OUT[1][1] | ARSELECT_OUT[2][1];
    assign ARSELECT[2] = ARSELECT_OUT[0][2] | ARSELECT_OUT[1][2] | ARSELECT_OUT[2][2];

     // masters to slave for slave 0
     axi_m2s_m3 #(.SLAVE_ID      (1           )
                  ,.ADDR_BASE     (ADDR_BASE0  )
                  ,.ADDR_LENGTH   (ADDR_LENGTH0)
                  ,.W_CID         (W_CID       )
                  ,.W_ID          (W_ID        )
                  ,.W_ADDR        (W_ADDR      )
                  ,.W_DATA        (W_DATA      )
                  ,.W_STRB        (W_STRB      )
                  ,.W_SID         (W_SID       )
                  ,.SLAVE_DEFAULT (1'b0        )
                 )
     u_axi_m2s_s0 (
                                .AXI_RSTn             (AXI_RSTn     )
                              , .AXI_CLK              (AXI_CLK      )

                              , .M0_MID               (M0_MID       )
                              , .M0_AWID              (M0_AWID      )
                              , .M0_AWADDR            (M0_AWADDR    )
                              , .M0_AWLEN             (M0_AWLEN     )
                              , .M0_AWSIZE            (M0_AWSIZE    )
                              , .M0_AWBURST           (M0_AWBURST   )
                              , .M0_AWVALID           (M0_AWVALID   )
                              , .M0_AWREADY           (M0_AWREADY_S0) //output
                              , .M0_WID               (M0_WID       )
                              , .M0_WDATA             (M0_WDATA     )
                              , .M0_WSTRB             (M0_WSTRB     )
                              , .M0_WLAST             (M0_WLAST     )
                              , .M0_WVALID            (M0_WVALID    )
                              , .M0_WREADY            (M0_WREADY_S0 )
                              , .M0_ARID              (M0_ARID      )
                              , .M0_ARADDR            (M0_ARADDR    )
                              , .M0_ARLEN             (M0_ARLEN     )
                              , .M0_ARSIZE            (M0_ARSIZE    )
                              , .M0_ARBURST           (M0_ARBURST   )
                              , .M0_ARVALID           (M0_ARVALID   )
                              , .M0_ARREADY           (M0_ARREADY_S0)

                              , .M1_MID               (M1_MID       )
                              , .M1_AWID              (M1_AWID      )
                              , .M1_AWADDR            (M1_AWADDR    )
                              , .M1_AWLEN             (M1_AWLEN     )
                              , .M1_AWSIZE            (M1_AWSIZE    )
                              , .M1_AWBURST           (M1_AWBURST   )
                              , .M1_AWVALID           (M1_AWVALID   )
                              , .M1_AWREADY           (M1_AWREADY_S0)
                              , .M1_WID               (M1_WID       )
                              , .M1_WDATA             (M1_WDATA     )
                              , .M1_WSTRB             (M1_WSTRB     )
                              , .M1_WLAST             (M1_WLAST     )
                              , .M1_WVALID            (M1_WVALID    )
                              , .M1_WREADY            (M1_WREADY_S0 )
                              , .M1_ARID              (M1_ARID      )
                              , .M1_ARADDR            (M1_ARADDR    )
                              , .M1_ARLEN             (M1_ARLEN     )
                              , .M1_ARSIZE            (M1_ARSIZE    )
                              , .M1_ARBURST           (M1_ARBURST   )
                              , .M1_ARVALID           (M1_ARVALID   )
                              , .M1_ARREADY           (M1_ARREADY_S0)

                              , .M2_MID               (M2_MID       )
                              , .M2_AWID              (M2_AWID      )
                              , .M2_AWADDR            (M2_AWADDR    )
                              , .M2_AWLEN             (M2_AWLEN     )
                              , .M2_AWSIZE            (M2_AWSIZE    )
                              , .M2_AWBURST           (M2_AWBURST   )
                              , .M2_AWVALID           (M2_AWVALID   )
                              , .M2_AWREADY           (M2_AWREADY_S0)
                              , .M2_WID               (M2_WID       )
                              , .M2_WDATA             (M2_WDATA     )
                              , .M2_WSTRB             (M2_WSTRB     )
                              , .M2_WLAST             (M2_WLAST     )
                              , .M2_WVALID            (M2_WVALID    )
                              , .M2_WREADY            (M2_WREADY_S0 )
                              , .M2_ARID              (M2_ARID      )
                              , .M2_ARADDR            (M2_ARADDR    )
                              , .M2_ARLEN             (M2_ARLEN     )
                              , .M2_ARSIZE            (M2_ARSIZE    )
                              , .M2_ARBURST           (M2_ARBURST   )
                              , .M2_ARVALID           (M2_ARVALID   )
                              , .M2_ARREADY           (M2_ARREADY_S0)

                              , .w_order_grant        (w_order_grant)
                              , .arbiter_type         (arbiter_type )
                              , .channel_en           (slaver0_en   )

         , .S_AWID               (S0_AWID      )
         , .S_AWADDR             (S0_AWADDR    )
         , .S_AWLEN              (S0_AWLEN     )
         , .S_AWSIZE             (S0_AWSIZE    )
         , .S_AWBURST            (S0_AWBURST   )
         , .S_AWVALID            (S0_AWVALID   )
         , .S_AWREADY            (S0_AWREADY   )
         , .S_WID                (S0_WID       )
         , .S_WDATA              (S0_WDATA     )
         , .S_WSTRB              (S0_WSTRB     )
         , .S_WLAST              (S0_WLAST     )
         , .S_WVALID             (S0_WVALID    )
         , .S_WREADY             (S0_WREADY    )
         , .S_ARID               (S0_ARID      )
         , .S_ARADDR             (S0_ARADDR    )
         , .S_ARLEN              (S0_ARLEN     )
         , .S_ARSIZE             (S0_ARSIZE    )
         , .S_ARBURST            (S0_ARBURST   )
         , .S_ARVALID            (S0_ARVALID   )
         , .S_ARREADY            (S0_ARREADY   )

         , .AWSELECT_OUT         (AWSELECT_OUT[0])
         , .ARSELECT_OUT         (ARSELECT_OUT[0])
         , .AWSELECT_IN          (AWSELECT_OUT[0])// not used since non-default-slave
         , .ARSELECT_IN          (ARSELECT_OUT[0])// not used since non-default-slave
     );
    
     // masters to slave for slave 1
     axi_m2s_m3 #(.SLAVE_ID      (2           )
                  ,.ADDR_BASE     (ADDR_BASE1  )
                  ,.ADDR_LENGTH   (ADDR_LENGTH1)
                  ,.W_CID         (W_CID       )
                  ,.W_ID          (W_ID        )
                  ,.W_ADDR        (W_ADDR      )
                  ,.W_DATA        (W_DATA      )
                  ,.W_STRB        (W_STRB      )
                  ,.W_SID         (W_SID       )
                  ,.SLAVE_DEFAULT (1'b0        )
                 )
     u_axi_m2s_s1 (
                                .AXI_RSTn             (AXI_RSTn     )
                              , .AXI_CLK              (AXI_CLK      )

                              , .M0_MID               (M0_MID       )
                              , .M0_AWID              (M0_AWID      )
                              , .M0_AWADDR            (M0_AWADDR    )
                              , .M0_AWLEN             (M0_AWLEN     )
                              , .M0_AWSIZE            (M0_AWSIZE    )
                              , .M0_AWBURST           (M0_AWBURST   )
                              , .M0_AWVALID           (M0_AWVALID   )
                              , .M0_AWREADY           (M0_AWREADY_S1)
                              , .M0_WID               (M0_WID       )
                              , .M0_WDATA             (M0_WDATA     )
                              , .M0_WSTRB             (M0_WSTRB     )
                              , .M0_WLAST             (M0_WLAST     )
                              , .M0_WVALID            (M0_WVALID    )
                              , .M0_WREADY            (M0_WREADY_S1 )
                              , .M0_ARID              (M0_ARID      )
                              , .M0_ARADDR            (M0_ARADDR    )
                              , .M0_ARLEN             (M0_ARLEN     )
                              , .M0_ARSIZE            (M0_ARSIZE    )
                              , .M0_ARBURST           (M0_ARBURST   )
                              , .M0_ARVALID           (M0_ARVALID   )
                              , .M0_ARREADY           (M0_ARREADY_S1)

                              , .M1_MID               (M1_MID       )
                              , .M1_AWID              (M1_AWID      )
                              , .M1_AWADDR            (M1_AWADDR    )
                              , .M1_AWLEN             (M1_AWLEN     )
                              , .M1_AWSIZE            (M1_AWSIZE    )
                              , .M1_AWBURST           (M1_AWBURST   )
                              , .M1_AWVALID           (M1_AWVALID   )
                              , .M1_AWREADY           (M1_AWREADY_S1)
                              , .M1_WID               (M1_WID       )
                              , .M1_WDATA             (M1_WDATA     )
                              , .M1_WSTRB             (M1_WSTRB     )
                              , .M1_WLAST             (M1_WLAST     )
                              , .M1_WVALID            (M1_WVALID    )
                              , .M1_WREADY            (M1_WREADY_S1 )
                              , .M1_ARID              (M1_ARID      )
                              , .M1_ARADDR            (M1_ARADDR    )
                              , .M1_ARLEN             (M1_ARLEN     )
                              , .M1_ARSIZE            (M1_ARSIZE    )
                              , .M1_ARBURST           (M1_ARBURST   )
                              , .M1_ARVALID           (M1_ARVALID   )
                              , .M1_ARREADY           (M1_ARREADY_S1)

                              , .M2_MID               (M2_MID       )
                              , .M2_AWID              (M2_AWID      )
                              , .M2_AWADDR            (M2_AWADDR    )
                              , .M2_AWLEN             (M2_AWLEN     )
                              , .M2_AWSIZE            (M2_AWSIZE    )
                              , .M2_AWBURST           (M2_AWBURST   )
                              , .M2_AWVALID           (M2_AWVALID   )
                              , .M2_AWREADY           (M2_AWREADY_S1)
                              , .M2_WID               (M2_WID       )
                              , .M2_WDATA             (M2_WDATA     )
                              , .M2_WSTRB             (M2_WSTRB     )
                              , .M2_WLAST             (M2_WLAST     )
                              , .M2_WVALID            (M2_WVALID    )
                              , .M2_WREADY            (M2_WREADY_S1 )
                              , .M2_ARID              (M2_ARID      )
                              , .M2_ARADDR            (M2_ARADDR    )
                              , .M2_ARLEN             (M2_ARLEN     )
                              , .M2_ARSIZE            (M2_ARSIZE    )
                              , .M2_ARBURST           (M2_ARBURST   )
                              , .M2_ARVALID           (M2_ARVALID   )
                              , .M2_ARREADY           (M2_ARREADY_S1)

                              , .w_order_grant        (w_order_grant)
                              , .arbiter_type         (arbiter_type )
                              , .channel_en           (slaver1_en   )

         , .S_AWID               (S1_AWID      )
         , .S_AWADDR             (S1_AWADDR    )
         , .S_AWLEN              (S1_AWLEN     )
         , .S_AWSIZE             (S1_AWSIZE    )
         , .S_AWBURST            (S1_AWBURST   )
         , .S_AWVALID            (S1_AWVALID   )
         , .S_AWREADY            (S1_AWREADY   )
         , .S_WID                (S1_WID       )
         , .S_WDATA              (S1_WDATA     )
         , .S_WSTRB              (S1_WSTRB     )
         , .S_WLAST              (S1_WLAST     )
         , .S_WVALID             (S1_WVALID    )
         , .S_WREADY             (S1_WREADY    )
         , .S_ARID               (S1_ARID      )
         , .S_ARADDR             (S1_ARADDR    )
         , .S_ARLEN              (S1_ARLEN     )
         , .S_ARSIZE             (S1_ARSIZE    )
         , .S_ARBURST            (S1_ARBURST   )
         , .S_ARVALID            (S1_ARVALID   )
         , .S_ARREADY            (S1_ARREADY   )

         , .AWSELECT_OUT         (AWSELECT_OUT[1])
         , .ARSELECT_OUT         (ARSELECT_OUT[1])
         , .AWSELECT_IN          (AWSELECT_OUT[1])// not used since non-default-slave
         , .ARSELECT_IN          (ARSELECT_OUT[1])// not used since non-default-slave
     );
     
     // masters to slave for slave 2
     axi_m2s_m3 #(.SLAVE_ID      (3           )
                  ,.ADDR_BASE     (ADDR_BASE2  )
                  ,.ADDR_LENGTH   (ADDR_LENGTH2)
                  ,.W_CID         (W_CID       )
                  ,.W_ID          (W_ID        )
                  ,.W_ADDR        (W_ADDR      )
                  ,.W_DATA        (W_DATA      )
                  ,.W_STRB        (W_STRB      )
                  ,.W_SID         (W_SID       )
                  ,.SLAVE_DEFAULT (1'b0        )
                 )
     u_axi_m2s_s2 (
                                .AXI_RSTn             (AXI_RSTn     )
                              , .AXI_CLK              (AXI_CLK      )
                              , .M0_MID               (M0_MID       )
                              , .M0_AWID              (M0_AWID      )
                              , .M0_AWADDR            (M0_AWADDR    )
                              , .M0_AWLEN             (M0_AWLEN     )
                              , .M0_AWSIZE            (M0_AWSIZE    )
                              , .M0_AWBURST           (M0_AWBURST   )
                              , .M0_AWVALID           (M0_AWVALID   )
                              , .M0_AWREADY           (M0_AWREADY_S2)
                              , .M0_WID               (M0_WID       )
                              , .M0_WDATA             (M0_WDATA     )
                              , .M0_WSTRB             (M0_WSTRB     )
                              , .M0_WLAST             (M0_WLAST     )
                              , .M0_WVALID            (M0_WVALID    )
                              , .M0_WREADY            (M0_WREADY_S2 )
                              , .M0_ARID              (M0_ARID      )
                              , .M0_ARADDR            (M0_ARADDR    )
                              , .M0_ARLEN             (M0_ARLEN     )
                              , .M0_ARSIZE            (M0_ARSIZE    )
                              , .M0_ARBURST           (M0_ARBURST   )
                              , .M0_ARVALID           (M0_ARVALID   )
                              , .M0_ARREADY           (M0_ARREADY_S2)

                              , .M1_MID               (M1_MID       )
                              , .M1_AWID              (M1_AWID      )
                              , .M1_AWADDR            (M1_AWADDR    )
                              , .M1_AWLEN             (M1_AWLEN     )
                              , .M1_AWSIZE            (M1_AWSIZE    )
                              , .M1_AWBURST           (M1_AWBURST   )
                              , .M1_AWVALID           (M1_AWVALID   )
                              , .M1_AWREADY           (M1_AWREADY_S2)
                              , .M1_WID               (M1_WID       )
                              , .M1_WDATA             (M1_WDATA     )
                              , .M1_WSTRB             (M1_WSTRB     )
                              , .M1_WLAST             (M1_WLAST     )
                              , .M1_WVALID            (M1_WVALID    )
                              , .M1_WREADY            (M1_WREADY_S2 )
                              , .M1_ARID              (M1_ARID      )
                              , .M1_ARADDR            (M1_ARADDR    )
                              , .M1_ARLEN             (M1_ARLEN     )
                              , .M1_ARSIZE            (M1_ARSIZE    )
                              , .M1_ARBURST           (M1_ARBURST   )
                              , .M1_ARVALID           (M1_ARVALID   )
                              , .M1_ARREADY           (M1_ARREADY_S2)

                              , .M2_MID               (M2_MID       )
                              , .M2_AWID              (M2_AWID      )
                              , .M2_AWADDR            (M2_AWADDR    )
                              , .M2_AWLEN             (M2_AWLEN     )
                              , .M2_AWSIZE            (M2_AWSIZE    )
                              , .M2_AWBURST           (M2_AWBURST   )
                              , .M2_AWVALID           (M2_AWVALID   )
                              , .M2_AWREADY           (M2_AWREADY_S2)
                              , .M2_WID               (M2_WID       )
                              , .M2_WDATA             (M2_WDATA     )
                              , .M2_WSTRB             (M2_WSTRB     )
                              , .M2_WLAST             (M2_WLAST     )
                              , .M2_WVALID            (M2_WVALID    )
                              , .M2_WREADY            (M2_WREADY_S2 )
                              , .M2_ARID              (M2_ARID      )
                              , .M2_ARADDR            (M2_ARADDR    )
                              , .M2_ARLEN             (M2_ARLEN     )
                              , .M2_ARSIZE            (M2_ARSIZE    )
                              , .M2_ARBURST           (M2_ARBURST   )
                              , .M2_ARVALID           (M2_ARVALID   )
                              , .M2_ARREADY           (M2_ARREADY_S2)

                              , .w_order_grant        (w_order_grant)
                              , .arbiter_type         (arbiter_type )
                              , .channel_en           (slaver2_en   )

         , .S_AWID               (S2_AWID      )
         , .S_AWADDR             (S2_AWADDR    )
         , .S_AWLEN              (S2_AWLEN     )
         , .S_AWSIZE             (S2_AWSIZE    )
         , .S_AWBURST            (S2_AWBURST   )
         , .S_AWVALID            (S2_AWVALID   )
         , .S_AWREADY            (S2_AWREADY   )
         , .S_WID                (S2_WID       )
         , .S_WDATA              (S2_WDATA     )
         , .S_WSTRB              (S2_WSTRB     )
         , .S_WLAST              (S2_WLAST     )
         , .S_WVALID             (S2_WVALID    )
         , .S_WREADY             (S2_WREADY    )
         , .S_ARID               (S2_ARID      )
         , .S_ARADDR             (S2_ARADDR    )
         , .S_ARLEN              (S2_ARLEN     )
         , .S_ARSIZE             (S2_ARSIZE    )
         , .S_ARBURST            (S2_ARBURST   )
         , .S_ARVALID            (S2_ARVALID   )
         , .S_ARREADY            (S2_ARREADY   )

         , .AWSELECT_OUT         (AWSELECT_OUT[2])
         , .ARSELECT_OUT         (ARSELECT_OUT[2])
         , .AWSELECT_IN          (AWSELECT_OUT[2])// not used since non-default-slave
         , .ARSELECT_IN          (ARSELECT_OUT[2])// not used since non-default-slave
     );
     
     // masters to slave for default slave
     axi_m2s_m3 #(.SLAVE_ID      (0           )
                  ,.ADDR_BASE     (            )
                  ,.ADDR_LENGTH   (ADDR_LENGTH1)
                  ,.W_CID         (W_CID       )
                  ,.W_ID          (W_ID        )
                  ,.W_ADDR        (W_ADDR      )
                  ,.W_DATA        (W_DATA      )
                  ,.W_STRB        (W_STRB      )
                  ,.W_SID         (W_SID       )
                  ,.SLAVE_DEFAULT (1'b1        )
                 )
     u_axi_m2s_sd (
                                .AXI_RSTn             (AXI_RSTn     )
                              , .AXI_CLK              (AXI_CLK      )

                              , .M0_MID               (M0_MID       )
                              , .M0_AWID              (M0_AWID      )
                              , .M0_AWADDR            (M0_AWADDR    )
                              , .M0_AWLEN             (M0_AWLEN     )
                              , .M0_AWSIZE            (M0_AWSIZE    )
                              , .M0_AWBURST           (M0_AWBURST   )
                              , .M0_AWVALID           (M0_AWVALID   )
                              , .M0_AWREADY           (M0_AWREADY_SD)
                              , .M0_WID               (M0_WID       )
                              , .M0_WDATA             (M0_WDATA     )
                              , .M0_WSTRB             (M0_WSTRB     )
                              , .M0_WLAST             (M0_WLAST     )
                              , .M0_WVALID            (M0_WVALID    )
                              , .M0_WREADY            (M0_WREADY_SD )
                              , .M0_ARID              (M0_ARID      )
                              , .M0_ARADDR            (M0_ARADDR    )
                              , .M0_ARLEN             (M0_ARLEN     )
                              , .M0_ARSIZE            (M0_ARSIZE    )
                              , .M0_ARBURST           (M0_ARBURST   )
                              , .M0_ARVALID           (M0_ARVALID   )
                              , .M0_ARREADY           (M0_ARREADY_SD)

                              , .M1_MID               (M1_MID       )
                              , .M1_AWID              (M1_AWID      )
                              , .M1_AWADDR            (M1_AWADDR    )
                              , .M1_AWLEN             (M1_AWLEN     )
                              , .M1_AWSIZE            (M1_AWSIZE    )
                              , .M1_AWBURST           (M1_AWBURST   )
                              , .M1_AWVALID           (M1_AWVALID   )
                              , .M1_AWREADY           (M1_AWREADY_SD)
                              , .M1_WID               (M1_WID       )
                              , .M1_WDATA             (M1_WDATA     )
                              , .M1_WSTRB             (M1_WSTRB     )
                              , .M1_WLAST             (M1_WLAST     )
                              , .M1_WVALID            (M1_WVALID    )
                              , .M1_WREADY            (M1_WREADY_SD )
                              , .M1_ARID              (M1_ARID      )
                              , .M1_ARADDR            (M1_ARADDR    )
                              , .M1_ARLEN             (M1_ARLEN     )
                              , .M1_ARSIZE            (M1_ARSIZE    )
                              , .M1_ARBURST           (M1_ARBURST   )
                              , .M1_ARVALID           (M1_ARVALID   )
                              , .M1_ARREADY           (M1_ARREADY_SD)

                              , .M2_MID               (M2_MID       )
                              , .M2_AWID              (M2_AWID      )
                              , .M2_AWADDR            (M2_AWADDR    )
                              , .M2_AWLEN             (M2_AWLEN     )
                              , .M2_AWSIZE            (M2_AWSIZE    )
                              , .M2_AWBURST           (M2_AWBURST   )
                              , .M2_AWVALID           (M2_AWVALID   )
                              , .M2_AWREADY           (M2_AWREADY_SD)
                              , .M2_WID               (M2_WID       )
                              , .M2_WDATA             (M2_WDATA     )
                              , .M2_WSTRB             (M2_WSTRB     )
                              , .M2_WLAST             (M2_WLAST     )
                              , .M2_WVALID            (M2_WVALID    )
                              , .M2_WREADY            (M2_WREADY_SD )
                              , .M2_ARID              (M2_ARID      )
                              , .M2_ARADDR            (M2_ARADDR    )
                              , .M2_ARLEN             (M2_ARLEN     )
                              , .M2_ARSIZE            (M2_ARSIZE    )
                              , .M2_ARBURST           (M2_ARBURST   )
                              , .M2_ARVALID           (M2_ARVALID   )
                              , .M2_ARREADY           (M2_ARREADY_SD)

                              , .w_order_grant        (w_order_grant)
                              , .arbiter_type         (arbiter_type)
                              , .channel_en           (1'b1)

         , .S_AWID               (SD_AWID      )
         , .S_AWADDR             (SD_AWADDR    )
         , .S_AWLEN              (SD_AWLEN     )
         , .S_AWSIZE             (SD_AWSIZE    )
         , .S_AWBURST            (SD_AWBURST   )
         , .S_AWVALID            (SD_AWVALID   )
         , .S_AWREADY            (SD_AWREADY   )
         , .S_WID                (SD_WID       )
         , .S_WDATA              (SD_WDATA     )
         , .S_WSTRB              (SD_WSTRB     )
         , .S_WLAST              (SD_WLAST     )
         , .S_WVALID             (SD_WVALID    )
         , .S_WREADY             (SD_WREADY    )
         , .S_ARID               (SD_ARID      )
         , .S_ARADDR             (SD_ARADDR    )
         , .S_ARLEN              (SD_ARLEN     )
         , .S_ARSIZE             (SD_ARSIZE    )
         , .S_ARBURST            (SD_ARBURST   )
         , .S_ARVALID            (SD_ARVALID   )
         , .S_ARREADY            (SD_ARREADY   )

         , .AWSELECT_OUT         (aw_decode_err)
         , .ARSELECT_OUT         (ar_decode_err)
         , .AWSELECT_IN          (AWSELECT     )
         , .ARSELECT_IN          (ARSELECT     )
     );

    //--------------default slave--------------------
    axi_default_slave #(  .W_CID  (W_CID  )
                        , .W_ID   (W_ID   )
                        , .W_ADDR (W_ADDR )
                        , .W_DATA (W_DATA )
    ) 
    u_axi_default_slave (
      .AXI_RSTn (AXI_RSTn   ) //input 
    , .AXI_CLK  (AXI_CLK    ) //input 
    , .AWID     (SD_AWID    ) //input 
    , .AWADDR   (SD_AWADDR  ) //input 
    , .AWLEN    (SD_AWLEN   ) //input 
    , .AWSIZE   (SD_AWSIZE  ) //input 
    , .AWBURST  (SD_AWBURST ) //input 
    , .AWVALID  (SD_AWVALID ) //input 
    , .AWREADY  (SD_AWREADY ) //output

    , .WID      (SD_WID     ) //input 
    , .WDATA    (SD_WDATA   ) //input 
    , .WSTRB    (SD_WSTRB   ) //input 
    , .WLAST    (SD_WLAST   ) //input 
    , .WVALID   (SD_WVALID  ) //input 
    , .WREADY   (SD_WREADY  ) //output

    , .BID      (SD_BID     ) //output
    , .BRESP    (SD_BRESP   ) //output
    , .BVALID   (SD_BVALID  ) //output
    , .BREADY   (SD_BREADY  ) //input 

    , .ARID     (SD_ARID    ) //input 
    , .ARADDR   (SD_ARADDR  ) //input 
    , .ARLEN    (SD_ARLEN   ) //input 
    , .ARSIZE   (SD_ARSIZE  ) //input 
    , .ARBURST  (SD_ARBURST ) //input 
    , .ARVALID  (SD_ARVALID ) //input 
    , .ARREADY  (SD_ARREADY ) //output

    , .RID      (SD_RID     ) //output
    , .RDATA    (SD_RDATA   ) //output
    , .RRESP    (SD_RRESP   ) //output
    , .RLAST    (SD_RLAST   ) //output
    , .RVALID   (SD_RVALID  ) //output
    , .RREADY   (SD_RREADY  ) //input 
    );

     // slaves to master for master 0
     axi_s2m_s3 #( .MASTER_ID (1       )
                  , .W_CID     (W_CID   )
                  , .W_ID      (W_ID    )
                  , .W_ADDR    (W_ADDR  )
                  , .W_DATA    (W_DATA  )
                  , .W_STRB    (W_STRB  )
                  , .W_SID     (W_SID   )
                 )
     u_axi_stom_m0 (
           .AXI_RSTn             (AXI_RSTn    )
         , .AXI_CLK              (AXI_CLK     )

         , .M_MID                (M0_MID      )
         , .M_BID                (M0_BID      )
         , .M_BRESP              (M0_BRESP    )
         , .M_BVALID             (M0_BVALID   )
         , .M_BREADY             (M0_BREADY   )
         , .M_RSID               (M0_RSID     )
         , .M_RDATA              (M0_RDATA    )
         , .M_RRESP              (M0_RRESP    )
         , .M_RLAST              (M0_RLAST    )
         , .M_RVALID             (M0_RVALID   )
         , .M_RREADY             (M0_RREADY   )

                           , .S0_BID               (S0_BID      )
                           , .S0_BRESP             (S0_BRESP    )
                           , .S0_BVALID            (S0_BVALID   )
                           , .S0_BREADY            (S0_BREADY_M0)
                           , .S0_RID               (S0_RID      )
                           , .S0_RDATA             (S0_RDATA    )
                           , .S0_RRESP             (S0_RRESP    )
                           , .S0_RLAST             (S0_RLAST    )
                           , .S0_RVALID            (S0_RVALID   )
                           , .S0_RREADY            (S0_RREADY_M0)

                           , .S1_BID               (S1_BID      )
                           , .S1_BRESP             (S1_BRESP    )
                           , .S1_BVALID            (S1_BVALID   )
                           , .S1_BREADY            (S1_BREADY_M0)
                           , .S1_RID               (S1_RID      )
                           , .S1_RDATA             (S1_RDATA    )
                           , .S1_RRESP             (S1_RRESP    )
                           , .S1_RLAST             (S1_RLAST    )
                           , .S1_RVALID            (S1_RVALID   )
                           , .S1_RREADY            (S1_RREADY_M0)

                           , .S2_BID               (S2_BID      )
                           , .S2_BRESP             (S2_BRESP    )
                           , .S2_BVALID            (S2_BVALID   )
                           , .S2_BREADY            (S2_BREADY_M0)
                           , .S2_RID               (S2_RID      )
                           , .S2_RDATA             (S2_RDATA    )
                           , .S2_RRESP             (S2_RRESP    )
                           , .S2_RLAST             (S2_RLAST    )
                           , .S2_RVALID            (S2_RVALID   )
                           , .S2_RREADY            (S2_RREADY_M0)
                           , .SD_BID               (SD_BID      )
                           , .SD_BRESP             (SD_BRESP    )
                           , .SD_BVALID            (SD_BVALID   )
                           , .SD_BREADY            (SD_BREADY_M0)
                           , .SD_RID               (SD_RID      )
                           , .SD_RDATA             (SD_RDATA    )
                           , .SD_RRESP             (SD_RRESP    )
                           , .SD_RLAST             (SD_RLAST    )
                           , .SD_RVALID            (SD_RVALID   )
                           , .SD_RREADY            (SD_RREADY_M0)

                           , .r_order_grant        (r_order_grant) //input wire [7:0] [3:0]
                           , .arbiter_type         (arbiter_type)
     );
      
     // slaves to master for master 1
     axi_s2m_s3 #( .MASTER_ID   (2       )
                  , .W_CID       (W_CID   )
                  , .W_ID        (W_ID    )
                  , .W_ADDR      (W_ADDR  )
                  , .W_DATA      (W_DATA  )
                  , .W_STRB      (W_STRB  )
                  , .W_SID       (W_SID   )
                 )
     u_axi_stom_m1 (
           .AXI_RSTn             (AXI_RSTn    )
         , .AXI_CLK              (AXI_CLK     )

         , .M_MID                (M1_MID      )
         , .M_BID                (M1_BID      )
         , .M_BRESP              (M1_BRESP    )
         , .M_BVALID             (M1_BVALID   )
         , .M_BREADY             (M1_BREADY   )
         , .M_RSID               (M1_RSID     )
         , .M_RDATA              (M1_RDATA    )
         , .M_RRESP              (M1_RRESP    )
         , .M_RLAST              (M1_RLAST    )
         , .M_RVALID             (M1_RVALID   )
         , .M_RREADY             (M1_RREADY   )

                           , .S0_BID               (S0_BID      )
                           , .S0_BRESP             (S0_BRESP    )
                           , .S0_BVALID            (S0_BVALID   )
                           , .S0_BREADY            (S0_BREADY_M1)
                           , .S0_RID               (S0_RID      )
                           , .S0_RDATA             (S0_RDATA    )
                           , .S0_RRESP             (S0_RRESP    )
                           , .S0_RLAST             (S0_RLAST    )
                           , .S0_RVALID            (S0_RVALID   )
                           , .S0_RREADY            (S0_RREADY_M1)

                           , .S1_BID               (S1_BID      )
                           , .S1_BRESP             (S1_BRESP    )
                           , .S1_BVALID            (S1_BVALID   )
                           , .S1_BREADY            (S1_BREADY_M1)
                           , .S1_RID               (S1_RID      )
                           , .S1_RDATA             (S1_RDATA    )
                           , .S1_RRESP             (S1_RRESP    )
                           , .S1_RLAST             (S1_RLAST    )
                           , .S1_RVALID            (S1_RVALID   )
                           , .S1_RREADY            (S1_RREADY_M1)

                           , .S2_BID               (S2_BID      )
                           , .S2_BRESP             (S2_BRESP    )
                           , .S2_BVALID            (S2_BVALID   )
                           , .S2_BREADY            (S2_BREADY_M1)
                           , .S2_RID               (S2_RID      )
                           , .S2_RDATA             (S2_RDATA    )
                           , .S2_RRESP             (S2_RRESP    )
                           , .S2_RLAST             (S2_RLAST    )
                           , .S2_RVALID            (S2_RVALID   )
                           , .S2_RREADY            (S2_RREADY_M1)

                           , .SD_BID               (SD_BID      )
                           , .SD_BRESP             (SD_BRESP    )
                           , .SD_BVALID            (SD_BVALID   )
                           , .SD_BREADY            (SD_BREADY_M1)
                           , .SD_RID               (SD_RID      )
                           , .SD_RDATA             (SD_RDATA    )
                           , .SD_RRESP             (SD_RRESP    )
                           , .SD_RLAST             (SD_RLAST    )
                           , .SD_RVALID            (SD_RVALID   )
                           , .SD_RREADY            (SD_RREADY_M1)

                           , .r_order_grant        (r_order_grant) //input wire [7:0] [3:0]
                           , .arbiter_type         (arbiter_type)
     );

     // slaves to master for master 2
     axi_s2m_s3 #( .MASTER_ID (3       )
                  , .W_CID     (W_CID   )
                  , .W_ID      (W_ID    )
                  , .W_ADDR    (W_ADDR  )
                  , .W_DATA    (W_DATA  )
                  , .W_STRB    (W_STRB  )
                  , .W_SID     (W_SID   )
                 )
     u_axi_stom_m2 (
           .AXI_RSTn             (AXI_RSTn    )
         , .AXI_CLK              (AXI_CLK     )

         , .M_MID                (M2_MID      )
         , .M_BID                (M2_BID      )
         , .M_BRESP              (M2_BRESP    )
         , .M_BVALID             (M2_BVALID   )
         , .M_BREADY             (M2_BREADY   )
         , .M_RSID               (M2_RSID     )
         , .M_RDATA              (M2_RDATA    )
         , .M_RRESP              (M2_RRESP    )
         , .M_RLAST              (M2_RLAST    )
         , .M_RVALID             (M2_RVALID   )
         , .M_RREADY             (M2_RREADY   )

                           , .S0_BID               (S0_BID      )
                           , .S0_BRESP             (S0_BRESP    )
                           , .S0_BVALID            (S0_BVALID   )
                           , .S0_BREADY            (S0_BREADY_M2)
                           , .S0_RID               (S0_RID      )
                           , .S0_RDATA             (S0_RDATA    )
                           , .S0_RRESP             (S0_RRESP    )
                           , .S0_RLAST             (S0_RLAST    )
                           , .S0_RVALID            (S0_RVALID   )
                           , .S0_RREADY            (S0_RREADY_M2)

                           , .S1_BID               (S1_BID      )
                           , .S1_BRESP             (S1_BRESP    )
                           , .S1_BVALID            (S1_BVALID   )
                           , .S1_BREADY            (S1_BREADY_M2)
                           , .S1_RID               (S1_RID      )
                           , .S1_RDATA             (S1_RDATA    )
                           , .S1_RRESP             (S1_RRESP    )
                           , .S1_RLAST             (S1_RLAST    )
                           , .S1_RVALID            (S1_RVALID   )
                           , .S1_RREADY            (S1_RREADY_M2)

                           , .S2_BID               (S2_BID      )
                           , .S2_BRESP             (S2_BRESP    )
                           , .S2_BVALID            (S2_BVALID   )
                           , .S2_BREADY            (S2_BREADY_M2)
                           , .S2_RID               (S2_RID      )
                           , .S2_RDATA             (S2_RDATA    )
                           , .S2_RRESP             (S2_RRESP    )
                           , .S2_RLAST             (S2_RLAST    )
                           , .S2_RVALID            (S2_RVALID   )
                           , .S2_RREADY            (S2_RREADY_M2)

                           , .SD_BID               (SD_BID      )
                           , .SD_BRESP             (SD_BRESP    )
                           , .SD_BVALID            (SD_BVALID   )
                           , .SD_BREADY            (SD_BREADY_M2)
                           , .SD_RID               (SD_RID      )
                           , .SD_RDATA             (SD_RDATA    )
                           , .SD_RRESP             (SD_RRESP    )
                           , .SD_RLAST             (SD_RLAST    )
                           , .SD_RVALID            (SD_RVALID   )
                           , .SD_RREADY            (SD_RREADY_M2)

                           , .r_order_grant        (r_order_grant) //input wire [7:0] [3:0]
                           , .arbiter_type         (arbiter_type)
     );
     
endmodule
