
/*-----------------------------------
// TEST ALL CASE FOR INTERCONNECT.
//----------------------------------
// How to use:
// 1. Uncomment the code block for which you want to test
// 2. Comment other code blocks
// 3. make
------------------------------------*/
`timescale 1ns / 1ps
`define APB_CFG
module axi_interconnect_tb();

localparam W_CID   =  4;          // Channel ID width
localparam W_ID    =  4;          // Master ID width
localparam W_SID   = (W_CID+W_ID);// Slave ID width
localparam W_ADDR  = 32;          // Address width
localparam W_DATA  = 32;          // Data width
localparam W_STRB  = (W_DATA/8);  // Data strobe width
localparam W_LEN   = 8 ;          // Burst len, 256
localparam W_SIZE  = 3 ;          // Burst size
localparam W_BURST = 2 ;          // Burst type
localparam W_RESP  = 2 ;          // Read data resp

localparam   PERIOD = 10; //ns, 100MHz                       

integer i, j;

reg                   rstn                      ;
reg                   clk                       ;

//master
reg  [W_ID-1    : 0]   M_AXI_AWID    [0:2]      ;
reg  [W_ADDR-1  : 0]   M_AXI_AWADDR  [0:2]      ;
reg  [W_LEN-1   : 0]   M_AXI_AWLEN   [0:2]      ;
reg  [W_SIZE-1  : 0]   M_AXI_AWSIZE  [0:2]      ;
reg  [W_BURST-1 : 0]   M_AXI_AWBURST [0:2]      ;
reg                    M_AXI_AWVALID [0:2]      ;
wire                   M_AXI_AWREADY [0:2]      ;

reg  [W_ID-1   : 0]    M_AXI_WID     [0:2]      ;
reg  [W_DATA-1 : 0]    M_AXI_WDATA   [0:2]      ;
reg  [W_STRB-1 : 0]    M_AXI_WSTRB   [0:2]      ;
reg                    M_AXI_WLAST   [0:2]      ;
reg                    M_AXI_WVALID  [0:2]      ;
wire                   M_AXI_WREADY  [0:2]      ;

wire [W_ID-1   : 0]    M_AXI_BID     [0:2]      ;
wire [W_RESP-1 : 0]    M_AXI_BRESP   [0:2]      ;
wire                   M_AXI_BVALID  [0:2]      ;
reg                    M_AXI_BREADY  [0:2]      ;


reg  [W_ID-1    : 0]   M_AXI_ARID    [0:2]      ;
reg  [W_ADDR-1  : 0]   M_AXI_ARADDR  [0:2]      ;
reg  [W_LEN-1   : 0]   M_AXI_ARLEN   [0:2]      ;
reg  [W_SIZE-1  : 0]   M_AXI_ARSIZE  [0:2]      ;
reg  [W_BURST-1 : 0]   M_AXI_ARBURST [0:2]      ;
reg                    M_AXI_ARVALID [0:2]      ;
wire                   M_AXI_ARREADY [0:2]      ;

wire [W_ID-1   : 0]    M_AXI_RID     [0:2]      ;
wire [W_DATA-1 : 0]    M_AXI_RDATA   [0:2]      ;
wire [W_RESP-1 : 0]    M_AXI_RRESP   [0:2]      ;
wire                   M_AXI_RLAST   [0:2]      ;
wire                   M_AXI_RVALID  [0:2]      ;
reg                    M_AXI_RREADY  [0:2]      ;

//slave
wire [W_SID-1   : 0]   S_AXI_AWID    [0:2]      ;
wire [W_ADDR-1  : 0]   S_AXI_AWADDR  [0:2]      ;
wire [W_LEN-1   : 0]   S_AXI_AWLEN   [0:2]      ;
wire [W_SIZE-1  : 0]   S_AXI_AWSIZE  [0:2]      ;
wire [W_BURST-1 : 0]   S_AXI_AWBURST [0:2]      ;
wire                   S_AXI_AWVALID [0:2]      ;
reg                    S_AXI_AWREADY [0:2]      ;

wire [W_SID-1  : 0]    S_AXI_WID     [0:2]      ;
wire [W_DATA-1 : 0]    S_AXI_WDATA   [0:2]      ;
wire [W_STRB-1 : 0]    S_AXI_WSTRB   [0:2]      ;
wire                   S_AXI_WLAST   [0:2]      ;
wire                   S_AXI_WVALID  [0:2]      ;
reg                    S_AXI_WREADY  [0:2]      ;

reg  [W_SID-1  : 0]    S_AXI_BID     [0:2]      ;
reg  [W_RESP-1 : 0]    S_AXI_BRESP   [0:2]      ;
reg                    S_AXI_BVALID  [0:2]      ;
wire                   S_AXI_BREADY  [0:2]      ;

wire [W_SID-1   : 0]   S_AXI_ARID    [0:2]      ;
wire [W_ADDR-1  : 0]   S_AXI_ARADDR  [0:2]      ;
wire [W_LEN-1   : 0]   S_AXI_ARLEN   [0:2]      ;
wire [W_SIZE-1  : 0]   S_AXI_ARSIZE  [0:2]      ;
wire [W_BURST-1 : 0]   S_AXI_ARBURST [0:2]      ;
wire                   S_AXI_ARVALID [0:2]      ;
reg                    S_AXI_ARREADY [0:2]      ;

reg  [W_SID-1  : 0]    S_AXI_RID     [0:2]      ;
reg  [W_DATA-1 : 0]    S_AXI_RDATA   [0:2]      ;
reg  [W_RESP-1 : 0]    S_AXI_RRESP   [0:2]      ;
reg                    S_AXI_RLAST   [0:2]      ;
reg                    S_AXI_RVALID  [0:2]      ;
wire                   S_AXI_RREADY  [0:2]      ;

//apb
reg                    pwrite ;
reg                    psel   ;
reg                    penable;
reg  [W_ADDR-1 : 0]    paddr  ;
reg  [W_DATA-1 : 0]    pwdata ;
wire [W_DATA-1 : 0]    prdata ;

