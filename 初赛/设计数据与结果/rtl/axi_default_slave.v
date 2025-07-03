module axi_default_slave
     #(parameter W_CID  = 4        // Channel ID width
               , W_ID   = 4        // ID width
               , W_ADDR = 32       // address width
               , W_DATA = 32       // data width
               , W_STRB = W_DATA/8 // data strobe width
               , W_SID  = W_CID+W_ID
      )
(
       input  wire                  AXI_RSTn
     , input  wire                  AXI_CLK
     , input  wire [W_SID-1:0]      AWID
     , input  wire [W_ADDR-1:0]     AWADDR
     , input  wire [ 7:0]           AWLEN
     , input  wire [ 2:0]           AWSIZE
     , input  wire [ 1:0]           AWBURST
     , input  wire                  AWVALID
     , output reg                   AWREADY

     , input  wire [W_SID-1:0]      WID
     , input  wire [W_DATA-1:0]     WDATA
     , input  wire [W_STRB-1:0]     WSTRB
     , input  wire                  WLAST
     , input  wire                  WVALID
     , output reg                   WREADY

     , output reg  [W_SID-1:0]      BID
     , output wire [ 1:0]           BRESP
     , output reg                   BVALID
     , input  wire                  BREADY

     , input  wire [W_SID-1:0]      ARID
     , input  wire [W_ADDR-1:0]     ARADDR
     , input  wire [ 7:0]           ARLEN
     , input  wire [ 2:0]           ARSIZE
     , input  wire [ 1:0]           ARBURST
     , input  wire                  ARVALID
     , output reg                   ARREADY

     , output reg  [W_SID-1:0]      RID
     , output wire [W_DATA-1:0]     RDATA
     , output wire [ 1:0]           RRESP
     , output reg                   RLAST
     , output reg                   RVALID
     , input  wire                  RREADY
);
     //-----------------------------------------------------------
     // write case
     assign BRESP = 2'b11; // DECERR: decode error
     reg [W_SID-1:0] awid_reg;
     reg [8:0] countW, awlen_reg;

     localparam STW_IDLE   = 'h0,
                STW_RUN    = 'h1,
                STW_WAIT   = 'h2,
                STW_RSP    = 'h3;
     reg [1:0] stateW=STW_IDLE;
     always @ (posedge AXI_CLK) begin
         if (!AXI_RSTn) begin
             AWREADY   <= 1'b0;
             WREADY    <= 1'b0;
             BID       <=  'h0;
             BVALID    <= 1'b0;
             countW    <=  'h0;
             awlen_reg <=  'h0;
             awid_reg  <=  'h0;
             stateW    <= STW_IDLE;
         end else begin
             case (stateW)
             STW_IDLE: begin
                 if (AWVALID==1'b1) begin
                     AWREADY <= 1'b1;
                     stateW  <= STW_RUN;
                 end
                 end // STW_IDLE
             STW_RUN: begin
                 if ((AWVALID==1'b1)&&(AWREADY==1'b1)) begin
                      AWREADY   <= 1'b0;
                      WREADY    <= 1'b1;
                      awlen_reg <= {1'b0,AWLEN};
                      awid_reg  <= AWID;
                      stateW    <= STW_WAIT;
                 end else begin
                 end
                 end // STW_IDLE
             STW_WAIT: begin
                 if (WVALID==1'b1) begin
                     if ((countW>=awlen_reg)||(WLAST==1'b1)) begin
                         BID    <= awid_reg;
                         BVALID <= 1'b1;
                         WREADY <= 1'b0;
                         countW <= 'h0;
                         stateW <= STW_RSP;
                         // synopsys translate_off
                         if (WLAST==1'b0) begin
                             $display("%04d %m Error expecting WLAST", $time);
                         end
                         // synopsys translate_on
                     end else begin
                         countW <= countW + 1;
                     end
                 end
                 // synopsys translate_off
                 if ((WVALID==1'b1)&&(WID!=awid_reg)) begin
                     $display("%04d %m Error AWID(0x%x):WID(0x%x) mismatch", $time, awid_reg, WID);
                 end
                 // synopsys translate_on
                 end // STW_WAIT
             STW_RSP: begin
                 if (BREADY==1'b1) begin
                     BVALID  <= 1'b0;
                     if (AWVALID==1'b1) begin
                         AWREADY <= 1'b1;
                         stateW  <= STW_RUN;
                     end else begin
                         stateW  <= STW_IDLE;
                     end
                 end
                 end // STW_RSP
             endcase
         end
     end
     
     //-----------------------------------------------------------
     // read case
     assign RRESP = 2'b11; // DECERR; decode error
     assign RDATA = ~'h0;
     reg [W_SID-1:0] arid_reg;
     reg [8:0] countR, arlen_reg;

     localparam STR_IDLE   = 'h0,
                STR_RUN    = 'h1,
                STR_WAIT   = 'h2,
                STR_END    = 'h3;
     reg [1:0] stateR=STR_IDLE;
     always @ (posedge AXI_CLK) begin
         if (!AXI_RSTn) begin
             ARREADY   <= 1'b0;
             RID       <=  'h0;
             RLAST     <= 1'b0;
             RVALID    <= 1'b0;
             arid_reg  <=  'h0;
             arlen_reg <=  'h0;
             countR    <=  'h0;
             stateR    <= STR_IDLE;
         end else begin
             case (stateR)
             STR_IDLE: begin
                 if (ARVALID==1'b1) begin
                      ARREADY   <= 1'b1;
                      stateR    <= STR_RUN;
                 end
                 end // STR_IDLE
             STR_RUN: begin
                 if ((ARVALID==1'b1)&&(ARREADY==1'b1)) begin
                      ARREADY   <= 1'b0;
                      arlen_reg <= ARLEN+1;
                      arid_reg  <= ARID;
                      RID       <= ARID;
                      RVALID    <= 1'b1;
                      RLAST     <= (ARLEN=='h0) ? 1'b1 : 1'b0;
                      countR    <=  'h2;
                      stateR    <= STR_WAIT;
                 end
                 end // STR_IDLE
             STR_WAIT: begin
                 if (RREADY==1'b1) begin
                     if (countR>=(arlen_reg+1)) begin
                         RVALID  <= 1'b0;
                         RLAST   <= 1'b0;
                         countR  <= 'h0;
                         stateR  <= STR_END;
                     end else begin
                         if (countR==arlen_reg) RLAST  <= 1'b1;
                         countR <= countR + 1;
                     end
                 end
                 end // STR_WAIT
             STR_END: begin
                 if (ARVALID==1'b1) begin
                      ARREADY   <= 1'b1;
                      stateR    <= STR_RUN;
                 end else begin
                      stateR    <= STR_IDLE;
                 end
                 end // STR_END
             endcase
         end
     end
endmodule