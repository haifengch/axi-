`timescale 1ns / 1ps
module    axi2ahb_bridge_tb();
    reg                    clk         ;
    reg                    rst_n       ;

    reg   [7  :0]          axi_arid    ;
    reg   [31 :0]          axi_araddr  ;
    reg   [7  :0]          axi_arlen   ;
    reg   [2  :0]          axi_arsize  ;
    reg   [1  :0]          axi_arburst ;
    reg                    axi_arvalid ;
    wire                   axi_arready ;

    wire  [7  :0]          axi_rid     ;
    wire  [31 :0]          axi_rdata   ;
    wire  [1  :0]          axi_rresp   ;
    wire                   axi_rlast   ;
    wire                   axi_rvalid  ;
    reg                    axi_rready  ;

    reg   [7  :0]          axi_awid    ;
    reg   [31 :0]          axi_awaddr  ;
    reg   [7  :0]          axi_awlen   ;
    reg   [2  :0]          axi_awsize  ;
    reg   [1  :0]          axi_awburst ;
    reg                    axi_awvalid ;
    wire                   axi_awready ;

    reg   [7  :0]          axi_wid     ;
    reg   [31 :0]          axi_wdata   ;
    reg                    axi_wlast   ;
    reg   [3 : 0]          axi_wstrb   ;
    reg                    axi_wvalid  ;
    wire                   axi_wready  ;

    wire  [7  :0]          axi_bid     ;
    wire  [1  :0]          axi_bresp   ;
    wire                   axi_bvalid  ;
    reg                    axi_bready  ;

    reg                    ahb_hgrant  ;
    wire                   ahb_hbusreq ;
    wire  [31 :0]          ahb_haddr   ;
    wire  [1  :0]          ahb_htrans  ;
    wire                   ahb_hwrite  ;
    wire  [2  :0]          ahb_hsize   ;
    wire  [2  :0]          ahb_hburst  ;
    wire  [31:0]           ahb_hwdata  ;
    reg   [31:0]           ahb_hrdata  ;
    reg                    ahb_hready  ;
    reg   [1  :0]          ahb_hresp   ;

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

    parameter PERIOD = 20;
    integer i;

    initial begin
        @(posedge clk)
        axi_rready = 1;
        axi_bready = 1;
        ahb_hready = 1;
        ahb_hgrant = 1;
        @(posedge clk);
        @(posedge clk);

        // //---------read incr/wrap 256-------------
        // axi_arid    <= 1;
        // axi_araddr  <= 32'h34;
        // axi_arlen   <= 8'b11111111; //256
        // axi_arsize  <= 3'b101;
        // axi_arburst <= 2'b01;//'b01-incr, 'b10-wrap
        // axi_arvalid <= 1; @(posedge clk);
        // axi_arvalid <= 0; @(posedge clk);

        // for (i = 1; i <= 256; i++) begin
        //     ahb_hrdata  <= i;
        //     ahb_hresp   <= 0;
        //     @(posedge clk);
        // end
        // wait(axi_rlast); @(posedge clk); ahb_hready <= 0;


    //---------write incr/wrap 256----------------
    axi_awid    <= 8'b0111_1101;
    axi_awaddr   <= 32'h34;
    axi_awlen   <= 8'b1111_1111;
    axi_awsize  <= 3'b101;
    axi_awburst <= 2'b01;//'b01-incr, 'b10-wrap
    axi_awvalid <= 1; @(posedge clk);
    axi_awid <= 0; axi_awaddr <= 0; axi_awlen <= 0; axi_awsize <= 0; axi_awburst <= 0; axi_awvalid <= 0; @(posedge clk);

    for (i = 1; i <= 256; i++) begin
        axi_wid    <= 8'b0111_1101;
        axi_wdata  <= i;
        axi_wlast  <= (i==256) ? 1 : 0;
        axi_wstrb  <= 4'hf;
        axi_wvalid <= 1;
        @(posedge clk);
    end
    axi_wid <= 0; axi_wdata <= 0; axi_wlast <= 0; axi_wstrb <= 0; axi_wvalid <= 0;
    while(axi_bvalid != 1) @(posedge clk);

    @(posedge clk);@(posedge clk);

    // //---------write interleaving 3----------------
    // //write addr-phase, 2-transaction
    // axi_awid    <= 8'b0111_1101;
    // axi_awaddr  <= 32'h3101;
    // axi_awlen   <= 8'h1;
    // axi_awsize  <= 3'b101;
    // axi_awburst <= 2'b01;//'b01-incr, 'b10-wrap
    // axi_awvalid <= 1; @(posedge clk);
    // axi_awid <= 0; axi_awaddr <= 0; axi_awlen <= 0; axi_awsize <= 0; axi_awburst <= 0; axi_awvalid <= 0; @(posedge clk);

    // axi_awid    <= 8'b1011_1110;
    // axi_awaddr  <= 32'h3201;
    // axi_awlen   <= 8'h1;
    // axi_awsize  <= 3'b101;
    // axi_awburst <= 2'b01;//'b01-incr, 'b10-wrap
    // axi_awvalid <= 1; @(posedge clk);
    // axi_awid <= 0; axi_awaddr <= 0; axi_awlen <= 0; axi_awsize <= 0; axi_awburst <= 0; axi_awvalid <= 0; @(posedge clk);

    // //write data-phase, 4 interleaving data
    // axi_wid    <= 8'b1011_1110;
    // axi_wdata  <= 32'h201; //data 1
    // axi_wlast  <= 0;
    // axi_wstrb  <= 4'hf;
    // axi_wvalid <= 1; @(posedge clk);
    // axi_wid <= 0; axi_wdata <= 0; axi_wlast <= 0; axi_wstrb <= 0; axi_wvalid <= 0;

    // axi_wid    <= 8'b0111_1101;
    // axi_wdata  <= 32'h101; //data 2
    // axi_wlast  <= 0;
    // axi_wstrb  <= 4'hf;
    // axi_wvalid <= 1; @(posedge clk);
    // axi_wid <= 0; axi_wdata <= 0; axi_wlast <= 0; axi_wstrb <= 0; axi_wvalid <= 0;
    
    // axi_wid    <= 8'b1011_1110;
    // axi_wdata  <= 32'h202; //data 3
    // axi_wlast  <= 1;
    // axi_wstrb  <= 4'hf;
    // axi_wvalid <= 1; @(posedge clk);
    // axi_wid <= 0; axi_wdata <= 0; axi_wlast <= 0; axi_wstrb <= 0; axi_wvalid <= 0;
    // while(axi_bvalid != 1) @(posedge clk);

    // axi_wid    <= 8'b0111_1101;
    // axi_wdata  <= 32'h102; //data 4
    // axi_wlast  <= 1;
    // axi_wstrb  <= 4'hf;
    // axi_wvalid <= 1; @(posedge clk);
    // axi_wid <= 0; axi_wdata <= 0; axi_wlast <= 0; axi_wstrb <= 0; axi_wvalid <= 0;
    // while(axi_bvalid != 1) @(posedge clk);
    

end

    initial begin
        $display("\n*************************");
        $display("SIMULATION START !!!!!!");
        $display("*************************\n");
    
        rst_n = 0;                        
        clk   = 0;     
        #(PERIOD*1.5) 
        rst_n = 1;     
        #(PERIOD*560); //finish simulation after PERTODs.
        $display("\n*************************");
        $display("SIMULATION END !!!!!!");
        $display("*************************\n");
        $finish(0);        
    end

    always #(PERIOD/2) clk = ~clk;

    initial  begin
        $fsdbDumpfile("axi2ahb_bridge.fsdb");
        $fsdbDumpvars(0, axi2ahb_bridge_tb, "+mda");
        $fsdbDumpMDA();
    end

    initial begin
        axi_arid    = 0;
        axi_araddr  = 0;
        axi_arlen   = 0;
        axi_arsize  = 0;
        axi_arburst = 0;
        axi_arvalid = 0;
        axi_rready  = 0;
        axi_awid    = 0;
        axi_awaddr  = 0;
        axi_awlen   = 0;
        axi_awsize  = 0;
        axi_awburst = 0;
        axi_awvalid = 0;
        axi_wid     = 0;
        axi_wdata   = 0;
        axi_wlast   = 0;
        axi_wstrb   = 0;
        axi_wvalid  = 0;
        axi_bready  = 0;
        ahb_hgrant  = 0;
        ahb_hrdata  = 0;
        ahb_hready  = 0;
        ahb_hresp   = 0;
    end
                                                                         
axi2ahb_bridge u_axi2ahb(
    .clk                            (clk                   ),
    .rst_n                          (rst_n                 ),
    .axi_arid                       (axi_arid              ),
    .axi_araddr                     (axi_araddr            ),
    .axi_arlen                      (axi_arlen             ),
    .axi_arsize                     (axi_arsize            ),
    .axi_arburst                    (axi_arburst           ),
    .axi_arvalid                    (axi_arvalid           ),
    .axi_arready                    (axi_arready           ),
    .axi_rid                        (axi_rid               ),
    .axi_rdata                      (axi_rdata             ),
    .axi_rresp                      (axi_rresp             ),
    .axi_rlast                      (axi_rlast             ),
    .axi_rvalid                     (axi_rvalid            ),
    .axi_rready                     (axi_rready            ),
    .axi_awid                       (axi_awid              ),
    .axi_awaddr                     (axi_awaddr            ),
    .axi_awlen                      (axi_awlen             ),
    .axi_awsize                     (axi_awsize            ),
    .axi_awburst                    (axi_awburst           ),
    .axi_awvalid                    (axi_awvalid           ),
    .axi_awready                    (axi_awready           ),
    .axi_wid                        (axi_wid               ),
    .axi_wdata                      (axi_wdata             ),
    .axi_wlast                      (axi_wlast             ),
    .axi_wstrb                      (axi_wstrb             ),
    .axi_wvalid                     (axi_wvalid            ),
    .axi_wready                     (axi_wready            ),
    .axi_bid                        (axi_bid               ),
    .axi_bresp                      (axi_bresp             ),
    .axi_bvalid                     (axi_bvalid            ),
    .axi_bready                     (axi_bready            ),
    .ahb_hgrant                     (ahb_hgrant            ),
    .ahb_hbusreq                    (ahb_hbusreq           ),
    .ahb_haddr                      (ahb_haddr             ),
    .ahb_htrans                     (ahb_htrans            ),
    .ahb_hwrite                     (ahb_hwrite            ),
    .ahb_hsize                      (ahb_hsize             ),
    .ahb_hburst                     (ahb_hburst            ),
    .ahb_hwdata                     (ahb_hwdata            ),
    .ahb_hrdata                     (ahb_hrdata            ),
    .ahb_hready                     (ahb_hready            ),
    .ahb_hresp                      (ahb_hresp             )
);

endmodule                                                  
                                                 