initial begin
    wait(rstn);
    @(posedge clk);
    @(posedge clk);

    //{{------------outstanding transaction test----------------
    // read transaction outstanding test
    for (j = 0; j < 4; j++) begin // transaction_j, mst0 to slv0, len=0
        Mx_send_raddr(2'd0, 4'b0001, (32'h0000_10a1+j), 8'h0, 3'b101, 2'b01);
        @(posedge clk);
        while (!M_AXI_ARREADY[2'd0]) @(posedge clk);
    end
    Mx_clr_raddr(2'd0);

    for (j = 0; j < 4; j++) begin // rdata, //slv0 to mst0
        Sx_send_rdata(2'd0, 8'b0101_0001, (32'h00d1+j), 2'b00, 1'b1);
        @(posedge clk)
        while (!S_AXI_RREADY[2'd0]) @(posedge clk);
    end
    Sx_clr_rdata(2'd0);

    // // write transaction outstanding test
    // for (j = 0; j < 4; j++) begin // transaction_j, mst1 to slv1
    //     Mx_send_waddr(2'd1, 4'b1001, (32'h0000_20a1+j), 8'h0, 3'b101, 2'b01);
    //     @(posedge clk);
    //     while (!M_AXI_AWREADY[2'd1]) @(posedge clk);
    //     Mx_clr_waddr(2'd1);
    // end
    // for (j = 0; j < 4; j++) begin
    //     Mx_send_wdata(2'd1, 4'b1001, (32'h00d0+j), 4'hf, 1'b1);// wdata
    //     @(posedge clk)
    //     while (!M_AXI_WREADY[2'd1]) @(posedge clk);
    //     Mx_clr_wdata(2'd1);
    //     while (!(S_AXI_WLAST[2'd1] & S_AXI_WREADY[2'd1] & S_AXI_WVALID[2'd1])) @(posedge clk);
    //     Sx_send_bresp(1, 8'b1010_1001, 0);// bresp
    //     @(posedge clk)
    //     Sx_clr_bresp(1);
    // end
    // //}}------------outstanding transaction test----------------

    // //{{------------max outstanding transaction----------------
    // S_AXI_AWREADY[0] = 0; @(posedge clk); 
    // for (j = 0; j < 10; j++) begin
    //     Mx_send_waddr(2'd0, 4'b0101, (32'h0000_10a1+j), 8'hff, 3'b101, 2'b01);
    //     @(posedge clk); while (!M_AXI_AWREADY[2'd0]) @(posedge clk);
    // end
    // //}}------------max outstanding transaction----------------


    // //{{------------r incrementing burst 256拍 test----------------
    // // read transaction raddr phase
    // Mx_send_raddr(2'd2, 4'b0001, 32'h0000_30a0, 8'hff, 3'b101, 2'b01); //mst2 to slv2
    // @(posedge clk);
    // while (!M_AXI_ARREADY[2'd2]) @(posedge clk);
    // Mx_clr_raddr(2'd2);

    // // read transaction rdata phase
    // for (j = 0; j < 255; j++) begin // rdata, slv2 to mst2 
    //     Sx_send_rdata(2'd2, 8'b1111_0001, (32'd0+j), 2'b00, 1'b0);
    //     @(posedge clk)
    //     while (!S_AXI_RREADY[2'd2]) @(posedge clk);
    // end
    //     Sx_send_rdata(2'd2, 8'b1111_0001, (32'd255), 2'b00, 1'b1);//rlast
    //     @(posedge clk)
    //     while (!S_AXI_RREADY[2'd2]) @(posedge clk);
    //     Sx_clr_rdata(2'd2);
    // // //}}------------r incrementing burst 256拍 test----------------


    // //{{------------w incrementing burst 256拍 test----------------
    // // write transaction waddr phase
    // Mx_send_waddr(2'd0, 4'b1001, 32'h0000_20a0, 8'hff, 3'b101, 2'b01); //mst0 to slv1
    // @(posedge clk);  while(!M_AXI_ARREADY[2'd0]) @(posedge clk); Mx_clr_waddr(2'd0);

    // // write transaction wdata phase
    // @(posedge clk); @(posedge clk);
    // for (j = 0; j < 255; j++) begin // wdata, mst0 to slv1
    //     Mx_send_wdata(2'd0, 4'b1001, (32'd0+j), 4'hf, 1'b0);
    //     @(posedge clk)  while(!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd0);
    // end
    //     Mx_send_wdata(2'd0, 4'b1001, (32'd255), 4'hf, 1'b1);//rlast
    //     @(posedge clk)  while(!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd0);
    //     while (!(S_AXI_WLAST[2'd1] & S_AXI_WREADY[2'd1] & S_AXI_WVALID[2'd1])) @(posedge clk);
    //     Sx_send_bresp(1, 8'b1001_1001, 0);// bresp
    // //}}------------w incrementing burst 256拍 test----------------


    // //{{------------------read out of order test----------------------
    // //raddr phase - out of order - different M_ARID
    // Mx_send_raddr(2'd0, 4'b0001, 32'h0000_10a1, 8'h1, 3'b101, 2'b01);//mst0 to slv0
    // @(posedge clk);  while (!M_AXI_ARREADY[2'd0]) @(posedge clk);
    // Mx_send_raddr(2'd0, 4'b0010, 32'h0000_20a2, 8'h1, 3'b101, 2'b01);//mst0 to slv1
    // @(posedge clk);  while (!M_AXI_ARREADY[2'd0]) @(posedge clk);
    // Mx_clr_raddr(2'd0);

    // //rdata phase - out of order
    // Sx_send_rdata(2'd1, 8'b1001_0010, 32'h10d3, 2'b00, 1'b0); //slv1 to mst0
    // @(posedge clk);  while (!S_AXI_RREADY[2'd1]) @(posedge clk);
    // Sx_send_rdata(2'd1, 8'b1001_0010, 32'h10d4, 2'b00, 1'b1); //slv1 to mst0
    // @(posedge clk);  while (!S_AXI_RREADY[2'd1]) @(posedge clk);
    // Sx_clr_rdata(2'd1);
    // Sx_send_rdata(2'd0, 8'b0101_0001, 32'h00d1, 2'b00, 1'b0); //slv0 to mst0
    // @(posedge clk);  while (!S_AXI_RREADY[2'd0]) @(posedge clk);
    // Sx_send_rdata(2'd0, 8'b0101_0001, 32'h00d2, 2'b00, 1'b1); //slv0 to mst0
    // @(posedge clk);  while (!S_AXI_RREADY[2'd0]) @(posedge clk);
    // Sx_clr_rdata(2'd0);

    // @(posedge clk);
    // //raddr phase - same M_ARID
    // Mx_send_raddr(2'd0, 4'b0001, 32'h0000_10a3, 8'h1, 3'b101, 2'b01);//mst0 to slv0
    // @(posedge clk);  while (!M_AXI_ARREADY[2'd0]) @(posedge clk);
    // Mx_send_raddr(2'd0, 4'b0001, 32'h0000_20a4, 8'h1, 3'b101, 2'b01);//mst0 to slv1
    // @(posedge clk);  while (!M_AXI_ARREADY[2'd0]) @(posedge clk);
    // Mx_clr_raddr(2'd0);

    // //rdata phase - out of order
    // Sx_send_rdata(2'd1, 8'b1001_0001, 32'h10d3, 2'b00, 1'b0); //slv1 to mst0
    // @(posedge clk);  while (!S_AXI_RREADY[2'd1]) @(posedge clk);
    // Sx_send_rdata(2'd1, 8'b1001_0001, 32'h10d4, 2'b00, 1'b1); //slv1 to mst0
    // @(posedge clk);  while (!S_AXI_RREADY[2'd1]) @(posedge clk);
    // Sx_clr_rdata(2'd1);

    // Sx_send_rdata(2'd0, 8'b0101_0001, 32'h00d1, 2'b00, 1'b0); //slv0 to mst0
    // @(posedge clk);  while (!S_AXI_RREADY[2'd0]) @(posedge clk);
    // Sx_send_rdata(2'd0, 8'b0101_0001, 32'h00d2, 2'b00, 1'b1); //slv0 to mst0
    // @(posedge clk);  while (!S_AXI_RREADY[2'd0]) @(posedge clk);
    // Sx_clr_rdata(2'd0);
    // //}}------------------read out of order test----------------------


    // //{{------------test write out of order------------------
    // //------ waddr phase - different M_ARID ------
    // Mx_send_waddr(2'd0, 4'b0100, 32'h0000_10a1, 8'h1, 3'b101, 2'b01);//mst0 to slv0
    // @(posedge clk);  while(!M_AXI_AWREADY[2'd0]) @(posedge clk); Mx_clr_waddr(2'd0);
    // Mx_send_waddr(2'd1, 4'b0101, 32'h0000_10a2, 8'h1, 3'b101, 2'b01);//mst1 to slv0
    // @(posedge clk);  while(!M_AXI_AWREADY[2'd0]) @(posedge clk); Mx_clr_waddr(1);

    // //wdata phase
    // @(posedge clk); @(posedge clk);
    // Mx_send_wdata(2'd1, 4'b0101, 32'h10d3, 4'hf, 1'b0);//mst1 to slv0
    // @(posedge clk)  while(!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd1);
    // Mx_send_wdata(2'd1, 4'b0101, 32'h10d4, 4'hf, 1'b1);//mst1 to slv0
    // @(posedge clk)  while(!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd1);
    // while (!(S_AXI_WLAST[2'd0] & S_AXI_WREADY[2'd0] & S_AXI_WVALID[2'd0])) @(posedge clk);
    // Sx_send_bresp(0, 8'b0110_0101, 0); @(posedge clk) Sx_clr_bresp(0); //B_* for M1

    // Mx_send_wdata(2'd0, 4'b0100, 32'h00d1, 4'hf, 1'b0);//mst0 to slv0
    // @(posedge clk)  while (!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd0);
    // Mx_send_wdata(2'd0, 4'b0100, 32'h00d2, 4'hf, 1'b1);//mst0 to slv0
    // @(posedge clk)  while(!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd0);
    // while (!(S_AXI_WLAST[2'd0] & S_AXI_WREADY[2'd0] & S_AXI_WVALID[2'd0])) @(posedge clk);
    // Sx_send_bresp(0, 8'b0101_0100, 0); @(posedge clk) Sx_clr_bresp(0); //B_* for M0

    // @(posedge clk);
    // //------ waddr phase - same M_ARID ------
    // Mx_send_waddr(2'd0, 4'b0100, 32'h0000_10a1, 8'h1, 3'b101, 2'b01);//mst0 to slv0
    // @(posedge clk);  while(!M_AXI_AWREADY[2'd0]) @(posedge clk); Mx_clr_waddr(2'd0);
    // Mx_send_waddr(2'd1, 4'b0100, 32'h0000_10a2, 8'h1, 3'b101, 2'b01);//mst1 to slv0
    // @(posedge clk);  while(!M_AXI_AWREADY[2'd0]) @(posedge clk); Mx_clr_waddr(1);

    // //wdata phase
    // @(posedge clk); @(posedge clk);
    // Mx_send_wdata(2'd1, 4'b0100, 32'h10d3, 4'hf, 1'b0);//mst1 to slv0
    // @(posedge clk)  while(!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd1);
    // Mx_send_wdata(2'd1, 4'b0100, 32'h10d4, 4'hf, 1'b1);//mst1 to slv0
    // @(posedge clk)  while(!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd1);
    // Mx_send_wdata(2'd0, 4'b0100, 32'h00d1, 4'hf, 1'b0);//mst0 to slv0
    // @(posedge clk)  while (!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd0);
    // Mx_send_wdata(2'd0, 4'b0100, 32'h00d2, 4'hf, 1'b1);//mst0 to slv0
    // @(posedge clk)  while(!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd0);

    // while (!(S_AXI_WLAST[2'd0] & S_AXI_WREADY[2'd0] & S_AXI_WVALID[2'd0])) @(posedge clk);
    // Sx_send_bresp(0, 8'b0101_0100, 0); @(posedge clk) Sx_clr_bresp(0); //B_* for M0
    // while (!(S_AXI_WLAST[2'd0] & S_AXI_WREADY[2'd0] & S_AXI_WVALID[2'd0])) @(posedge clk);
    // Sx_send_bresp(0, 8'b0110_0100, 0); @(posedge clk) Sx_clr_bresp(0); //B_* for M1
    // //}}------------test write out of order------------------
    

    // //{{------------test read interleaving------------------
    // //raddr phase - different M_ARID
    // Mx_send_raddr(2'd0, 4'b0001, 32'h0000_10a1, 8'h1, 3'b101, 2'b01);//mst0 to slv0
    // @(posedge clk);  while(!M_AXI_ARREADY[2'd0]) @(posedge clk);
    // Mx_send_raddr(2'd0, 4'b0010, 32'h0000_20a2, 8'h1, 3'b101, 2'b01);//mst0 to slv1
    // @(posedge clk);  while(!M_AXI_ARREADY[2'd0]) @(posedge clk); Mx_clr_raddr(2'd0);

    // //rdata phase - interleaving
    // Sx_send_rdata(2'd1, 8'b1001_0010, 32'h10d3, 2'b00, 1'b0); //slv1 to mst0
    // @(posedge clk);  while(!S_AXI_RREADY[2'd1]) @(posedge clk); Sx_clr_rdata(2'd1);
    // Sx_send_rdata(2'd0, 8'b0101_0001, 32'h00d1, 2'b00, 1'b0); //slv0 to mst0
    // @(posedge clk);  while(!S_AXI_RREADY[2'd0]) @(posedge clk); Sx_clr_rdata(2'd0);
    // Sx_send_rdata(2'd1, 8'b1001_0010, 32'h10d4, 2'b00, 1'b1); //slv1 to mst0
    // @(posedge clk);  while(!S_AXI_RREADY[2'd1]) @(posedge clk); Sx_clr_rdata(2'd1);
    // Sx_send_rdata(2'd0, 8'b0101_0001, 32'h00d2, 2'b00, 1'b1); //slv0 to mst0
    // @(posedge clk);  while(!S_AXI_RREADY[2'd0]) @(posedge clk); Sx_clr_rdata(2'd0);

    // //raddr phase - same M_ARID
    // Mx_send_raddr(2'd0, 4'b0001, 32'h0000_10a1, 8'h1, 3'b101, 2'b01);//mst0 to slv0
    // @(posedge clk);  while(!M_AXI_ARREADY[2'd0]) @(posedge clk);
    // Mx_send_raddr(2'd0, 4'b0001, 32'h0000_20a2, 8'h1, 3'b101, 2'b01);//mst0 to slv1
    // @(posedge clk);  while(!M_AXI_ARREADY[2'd0]) @(posedge clk); Mx_clr_raddr(2'd0);

    // //rdata phase - interleaving - need hold-order
    // Sx_send_rdata(2'd1, 8'b1001_0001, 32'h10d3, 2'b00, 1'b0); //slv1 to mst0
    // @(posedge clk);  while(!S_AXI_RREADY[2'd1]) @(posedge clk); Sx_clr_rdata(2'd1);
    // Sx_send_rdata(2'd0, 8'b0101_0001, 32'h00d1, 2'b00, 1'b0); //slv0 to mst0
    // @(posedge clk);  while(!S_AXI_RREADY[2'd0]) @(posedge clk); Sx_clr_rdata(2'd0);
    // Sx_send_rdata(2'd1, 8'b1001_0001, 32'h10d4, 2'b00, 1'b1); //slv1 to mst0
    // @(posedge clk);  while(!S_AXI_RREADY[2'd1]) @(posedge clk); Sx_clr_rdata(2'd1);
    // Sx_send_rdata(2'd0, 8'b0101_0001, 32'h00d2, 2'b00, 1'b1); //slv0 to mst0
    // @(posedge clk);  while(!S_AXI_RREADY[2'd0]) @(posedge clk); Sx_clr_rdata(2'd0);
    // //}}------------test read interleaving------------------


    // //{{------------test write interleaving------------------
    // //------ waddr phase - different M_ARID ------
    // Mx_send_waddr(2'd0, 4'b0100, 32'h0000_10a1, 8'h1, 3'b101, 2'b01);//mst0 to slv0
    // @(posedge clk);  while(!M_AXI_AWREADY[2'd0]) @(posedge clk); Mx_clr_waddr(2'd0);
    // Mx_send_waddr(2'd1, 4'b0101, 32'h0000_10a2, 8'h1, 3'b101, 2'b01);//mst1 to slv0
    // @(posedge clk);  while(!M_AXI_AWREADY[2'd0]) @(posedge clk); Mx_clr_waddr(1);

    // //wdata phase
    // @(posedge clk); @(posedge clk);
    // Mx_send_wdata(2'd1, 4'b0101, 32'h10d3, 4'hf, 1'b0);//mst1 to slv0
    // @(posedge clk)  while(!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd1);
    // Mx_send_wdata(2'd0, 4'b0100, 32'h00d1, 4'hf, 1'b0);//mst0 to slv0
    // @(posedge clk)  while (!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd0);
    // Mx_send_wdata(2'd1, 4'b0101, 32'h10d4, 4'hf, 1'b1);//mst1 to slv0
    // @(posedge clk)  while(!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd1);
    // Mx_send_wdata(2'd0, 4'b0100, 32'h00d2, 4'hf, 1'b1);//mst0 to slv0
    // @(posedge clk)  while(!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd0);
    
    // while (!(S_AXI_WLAST[2'd0] & S_AXI_WREADY[2'd0] & S_AXI_WVALID[2'd0])) @(posedge clk);
    // Sx_send_bresp(0, 8'b0110_0101, 0); @(posedge clk) Sx_clr_bresp(0); //B_* for M1
    // while (!(S_AXI_WLAST[2'd0] & S_AXI_WREADY[2'd0] & S_AXI_WVALID[2'd0])) @(posedge clk);
    // Sx_send_bresp(0, 8'b0101_0100, 0); @(posedge clk) Sx_clr_bresp(0); //B_* for M0

    // @(posedge clk);
    // //------ waddr phase - same M_ARID ------
    // Mx_send_waddr(2'd0, 4'b0100, 32'h0000_10a1, 8'h1, 3'b101, 2'b01);//mst0 to slv0
    // @(posedge clk);  while(!M_AXI_AWREADY[2'd0]) @(posedge clk); Mx_clr_waddr(2'd0);
    // Mx_send_waddr(2'd1, 4'b0100, 32'h0000_10a2, 8'h1, 3'b101, 2'b01);//mst1 to slv0
    // @(posedge clk);  while(!M_AXI_AWREADY[2'd0]) @(posedge clk); Mx_clr_waddr(1);

    // //wdata phase
    // @(posedge clk); @(posedge clk);
    // Mx_send_wdata(2'd1, 4'b0100, 32'h10d3, 4'hf, 1'b0);//mst1 to slv0
    // @(posedge clk)  while(!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd1);
    // Mx_send_wdata(2'd0, 4'b0100, 32'h00d1, 4'hf, 1'b0);//mst0 to slv0
    // @(posedge clk)  while (!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd0);
    // Mx_send_wdata(2'd1, 4'b0100, 32'h10d4, 4'hf, 1'b1);//mst1 to slv0
    // @(posedge clk)  while(!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd1);
    // Mx_send_wdata(2'd0, 4'b0100, 32'h00d2, 4'hf, 1'b1);//mst0 to slv0
    // @(posedge clk)  while(!M_AXI_WREADY[2'd0]) @(posedge clk); Mx_clr_wdata(2'd0);
    
    // while (!(S_AXI_WLAST[2'd0] & S_AXI_WREADY[2'd0] & S_AXI_WVALID[2'd0])) @(posedge clk);
    // Sx_send_bresp(0, 8'b0101_0100, 0); @(posedge clk) Sx_clr_bresp(0); //B_* for M0
    // while (!(S_AXI_WLAST[2'd0] & S_AXI_WREADY[2'd0] & S_AXI_WVALID[2'd0])) @(posedge clk);
    // Sx_send_bresp(0, 8'b0110_0100, 0); @(posedge clk) Sx_clr_bresp(0); //B_* for M1
    // //}}------------test write interleaving------------------


    
    // //{{************each mst talk to each slv****************
    // //------slv0-----
    // Mx_send_raddr(2'd0, 4'b0001, 32'h0000_10a1, 8'h0, 3'b101, 2'b01);//mst0 to slv0
    // Mx_send_raddr(2'd1, 4'b0010, 32'h0000_10a2, 8'h0, 3'b101, 2'b01);//mst1 to slv0
    // Mx_send_raddr(2'd2, 4'b0011, 32'h0000_10a3, 8'h0, 3'b101, 2'b01);//mst2 to slv0
    // @(posedge clk); Mx_clr_raddr(2'd0); Mx_clr_raddr(2'd1); Mx_clr_raddr(2'd2);

    // @(posedge clk); @(posedge clk);
    // Sx_send_rdata(2'd0, 8'b0101_0001, 32'h00d1, 2'b00, 1'b1); //slv0 to mst0
    // @(posedge clk); Sx_clr_rdata(2'd0);
    // Sx_send_rdata(2'd0, 8'b0110_0010, 32'h01d2, 2'b00, 1'b1); //slv0 to mst1
    // @(posedge clk); Sx_clr_rdata(2'd0);
    // Sx_send_rdata(2'd0, 8'b0111_0011, 32'h02d3, 2'b00, 1'b1); //slv0 to mst2
    // @(posedge clk); Sx_clr_rdata(2'd0);

    // //------slv1------
    // Mx_send_raddr(2'd0, 4'b0001, 32'h0000_20a1, 8'h0, 3'b101, 2'b01);//mst0 to slv1
    // Mx_send_raddr(2'd1, 4'b0010, 32'h0000_20a2, 8'h0, 3'b101, 2'b01);//mst1 to slv1
    // Mx_send_raddr(2'd2, 4'b0011, 32'h0000_20a3, 8'h0, 3'b101, 2'b01);//mst2 to slv1
    // @(posedge clk); Mx_clr_raddr(2'd0); Mx_clr_raddr(2'd1); Mx_clr_raddr(2'd2);

    // @(posedge clk); @(posedge clk); @(posedge clk);
    // Sx_send_rdata(2'd1, 8'b1001_0001, 32'h10d1, 2'b00, 1'b1); //slv1 to mst0
    // @(posedge clk); Sx_clr_rdata(2'd1);
    // Sx_send_rdata(2'd1, 8'b1010_0010, 32'h11d2, 2'b00, 1'b1); //slv1 to mst1
    // @(posedge clk); Sx_clr_rdata(2'd1);
    // Sx_send_rdata(2'd1, 8'b1011_0011, 32'h12d3, 2'b00, 1'b1); //slv1 to mst2
    // @(posedge clk); Sx_clr_rdata(2'd1);

    // //------slv2------
    // Mx_send_raddr(2'd0, 4'b0001, 32'h0000_30a1, 8'h0, 3'b101, 2'b01);//mst0 to slv2
    // Mx_send_raddr(2'd1, 4'b0010, 32'h0000_30a2, 8'h0, 3'b101, 2'b01);//mst1 to slv2
    // Mx_send_raddr(2'd2, 4'b0011, 32'h0000_30a3, 8'h0, 3'b101, 2'b01);//mst2 to slv2
    // @(posedge clk); Mx_clr_raddr(2'd0); Mx_clr_raddr(2'd1); Mx_clr_raddr(2'd2);

    // @(posedge clk); @(posedge clk); @(posedge clk);
    // Sx_send_rdata(2'd2, 8'b1101_0001, 32'h20d1, 2'b00, 1'b1); //slv2 to mst0
    // @(posedge clk); Sx_clr_rdata(2'd2);
    // Sx_send_rdata(2'd2, 8'b1110_0010, 32'h21d2, 2'b00, 1'b1); //slv2 to mst1
    // @(posedge clk); Sx_clr_rdata(2'd2);
    // Sx_send_rdata(2'd2, 8'b1111_0011, 32'h22d3, 2'b00, 1'b1); //slv2 to mst2
    // @(posedge clk); Sx_clr_rdata(2'd2);
    // //}}************each mst talk to each slv****************

    // //{{************same time diff-mst talk to diff-slv****************
    // fork // addr phase
    //     Mx_send_raddr(2'd0, 4'b0001, 32'h0000_10a0, 8'h0, 3'b101, 2'b01);//mst0 to slv0
    //     Mx_send_raddr(2'd1, 4'b0001, 32'h0000_20a1, 8'h0, 3'b101, 2'b01);//mst1 to slv1
    //     Mx_send_raddr(2'd2, 4'b0001, 32'h0000_30a2, 8'h0, 3'b101, 2'b01);//mst2 to slv2
    // join
    // @(posedge clk); Mx_clr_raddr(2'd0); Mx_clr_raddr(2'd1); Mx_clr_raddr(2'd2);

    // @(posedge clk); @(posedge clk); @(posedge clk); @(posedge clk);
    // fork // data phase
    //     Sx_send_rdata(2'd0, 8'b0101_0001, 32'h00d1, 2'b00, 1'b1); //slv0 to mst0
    //     Sx_send_rdata(2'd1, 8'b1010_0001, 32'h11d2, 2'b00, 1'b1); //slv1 to mst1
    //     Sx_send_rdata(2'd2, 8'b1111_0001, 32'h22d3, 2'b00, 1'b1); //slv2 to mst2
    // join
    // @(posedge clk); Sx_clr_rdata(2'd0); Sx_clr_rdata(2'd1); Sx_clr_rdata(2'd2);
    // //}}************same time diff-mst talk to diff-slv****************

    // //{{************test arbiter m2s****************
    // Mx_send_raddr(2'd0, 4'b0001, 32'h0000_10a0, 8'h0, 3'b101, 2'b01);//mst0 to slv0
    // @(posedge clk);
    // fork
    //     Mx_send_raddr(2'd0, 4'b0001, 32'h0000_10a0, 8'h0, 3'b101, 2'b01);//mst0 to slv0
    //     Mx_send_raddr(2'd1, 4'b0001, 32'h0000_10a1, 8'h0, 3'b101, 2'b01);//mst1 to slv0
    //     Mx_send_raddr(2'd2, 4'b0001, 32'h0000_10a2, 8'h0, 3'b101, 2'b01);//mst2 to slv0
    // join
    // @(posedge clk); Mx_clr_raddr(2'd0); Mx_clr_raddr(2'd1); Mx_clr_raddr(2'd2);
    // //}}************test arbiter m2s****************

    // //{{************test arbiter s2m****************
    // Mx_send_raddr(2'd0, 4'b0001, 32'h0000_10a0, 8'h0, 3'b101, 2'b01);//mst0 to slv0
    // @(posedge clk);
    // Mx_send_raddr(2'd0, 4'b0001, 32'h0000_10a1, 8'h0, 3'b101, 2'b01);//mst0 to slv0
    // @(posedge clk);
    // Mx_send_raddr(2'd0, 4'b0010, 32'h0000_20a2, 8'h0, 3'b101, 2'b01);//mst0 to slv1
    // @(posedge clk);
    // Mx_send_raddr(2'd0, 4'b0011, 32'h0000_30a3, 8'h0, 3'b101, 2'b01);//mst0 to slv2
    // @(posedge clk); Mx_clr_raddr(2'd0); @(posedge clk);

    // Sx_send_rdata(2'd0, 8'b0101_0001, 32'h00d0, 2'b00, 1'b1); //slv0 to mst0
    // @(posedge clk);
    // fork
    //     Sx_send_rdata(2'd0, 8'b0101_0001, 32'h00d1, 2'b00, 1'b1); //slv0 to mst0
    //     Sx_send_rdata(2'd1, 8'b1001_0010, 32'h10d2, 2'b00, 1'b1); //slv1 to mst0
    //     Sx_send_rdata(2'd2, 8'b1101_0011, 32'h20d3, 2'b00, 1'b1); //slv2 to mst0
    // join
    // @(posedge clk); Sx_clr_rdata(2'd0); Sx_clr_rdata(2'd1); Sx_clr_rdata(2'd2);
    // //}}************test arbiter s2m****************


    // //{{-----------------Cross 4K test------------------
    // Mx_send_raddr(2'd0, 4'b0001, 32'h0000_1ff0, 8'h1f, 3'b101, 2'b01);
    // @(posedge clk);
    // while (!M_AXI_ARREADY[2'd0]) @(posedge clk);
    // Mx_clr_raddr(2'd0);
    // //}}-----------------Cross 4K test------------------


    // // {{************default slave*******************
    // Mx_send_raddr(2'd0, 4'b0001, 32'hface_1def, 8'hf, 3'b101, 2'b01);//mst0 to xxxx
    // @(posedge clk); Mx_clr_raddr(2'd0);
    // // }}************default slave*******************


    // //{{------------test write interleaving, reorder, APB CFG, arbiter----------------
    //     pwrite  <= 0; //IDLE
    //     psel    <= 0;
    //     paddr   <= 0;
    //     penable <= 0;@(posedge clk);
    //     // waddr phase
    //     Mx_send_waddr(2'd0, 4'b0101, 32'h0000_1001, 8'h1, 3'b101, 2'b01);//mst0 to slv0
    //     @(posedge clk); while (!M_AXI_AWREADY[2'd0]) @(posedge clk); Mx_clr_waddr(2'd0);
    //     Mx_send_waddr(2'd1, 4'b0101, 32'h0000_1002, 8'h1, 3'b101, 2'b01);//mst1 to slv0
    //     @(posedge clk); while (!M_AXI_AWREADY[2'd0]) @(posedge clk); Mx_clr_waddr(1); @(posedge clk);
    //     pwrite  <= 0; //SETUP
    //     psel    <= 1;
    //     paddr   <= 32'h50000000 + 8'h4;
    //     penable <= 0; @(posedge clk);

    //     pwrite  <= 0; //ENABLE
    //     psel    <= 1;
    //     paddr   <= 32'h50000000 + 8'h4;
    //     penable <= 1; @(posedge clk);

    //     pwrite  <= 0; //IDLE
    //     psel    <= 0;
    //     paddr   <= 0;
    //     penable <= 0;

    //     //arbiter
    //     pwrite  <= 1; //SETUP
    //     pwdata  <= 1;
    //     psel    <= 1;
    //     paddr   <= 32'h50000000 + 8'h14;
    //     penable <= 0; @(posedge clk);

    //     pwrite  <= 1; //ENABLE
    //     pwdata  <= 1;
    //     psel    <= 1;
    //     paddr   <= 32'h50000000 + 8'h14;
    //     penable <= 1; @(posedge clk);

    //     pwrite  <= 0; //IDLE
    //     pwdata  <= 0;
    //     psel    <= 0;
    //     paddr   <= 0;
    //     penable <= 0;

    //     Mx_send_waddr(2'd1, 4'b0101, 32'hface_1def, 8'h1, 3'b101, 2'b01);//mst1 to xxx
    //     @(posedge clk); while (!M_AXI_AWREADY[2'd0]) @(posedge clk); Mx_clr_waddr(1); @(posedge clk);
    //     pwrite  <= 0; //SETUP
    //     psel    <= 1;
    //     paddr   <= 32'h50000000;
    //     penable <= 0;
    //     @(posedge clk);
    //     pwrite  <= 0; //ENABLE
    //     psel    <= 1;
    //     paddr   <= 32'h50000000;
    //     penable <= 1;
    //     @(posedge clk);
    //     pwrite  <= 0; //IDLE
    //     psel    <= 0;
    //     paddr   <= 0;
    //     penable <= 0;

    //     //slave_en
    //     @(posedge clk);
    //     pwrite  <= 1; //SETUP
    //     psel    <= 1;
    //     paddr   <= 32'h50000018;
    //     penable <= 0;
    //     @(posedge clk);
    //     pwrite  <= 1; //ENABLE
    //     psel    <= 1;
    //     paddr   <= 32'h50000018;
    //     penable <= 1;
    //     @(posedge clk);
    //     pwrite  <= 0; //IDLE
    //     psel    <= 0;
    //     paddr   <= 0;
    //     penable <= 0;

    // // wdata phase - interleaving - same id - need reorder
    // @(posedge clk);
    // @(posedge clk);
    // // fork
    //     begin
    //         Mx_send_wdata(2'd1, 4'b0101, 32'h003, 4'hf, 1'b0);//mst1 to slv0
    //         @(posedge clk)
    //         while (!M_AXI_WREADY[2'd0]) @(posedge clk);
    //         Mx_clr_wdata(2'd1);
    //     end
    //     begin
    //         Mx_send_wdata(2'd0, 4'b0101, 32'h001, 4'hf, 1'b0);//mst0 to slv0
    //         @(posedge clk)
    //         while (!M_AXI_WREADY[2'd0]) @(posedge clk);
    //         Mx_clr_wdata(2'd0);
    //     end
    // // join

    // fork
    //     begin
    //         Mx_send_wdata(2'd0, 4'b0101, 32'h002, 4'hf, 1'b1);//mst0 to slv0
    //         @(posedge clk)
    //         while (!M_AXI_WREADY[2'd0]) @(posedge clk);
    //         Mx_clr_wdata(2'd0);
    //     end
    //     begin
    //         Mx_send_wdata(2'd1, 4'b0101, 32'h004, 4'hf, 1'b1);//mst1 to slv0
    //         @(posedge clk)
    //         while (!M_AXI_WREADY[2'd0]) @(posedge clk);
    //         Mx_clr_wdata(2'd1);
    //     end
    //     begin //B_* for M0
    //         while (!(S_AXI_WLAST[2'd0] & S_AXI_WREADY[2'd0] & S_AXI_WVALID[2'd0])) @(posedge clk);
    //         Sx_send_bresp(0, 8'b0101_0101, 0);
    //         @(posedge clk)
    //         Sx_clr_bresp(0);
    //     // end
    //     // begin //B_* for M1
    //         while (!(S_AXI_WLAST[2'd0] & S_AXI_WREADY[2'd0] & S_AXI_WVALID[2'd0])) @(posedge clk);
    //         Sx_send_bresp(0, 8'b0110_0101, 0);
    //         @(posedge clk)
    //         Sx_clr_bresp(0);
    //     end
    // join

    // Mx_send_wdata(2'd1, 4'b0101, 32'h0df1, 4'hf, 1'b1);//mst0 to slv0
    // @(posedge clk)
    // while (!M_AXI_WREADY[2'd0]) @(posedge clk);
    // Mx_clr_wdata(2'd1);
    // Mx_send_wdata(2'd1, 4'b0101, 32'h0df2, 4'hf, 1'b1);//mst1 to slv0
    // @(posedge clk)
    // while (!M_AXI_WREADY[2'd0]) @(posedge clk);
    // Mx_clr_wdata(2'd1);
    // //}}------------test write interleaving, reorder, arbiter----------------

    
    
    //--------------test the arbiter in sid_buffer.v ------------------
    //{{
    // fork 
    //     begin
    //         Mx_send_raddr(2'd0, 4'b0001, 32'h0000_1001, 8'h1, 3'b101, 2'b01);//mst0 to slv0
    //         @(posedge clk);
    //         while (!M_AXI_ARREADY[2'd0]) @(posedge clk);
    //         Mx_clr_raddr(2'd0);
    //     end
    //     begin
    //         Mx_send_raddr(2'd1, 4'b0010, 32'h0000_2002, 8'h1, 3'b101, 2'b01);//mst0 to slv1
    //         @(posedge clk);
    //         while (!M_AXI_ARREADY[2'd1]) @(posedge clk);
    //         Mx_clr_raddr(1);//mst0
    //     end
    // join

    // // //rdata phase
    // @(posedge clk);
    // @(posedge clk);
    // fork
    //     begin
    //         Sx_send_rdata(2'd1, 8'b0110_0010, 32'h103, 2'b00, 1'b0);//slv1
    //         @(posedge clk)
    //         while (!S_AXI_RREADY[2'd1]) @(posedge clk);
    //         Sx_clr_rdata(2'd1);
    //     end
    //     begin
    //         Sx_send_rdata(2'd0, 8'b0001_0001, 32'h001, 2'b00, 1'b0);//slv0
    //         @(posedge clk)
    //         while (!S_AXI_RREADY[2'd0]) @(posedge clk);
    //         Sx_clr_rdata(2'd0);
    //     end
    // join

    // fork
    //     begin
    //         Sx_send_rdata(2'd1, 8'b0110_0010, 32'h104, 2'b00, 1'b1);//slv1
    //         @(posedge clk)
    //         while (!S_AXI_RREADY[2'd1]) @(posedge clk);
    //         Sx_clr_rdata(2'd1);
    //     end
    //     begin
    //         Sx_send_rdata(2'd0, 8'b0001_0001, 32'h002, 2'b00, 1'b1);//slv0
    //         @(posedge clk)
    //         while (!S_AXI_RREADY[2'd0]) @(posedge clk);
    //         Sx_clr_rdata(2'd0);
    //     end
    // join
    //}}--------------test the arbiter in sid_buffer.v ------------------
end

    //---------------SIMULATION TIME------------------
initial begin
    $display("\n*************************");
    $display("SIMULATION START !!!!!!");
    $display("*************************\n");

    rstn = 0;                          
    clk  = 0;                          
    #(PERIOD*1.5) rstn = 1;     
    #(PERIOD*300); //finish simulation after PERTODs.
    $display("\n*************************");
    $display("SIMULATION END !!!!!!");
    $display("*************************\n");
    $finish(0);        
end                       
always #(PERIOD/2) clk = ~clk ;   

//--------Tasks for raddr and rdata-----------
task Mx_send_raddr(
    input [1 : 0]           i_M_Mx     ,
    input [W_ID-1 : 0]      i_M_ARID   ,
    input [W_ADDR-1 : 0]    i_M_ARADDR ,
    input [W_LEN-1 : 0]     i_M_ARLEN  ,
    input [W_SIZE-1 : 0]    i_M_ARSIZE ,
    input [W_BURST-1 : 0]   i_M_ARBURST
    );
    begin
        if(M_AXI_ARREADY[i_M_Mx]) begin
            M_AXI_ARID   [i_M_Mx] <= i_M_ARID;
            M_AXI_ARADDR [i_M_Mx] <= i_M_ARADDR;
            M_AXI_ARLEN  [i_M_Mx] <= i_M_ARLEN;
            M_AXI_ARSIZE [i_M_Mx] <= i_M_ARSIZE;
            M_AXI_ARBURST[i_M_Mx] <= i_M_ARBURST;
            M_AXI_ARVALID[i_M_Mx] <= 1'b1;
        end
        else begin
            $display("\nM_AR_FIFO is full, M_AXI_ARREADY[%d] == 0, can't send araddr now!", i_M_Mx);
            $stop(2);
        end
    end
endtask
task Mx_clr_raddr(
    input [1 : 0]      i_M_Mx     
    );
    begin
        M_AXI_ARID   [i_M_Mx] <= 'd0;
        M_AXI_ARADDR [i_M_Mx] <= 'd0;
        M_AXI_ARLEN  [i_M_Mx] <= 'd0;
        M_AXI_ARSIZE [i_M_Mx] <= 'd0;
        M_AXI_ARBURST[i_M_Mx] <= 'd0;
        M_AXI_ARVALID[i_M_Mx] <= 'd0;
    end
endtask

task Sx_send_rdata(
    input  [1:0]            i_S_Sx,
    input  [W_SID-1 : 0]    i_S_RID   ,
    input  [W_DATA-1 : 0]   i_S_RDATA ,
    input  [W_RESP -1 : 0]  i_S_RRESP ,
    input                   i_S_RLAST 
);
    begin
        if(S_AXI_RREADY[i_S_Sx]) begin
            S_AXI_RID   [i_S_Sx] <= i_S_RID   ;
            S_AXI_RDATA [i_S_Sx] <= i_S_RDATA ;
            S_AXI_RVALID[i_S_Sx] <= 1'b1;
            S_AXI_RRESP [i_S_Sx] <= i_S_RRESP ;
            S_AXI_RLAST [i_S_Sx] <= i_S_RLAST ;
        end else begin
            $display("\nS_R_FIFO is full, S_AXI_RREADY[%d] == 0, can't send rdata now!", i_S_Sx);
            $stop(2);
        end
        
    end
endtask
task Sx_clr_rdata(
    input  [1:0]          i_S_Sx
);
    begin
        S_AXI_RID   [i_S_Sx] <= 'd0;
        S_AXI_RDATA [i_S_Sx] <= 'd0;
        S_AXI_RVALID[i_S_Sx] <= 'd0;
        S_AXI_RRESP [i_S_Sx] <= 'd0;
        S_AXI_RLAST [i_S_Sx] <= 'd0;
    end
endtask

//--------Tasks for waddr, wdata, wresp-----------
task Mx_send_waddr(
    input [1 : 0]          i_M_Mx     ,
    input [W_ID-1 : 0]     i_M_AWID   ,
    input [W_ADDR-1 : 0]   i_M_AWADDR ,
    input [W_LEN-1 : 0]    i_M_AWLEN  ,
    input [W_SIZE-1 : 0]   i_M_AWSIZE ,
    input [W_BURST-1 : 0]  i_M_AWBURST
);
    begin
        M_AXI_AWID   [i_M_Mx] <=  i_M_AWID; 
        M_AXI_AWADDR [i_M_Mx] <=  i_M_AWADDR; 
        M_AXI_AWLEN  [i_M_Mx] <=  i_M_AWLEN  ; 
        M_AXI_AWSIZE [i_M_Mx] <=  i_M_AWSIZE ; 
        M_AXI_AWBURST[i_M_Mx] <=  i_M_AWBURST; 
        M_AXI_AWVALID[i_M_Mx] <=  1'b1; 
    end
endtask
task Mx_clr_waddr(
    input [1 : 0]          i_M_Mx     
);
    begin
        M_AXI_AWID   [i_M_Mx] <= 'd0;
        M_AXI_AWADDR [i_M_Mx] <= 'd0;
        M_AXI_AWLEN  [i_M_Mx] <= 'd0;
        M_AXI_AWSIZE [i_M_Mx] <= 'd0;
        M_AXI_AWBURST[i_M_Mx] <= 'd0;
        M_AXI_AWVALID[i_M_Mx] <= 'd0;
    end
endtask

task Mx_send_wdata(
    input [1:0]          i_M_Mx   ,
    input [W_ID-1:0]     i_M_WID  , 
    input [W_DATA-1:0]   i_M_WDATA, 
    input [W_STRB-1:0]   i_M_WSTRB, 
    input                i_M_WLAST
);
    begin
        M_AXI_WID   [i_M_Mx] <= i_M_WID  ;
        M_AXI_WDATA [i_M_Mx] <= i_M_WDATA;
        M_AXI_WSTRB [i_M_Mx] <= i_M_WSTRB;
        M_AXI_WLAST [i_M_Mx] <= i_M_WLAST;
        M_AXI_WVALID[i_M_Mx] <= 1'b1;
    end
endtask
task Mx_clr_wdata(
    input  [1:0]           i_M_Mx
);
    begin
        M_AXI_WID   [i_M_Mx] <= 0;
        M_AXI_WDATA [i_M_Mx] <= 0;
        M_AXI_WSTRB [i_M_Mx] <= 0;
        M_AXI_WLAST [i_M_Mx] <= 0;
        M_AXI_WVALID[i_M_Mx] <= 0;
    end
endtask

task Sx_send_bresp(
    input [1 : 0]           i_S_Sx     ,
    input [W_SID-1 : 0]     i_S_AXI_BID, 
    input [1 : 0]           i_S_AXI_BRESP
);
    begin
        S_AXI_BID   [i_S_Sx] <= i_S_AXI_BID;
        S_AXI_BRESP [i_S_Sx] <= i_S_AXI_BRESP;
        S_AXI_BVALID[i_S_Sx] <= 1'b1;
    end
endtask
task Sx_clr_bresp(
    input [1:0]           i_S_Sx     
);
    begin
        S_AXI_BID   [i_S_Sx] <= 'h00;
        S_AXI_BRESP [i_S_Sx] <= 'b00;
        S_AXI_BVALID[i_S_Sx] <= 'b0;
    end
endtask

initial  begin
    $fsdbDumpfile("axi_interconnect.fsdb");
    $fsdbDumpvars(0, axi_interconnect_tb, "+mda");
    $fsdbDumpMDA();
end           

initial begin
    wait(rstn);
    for (i = 0; i < 3; i++) begin
        S_AXI_ARREADY[i] <= 1'b1;
        M_AXI_RREADY [i] <= 1'b1;
        S_AXI_AWREADY[i] <= 1'b1;
        S_AXI_WREADY [i] <= 1'b1;
        M_AXI_BREADY [i] <= 1'b1;
    end
end                   
initial begin
    for (i = 0; i < 3; i = i + 1) begin
        M_AXI_ARID[i]    = 0;
        M_AXI_ARADDR[i]  = 0;
        M_AXI_ARLEN[i]   = 0;
        M_AXI_ARSIZE[i]  = 0;
        M_AXI_ARBURST[i] = 0;
        M_AXI_ARVALID[i] = 0;
        S_AXI_ARREADY[i] = 0;

        S_AXI_RID   [i] = 0;
        S_AXI_RDATA [i] = 0;
        S_AXI_RVALID[i] = 0;
        M_AXI_RREADY[i] = 0;
        S_AXI_RRESP [i] = 0;
        S_AXI_RLAST [i] = 0;

        M_AXI_AWID   [i] = 0;
        M_AXI_AWADDR [i] = 0;
        M_AXI_AWLEN  [i] = 0;
        M_AXI_AWSIZE [i] = 0;
        M_AXI_AWBURST[i] = 0;
        M_AXI_AWVALID[i] = 0;
        S_AXI_AWREADY[i] = 0;

        M_AXI_WID   [i] = 0;
        M_AXI_WDATA [i] = 0;
        M_AXI_WSTRB [i] = 0;
        M_AXI_WLAST [i] = 0;
        M_AXI_WVALID[i] = 0;
        S_AXI_WREADY[i] = 0;

        S_AXI_BID   [i] = 0;
        S_AXI_BRESP [i] = 0;
        S_AXI_BVALID[i] = 0;
        M_AXI_BREADY[i] = 0;
    end
end

axi_interconnect #()
u_axi_interconnect(
.AXI_RSTn                           (rstn                  ),
.AXI_CLK                            (clk                   ),
.M_AXI_AWID                         (M_AXI_AWID                ),
.M_AXI_AWADDR                       (M_AXI_AWADDR              ),
.M_AXI_AWLEN                        (M_AXI_AWLEN               ),
.M_AXI_AWSIZE                       (M_AXI_AWSIZE              ),
.M_AXI_AWBURST                      (M_AXI_AWBURST             ),
.M_AXI_AWVALID                      (M_AXI_AWVALID             ),
.M_AXI_AWREADY                      (M_AXI_AWREADY             ),

.M_AXI_WID                          (M_AXI_WID                 ),
.M_AXI_WDATA                        (M_AXI_WDATA               ),
.M_AXI_WSTRB                        (M_AXI_WSTRB               ),
.M_AXI_WLAST                        (M_AXI_WLAST               ),
.M_AXI_WVALID                       (M_AXI_WVALID              ),
.M_AXI_WREADY                       (M_AXI_WREADY              ),

.M_AXI_BID                          (M_AXI_BID                 ),
.M_AXI_BRESP                        (M_AXI_BRESP               ),
.M_AXI_BVALID                       (M_AXI_BVALID              ),
.M_AXI_BREADY                       (M_AXI_BREADY              ),

.M_AXI_ARID                         (M_AXI_ARID                ),
.M_AXI_ARADDR                       (M_AXI_ARADDR              ),
.M_AXI_ARLEN                        (M_AXI_ARLEN               ),
.M_AXI_ARSIZE                       (M_AXI_ARSIZE              ),
.M_AXI_ARBURST                      (M_AXI_ARBURST             ),
.M_AXI_ARVALID                      (M_AXI_ARVALID             ),
.M_AXI_ARREADY                      (M_AXI_ARREADY             ),

.M_AXI_RID                          (M_AXI_RID                 ),
.M_AXI_RDATA                        (M_AXI_RDATA               ),
.M_AXI_RRESP                        (M_AXI_RRESP               ),
.M_AXI_RLAST                        (M_AXI_RLAST               ),
.M_AXI_RVALID                       (M_AXI_RVALID              ),
.M_AXI_RREADY                       (M_AXI_RREADY              ),

.S_AXI_AWID                         (S_AXI_AWID                ),
.S_AXI_AWADDR                       (S_AXI_AWADDR              ),
.S_AXI_AWLEN                        (S_AXI_AWLEN               ),
.S_AXI_AWSIZE                       (S_AXI_AWSIZE              ),
.S_AXI_AWBURST                      (S_AXI_AWBURST             ),
.S_AXI_AWVALID                      (S_AXI_AWVALID             ),
.S_AXI_AWREADY                      (S_AXI_AWREADY             ),

.S_AXI_WID                          (S_AXI_WID                 ),
.S_AXI_WDATA                        (S_AXI_WDATA               ),
.S_AXI_WSTRB                        (S_AXI_WSTRB               ),
.S_AXI_WLAST                        (S_AXI_WLAST               ),
.S_AXI_WVALID                       (S_AXI_WVALID              ),
.S_AXI_WREADY                       (S_AXI_WREADY              ),

.S_AXI_BID                          (S_AXI_BID                 ),
.S_AXI_BRESP                        (S_AXI_BRESP               ),
.S_AXI_BVALID                       (S_AXI_BVALID              ),
.S_AXI_BREADY                       (S_AXI_BREADY              ),

.S_AXI_ARID                         (S_AXI_ARID                ),
.S_AXI_ARADDR                       (S_AXI_ARADDR              ),
.S_AXI_ARLEN                        (S_AXI_ARLEN               ),
.S_AXI_ARSIZE                       (S_AXI_ARSIZE              ),
.S_AXI_ARBURST                      (S_AXI_ARBURST             ),
.S_AXI_ARVALID                      (S_AXI_ARVALID             ),
.S_AXI_ARREADY                      (S_AXI_ARREADY             ),

.S_AXI_RID                          (S_AXI_RID                 ),
.S_AXI_RDATA                        (S_AXI_RDATA               ),
.S_AXI_RRESP                        (S_AXI_RRESP               ),
.S_AXI_RLAST                        (S_AXI_RLAST               ),
.S_AXI_RVALID                       (S_AXI_RVALID              ),
.S_AXI_RREADY                       (S_AXI_RREADY              )

`ifdef APB_CFG
    , .pwrite                        (pwrite )
    , .psel                          (psel   )
    , .penable                       (penable) 
    , .paddr                         (paddr  )
    , .pwdata                        (pwdata )
    , .prdata                        (prdata )
`endif
);
endmodule
