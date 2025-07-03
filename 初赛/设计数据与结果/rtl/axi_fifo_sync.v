// Synchronous FIFO
//----------------------------------------------------------------
// MACROS and PARAMETERS
//     FDW: bit-width of data
//     FAW: num of entries in power of 2
//----------------------------------------------------------------
// Features
//    * ready-valid handshake protocol
//    * First-Word Fall-Through, but rd_vld indicates its validity
//----------------------------------------------------------------
//    * data moves when both ready(rdy) and valid(vld) is high.
//    * ready(rdy) means the receiver is ready to accept data.
//    * valid(vld) means the data is valid on 'data'.
//----------------------------------------------------------------

module axi_fifo_sync
     #(parameter FDW =32, // fifof data width
                 FAW =5   // num of entries in 2 to the power FAW
                 )
(
       input   wire           rstn
     , input   wire           clr 
     , input   wire           clk

     , output  wire           wr_rdy
     , input   wire           wr_vld
     , input   wire [FDW-1:0] wr_din
     , input   wire           rd_rdy
     , output  wire           rd_vld
     , output  wire [FDW-1:0] rd_dout
);
    
   localparam FDT = 1 << FAW;

   wire           full     ;
   wire           empty    ;
   reg  [FAW:0]   item_cnt ;
   reg  [FAW:0]   fifo_head; // where data to be read
   reg  [FAW:0]   fifo_tail; // where data to be written
   reg  [FAW:0]   next_tail;
   reg  [FAW:0]   next_head;

   //---------------------------------------------------
   // synopsys translate_off
   initial fifo_head = 'h0;
   initial fifo_tail = 'h0;
   initial next_head = 'h0;
   initial next_tail = 'h0;
   // synopsys translate_on
   //---------------------------------------------------

   // push data item into the entry pointed by fifo_tail
   always @(posedge clk) begin
      if (!rstn) begin
          fifo_tail <= 0;
          next_tail <= 1;
      end else if (clr) begin
          fifo_tail <= 0;
          next_tail <= 1;
      end else begin
          if (!full && wr_vld) begin
              fifo_tail <= next_tail;
              next_tail <= next_tail + 1;
          end 
      end
   end

   // pop data item from the entry pointed by fifo_head
   always @(posedge clk) begin
      if (!rstn) begin
          fifo_head <= 0;
          next_head <= 1;
      end else if (clr) begin
          fifo_head <= 0;
          next_head <= 1;
      end else begin
          if (!empty && rd_rdy) begin
              fifo_head <= next_head;
              next_head <= next_head + 1;
          end
      end
   end

   always @(posedge clk) begin
      if (!rstn) begin
         item_cnt <= 0;
      end else if (clr) begin
         item_cnt <= 0;
      end else begin
         if (wr_vld && !full && (!rd_rdy || (rd_rdy && empty))) begin
             item_cnt <= item_cnt + 1;
         end else
         if (rd_rdy && !empty && (!wr_vld || (wr_vld && full))) begin
             item_cnt <= item_cnt - 1;
         end
      end
   end
   
   assign rd_vld = ~empty;
   assign wr_rdy = ~full;
   assign empty  = (fifo_head == fifo_tail);
   assign full   = (item_cnt >= FDT);

   reg [FDW-1:0] Mem [0:FDT-1];

   // synopsys translate_off
   integer i, j;
   initial begin
        for (i = 0; i < FDT; i++) begin
            for (j = 0; j < FDW; j++) begin
                Mem[i][j] = 'd0;
            end
            
        end
   end
   // synopsys translate_on

   assign rd_dout  = Mem[fifo_head[FAW-1:0]];

   always @(posedge clk) begin
       if (!full && wr_vld) begin
           Mem[fifo_tail[FAW-1:0]] <= wr_din;
       end
   end

endmodule