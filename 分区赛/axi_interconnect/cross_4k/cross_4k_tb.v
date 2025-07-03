`timescale 1ns / 1ps
module cross_4k_tb();
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

    reg                   clk        ;
    reg                   rst_n      ;

    // input
    reg    [W_ID-1 :0]    m_axi_arid    ;
    reg    [W_ADDR-1:0]   m_axi_araddr  ;
    reg    [W_LEN-1 :0]   m_axi_arlen   ;
    reg    [2 :0]         m_axi_arsize  ;
    reg    [1 :0]         m_axi_arburst ;
    reg                   m_axi_arvalid ;
    wire                  m_axi_arready ;

    reg    [W_ID-1 :0]    m_axi_awid   ;
    reg    [W_ADDR-1:0]   m_axi_awaddr ;
    reg    [W_LEN-1 :0]   m_axi_awlen  ;
    reg    [2 :0]         m_axi_awsize ;
    reg    [1 :0]         m_axi_awburst;
    reg                   m_axi_awvalid;
    wire                  m_axi_awready;

    // reg  [W_ID-1:0]       m_axi_wid     ; 
    // reg  [W_DATA-1:0]     m_axi_wdata   ;
    // reg  [W_STRB-1:0]     m_axi_wstrb   ;
    // reg                   m_axi_wlast   ;
    // reg                   m_axi_wvalid  ; 
    // wire                  m_axi_wready  ; 

    // output
    wire    [W_ID-1:0]    s_axi_arid    ;
    wire    [W_ADDR-1:0]  s_axi_araddr  ;
    wire    [W_LEN-1:0]   s_axi_arlen   ;
    wire    [2:0]         s_axi_arsize  ;
    wire    [1:0]         s_axi_arburst ;
    wire                  s_axi_arvalid ;
    reg                   s_axi_arready ;

    wire    [W_ID-1:0]    s_axi_awid    ;
    wire    [W_ADDR-1:0]  s_axi_awaddr  ;
    wire    [W_LEN-1:0]   s_axi_awlen   ;
    wire    [2:0]         s_axi_awsize  ;
    wire    [1:0]         s_axi_awburst ;
    wire                  s_axi_awvalid ;
    reg                   s_axi_awready ;

    // wire   [W_SID-1:0]    s_axi_wid     ;
    // wire   [W_DATA-1:0]   s_axi_wdata   ;
    // wire   [W_STRB-1:0]   s_axi_wstrb   ;
    // wire                  s_axi_wlast   ;
    // wire                  s_axi_wvalid  ;
    // reg                   s_axi_wready  ;

    integer i,j;

initial begin
    wait(rst_n);
    @(posedge clk);
    @(posedge clk);

    // //{{------------outstanding transaction test----------------
    // read transaction outstanding test
    Mx_send_raddr(4'b0001, 32'h0000_1000, 8'hff, 3'b101, 2'b01);
    @(posedge clk);
    while (!m_axi_arready) @(posedge clk);

    for (j = 0; j < 2; j++) begin // transaction_j, mst0 to slv0, len=0
        Mx_send_raddr(4'b0001, (32'h0000_1ff0+j), 8'hff, 3'b101, 2'b01);
        @(posedge clk);
        while (!m_axi_arready) @(posedge clk);
    end
    Mx_clr_raddr();

    // write transaction outstanding test
    for (j = 0; j < 4; j++) begin // transaction_j, mst1 to slv1
        Mx_send_waddr(4'b1001, (32'h0000_2ff0+j), 8'hff, 3'b101, 2'b01);
        @(posedge clk);
        while (!m_axi_awready) @(posedge clk);
        Mx_clr_waddr();
    end
    // for (j = 0; j < 4; j++) begin
    //     Mx_send_wdata(4'b1001, (32'h00d0+j), 4'hf, 1'b1);// wdata
    //     @(posedge clk)
    //     while (!m_axi_wready) @(posedge clk);
    //     Mx_clr_wdata();
    //     while (!(s_axi_wlast & s_axi_wready & s_axi_wvalid)) @(posedge clk);
    // end
    // //}}------------outstanding transaction test----------------
end

//---------------SIMULATION TIME------------------
initial begin
    $display("\n*************************");
    $display("SIMULATION START !!!!!!");
    $display("*************************\n");

    rst_n = 0;                          
    clk  = 0;                          
    #(PERIOD*1.5) rst_n = 1;     
    #(PERIOD*30); //finish simulation after PERTODs.
    $display("\n*************************");
    $display("SIMULATION END !!!!!!");
    $display("*************************\n");
    $finish(0);        
end                       
always #(PERIOD/2) clk = ~clk ; 

task Mx_send_raddr(
    input [W_ID-1 : 0]      i_M_ARID   ,
    input [W_ADDR-1 : 0]    i_M_ARADDR ,
    input [W_LEN-1 : 0]     i_M_ARLEN  ,
    input [W_SIZE-1 : 0]    i_M_ARSIZE ,
    input [W_BURST-1 : 0]   i_M_ARBURST
    );
    begin
        if(m_axi_arready) begin
            m_axi_arid    <= i_M_ARID;
            m_axi_araddr  <= i_M_ARADDR;
            m_axi_arlen   <= i_M_ARLEN;
            m_axi_arsize  <= i_M_ARSIZE;
            m_axi_arburst <= i_M_ARBURST;
            m_axi_arvalid <= 1'b1;
        end
    end
endtask
task Mx_clr_raddr();
    begin
        m_axi_arid    <= 'd0;
        m_axi_araddr  <= 'd0;
        m_axi_arlen   <= 'd0;
        m_axi_arsize  <= 'd0;
        m_axi_arburst <= 'd0;
        m_axi_arvalid <= 'd0;
    end
endtask

task Mx_send_waddr(
    input [W_ID-1 : 0]     i_M_AWID   ,
    input [W_ADDR-1 : 0]   i_M_AWADDR ,
    input [W_LEN-1 : 0]    i_M_AWLEN  ,
    input [W_SIZE-1 : 0]   i_M_AWSIZE ,
    input [W_BURST-1 : 0]  i_M_AWBURST
);
    begin
        m_axi_awid    <=  i_M_AWID; 
        m_axi_awaddr  <=  i_M_AWADDR; 
        m_axi_awlen   <=  i_M_AWLEN  ; 
        m_axi_awsize  <=  i_M_AWSIZE ; 
        m_axi_awburst <=  i_M_AWBURST; 
        m_axi_awvalid <=  1'b1; 
    end
endtask
task Mx_clr_waddr();
    begin
        m_axi_awid    <= 'd0;
        m_axi_awaddr  <= 'd0;
        m_axi_awlen   <= 'd0;
        m_axi_awsize  <= 'd0;
        m_axi_awburst <= 'd0;
        m_axi_awvalid <= 'd0;
    end
endtask

// task Mx_send_wdata(
//     input [W_ID-1:0]     i_M_WID  , 
//     input [W_DATA-1:0]   i_M_WDATA, 
//     input [W_STRB-1:0]   i_M_WSTRB, 
//     input                i_M_WLAST
// );
//     begin
//         m_axi_wid    <= i_M_WID  ;
//         m_axi_wdata  <= i_M_WDATA;
//         m_axi_wstrb  <= i_M_WSTRB;
//         m_axi_wlast  <= i_M_WLAST;
//         m_axi_wvalid <= 1'b1;
//     end
// endtask
// task Mx_clr_wdata();
//     begin
//         m_axi_wid    <= 0;
//         m_axi_wdata  <= 0;
//         m_axi_wstrb  <= 0;
//         m_axi_wlast  <= 0;
//         m_axi_wvalid <= 0;
//     end
// endtask


initial  begin
    $fsdbDumpfile("cross_4k_if.fsdb");
    $fsdbDumpvars(0, cross_4k_tb, "+mda");
    $fsdbDumpMDA();
end           

initial begin
    wait(rst_n);
    s_axi_arready <= 1'b1;
    s_axi_awready <= 1'b1;
    // s_axi_wready  <= 1'b1;
end                   
initial begin
    m_axi_arid    = 0;
    m_axi_araddr  = 0;
    m_axi_arlen   = 0;
    m_axi_arsize  = 0;
    m_axi_arburst = 0;
    m_axi_arvalid = 0;
    s_axi_arready = 0;
    
    m_axi_awid    = 0;
    m_axi_awaddr  = 0;
    m_axi_awlen   = 0;
    m_axi_awsize  = 0;
    m_axi_awburst = 0;
    m_axi_awvalid = 0;
    s_axi_awready = 0;
    
    // m_axi_wid    = 0;
    // m_axi_wdata  = 0;
    // m_axi_wstrb  = 0;
    // m_axi_wlast  = 0;
    // m_axi_wvalid = 0;
    // s_axi_wready = 0;
     
end

cross_4k_if#()
  u_cross_4k(
     .clk              (clk             ),
     .rst_n            (rst_n           ),
     // input
     .m_axi_arid       (m_axi_arid      ),
     .m_axi_araddr     (m_axi_araddr    ),
     .m_axi_arlen      (m_axi_arlen     ),
     .m_axi_arsize     (m_axi_arsize    ),
     .m_axi_arburst    (m_axi_arburst   ),
     .m_axi_arvalid    (m_axi_arvalid   ),
     .m_axi_arready    (m_axi_arready   ),
     .m_axi_awid       (m_axi_awid     ),
     .m_axi_awaddr     (m_axi_awaddr   ),
     .m_axi_awlen      (m_axi_awlen    ),
     .m_axi_awsize     (m_axi_awsize   ),
     .m_axi_awburst    (m_axi_awburst  ),
     .m_axi_awvalid    (m_axi_awvalid  ),
     .m_axi_awready    (m_axi_awready  ),
    //  .m_axi_wid        (m_axi_wid       ),
    //  .m_axi_wdata      (m_axi_wdata     ),
    //  .m_axi_wstrb      (m_axi_wstrb     ),
    //  .m_axi_wlast      (m_axi_wlast     ),
    //  .m_axi_wvalid     (m_axi_wvalid    ),
    //  .m_axi_wready     (m_axi_wready    ),
     // output
     .s_axi_arid       (s_axi_arid      ),
     .s_axi_araddr     (s_axi_araddr    ),
     .s_axi_arlen      (s_axi_arlen     ),
     .s_axi_arsize     (s_axi_arsize    ),
     .s_axi_arburst    (s_axi_arburst   ),
     .s_axi_arvalid    (s_axi_arvalid   ),
     .s_axi_arready    (s_axi_arready   ),
     .s_axi_awid       (s_axi_awid      ),
     .s_axi_awaddr     (s_axi_awaddr    ),
     .s_axi_awlen      (s_axi_awlen     ),
     .s_axi_awsize     (s_axi_awsize    ),
     .s_axi_awburst    (s_axi_awburst   ),
     .s_axi_awvalid    (s_axi_awvalid   ),
     .s_axi_awready    (s_axi_awready   )
    //  .s_axi_wid        (s_axi_wid       ),
    //  .s_axi_wdata      (s_axi_wdata     ),
    //  .s_axi_wstrb      (s_axi_wstrb     ),
    //  .s_axi_wlast      (s_axi_wlast     ),
    //  .s_axi_wvalid     (s_axi_wvalid    ),
    //  .s_axi_wready     (s_axi_wready    )
 );
endmodule