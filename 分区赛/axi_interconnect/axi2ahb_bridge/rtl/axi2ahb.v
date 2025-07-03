module axi2ahb(
    input  wire          clk        ,   
    input  wire          rst_n      ,     

    input  wire [7 :0]   axi_arid   ,      
    input  wire [31:0]   axi_araddr ,    
    input  wire [7 :0]   axi_arlen  ,     
    input  wire [2 :0]   axi_arsize ,    
    input  wire [1 :0]   axi_arburst,   
    input  wire          axi_arvalid,  
    output wire          axi_arready,    
    output wire [7:0]    axi_rid    ,       
    output wire [31:0]   axi_rdata  ,     
    output wire [1:0]    axi_rresp  ,     
    output wire          axi_rlast  ,     
    output wire          axi_rvalid ,    
    input  wire          axi_rready ,
    input  wire [7 :0]   axi_awid   ,      
    input  wire [31:0]   axi_awaddr ,    
    input  wire [7 :0]   axi_awlen  ,     
    input  wire [2 :0]   axi_awsize ,    
    input  wire [1 :0]   axi_awburst,   
    input  wire          axi_awvalid,   
    output wire          axi_awready,  
    input  wire [7:0]    axi_wid    ,       
    input  wire [31:0]   axi_wdata  ,     
    input  wire          axi_wlast  ,     
    input  wire [3:0]    axi_wstrb  ,     
    input  wire          axi_wvalid ,  
    output wire          axi_wready ,
    output wire [7:0]    axi_bid    ,       
    output reg  [1:0]    axi_bresp  ,     
    output wire          axi_bvalid , 
    input  wire          axi_bready ,    
    input  wire          ahb_hgrant ,    
    output wire          ahb_hbusreq,   
    output reg  [31:0]   ahb_haddr  ,     
    output reg  [1 :0]   ahb_htrans ,  
    output reg           ahb_hwrite ,
    output reg  [2:0]    ahb_hsize  ,     
    output reg  [2:0]    ahb_hburst ,     
    output wire [31:0]   ahb_hwdata , 
    input  wire [31:0]   ahb_hrdata ,  
    input  wire          ahb_hready ,    
    input  wire [1:0]    ahb_hresp  
); 
 
reg  [8  :0]     cur_st             ;         
reg  [8  :0]     nxt_st             ;
reg  [7  :0]     wr_cnt             ;             
reg              wr_cnt_ld          ;          
reg              wr_cnt_sub         ;  
wire             wr_cnt_sub_en      ;      
wire             wr_cnt_zero        ;     
reg  [7  :0]     rd_cnt             ;             
reg              rd_cnt_ld          ;          
reg              rd_cnt_sub         ;     
wire             rd_cnt_sub_en      ;      
wire             rd_cnt_zero        ;   
wire             last_ctrl          ; 
wire             rd_axi_last        ;  
reg  [7  :0]     wptr               ;               
reg  [7  :0]     rptr               ;               
reg              clr_ptr            ;         
reg              ahb_trans_noseq    ;    
reg              ahb_trans_seq      ;              
reg              axi2buf_en         ;   
reg              ahb2buf_en         ;          
reg              buf2ahb_en         ;        
reg              buf2axi_en         ;          
reg              buf2axi_first      ;   
reg              first_read_flag    ;    
reg              first_trans_en     ;     
wire             first_read_flag_clr; 
reg  [31:0]      data_buf [255:0]   ;
reg  [255 :0]    tea_buf            ;          
reg  [31:0]      o_databuf          ;         
reg  [1 :0]      o_teabuf           ;   
wire [31:0]      i_databuf          ;      
wire             i_teabuf           ;       
wire             databuf_rd         ;              
wire             databuf_wr         ;
wire             buf_empty          ;  
wire             ahb_rd_cplt        ;        
wire             ahb_tea            ;            
wire             ahb_trans_hold     ;     
wire             ahb_trans_seq_en   ;   
wire             ahb_wr_cplt        ;        
wire             ahb_wr_tea         ;         
wire             axi_rd_vld         ;         
wire             axi_wr_vld         ;         
reg  [7 :0]     arid_flop           ;          
reg  [7 :0]     awid_flop           ;  
wire [31:0]     trans_addr          ;         
wire [1 :0]     trans_burst         ;        
wire [7 :0]     trans_len           ;          
wire            trans_req_vld       ;      
wire [2 :0]     trans_size          ;         
wire            haddr_update        ;       
wire            burst_type          ;
reg             burst_type_reg      ;
reg  [7 :0]     trans_len_wrap      ;   
reg  [7 :0]     trans_len_incr      ;  
reg  [31:0]     addr_wrap           ;          
wire            wrap4               ;              
wire            wrap8               ;              
wire            wrap16              ;              
wire            wrap32              ;              
wire            wrap64              ;              
wire            wrap128             ;              
wire            wrap256             ;      
reg  [2 :0]     pre_hburst          ;    
wire            bresp_hold          ;         
wire            bresp_update        ;      


parameter  FSM_IDLE     = 9'b000000001, 
           RD_AXI       = 9'b000000010, 
           WR_AHB       = 9'b000000100, 
           WR_LAST_DATA = 9'b000001000,
           RESP_AXI     = 9'b000010000,
            
           RD_AHB       = 9'b000100000,
           RD_LAST_DATA = 9'b001000000,
           WR_AXI       = 9'b010000000,
           WT_DB_WR     = 9'b100000000; 

always @(posedge clk) begin
  if(!rst_n) begin
      cur_st[8:0] <= FSM_IDLE;
    end
  else begin
      cur_st[8:0] <= nxt_st[8:0];
    end
end

always @(*) begin
    clr_ptr         = 0;
    wr_cnt_ld       = 0;
    wr_cnt_sub      = 0;
    rd_cnt_ld       = 0;
    rd_cnt_sub      = 0;
    first_trans_en  = 0;
    ahb_trans_noseq = 0;
    ahb_trans_seq   = 0;
    buf2axi_first   = 0;
    buf2axi_en      = 0;
    buf2ahb_en      = 0;
    axi2buf_en      = 0;
    ahb2buf_en      = 0;
    case(cur_st[8:0])
        FSM_IDLE: begin
            clr_ptr = 1;
            if(axi_awvalid) begin
                nxt_st[8:0] = RD_AXI;
                wr_cnt_ld   = 1;
              end
            else if(axi_arvalid) begin
                nxt_st[8:0]     = RD_AHB;
                rd_cnt_ld       = 1;
                ahb_trans_noseq = 1;
                first_trans_en  = 1;  //first trans contrl ending cannot access data 
              end
            else begin
                nxt_st[8:0] = FSM_IDLE;
              end
        end
        RD_AXI: begin
            axi2buf_en = 1;
            if(rd_axi_last) begin
                nxt_st[8:0] = WR_AHB;
                ahb_trans_noseq = 1;
              end
            else begin
                nxt_st[8:0] = RD_AXI;
              end
        end
        WR_AHB: begin
            buf2ahb_en = 1;
            wr_cnt_sub = 1;
            ahb_trans_seq = 1;
            if(ahb_tea) begin //while WR_AHB, ahb_tea==1 means hresp!=2'b00, wr_cnt is useless.
                nxt_st[8:0] = RESP_AXI;
              end
            else if(ahb_wr_cplt) begin
                nxt_st[8:0] = WR_LAST_DATA;
              end
            else begin
                nxt_st[8:0] = WR_AHB;
              end
        end      
        WR_LAST_DATA:begin
            if(ahb_hready) begin
                nxt_st[8:0] = RESP_AXI;
              end
            else begin
                nxt_st[8:0] = WR_LAST_DATA;
              end
        end
        RESP_AXI:begin 
            if(axi_bready) begin
                nxt_st[8:0] = FSM_IDLE;
              end
            else begin
                nxt_st[8:0] = RESP_AXI;
              end
        end
        RD_AHB:begin
            ahb_trans_seq = 1;
            rd_cnt_sub    = 1;
            ahb2buf_en    = 1;
            if(ahb_rd_cplt) begin
                nxt_st[8:0] = RD_LAST_DATA;
              end
            else begin
                nxt_st[8:0] = RD_AHB;
              end
        end
        RD_LAST_DATA:begin
            ahb2buf_en = 1;
            if(ahb_hready)begin
                nxt_st[8:0] = WT_DB_WR;
              end
            else begin
                nxt_st[8:0] = RD_LAST_DATA;
              end
        end
        WT_DB_WR:begin
              buf2axi_first = 1;
              nxt_st[8:0] = WR_AXI;
        end
        WR_AXI:begin
            buf2axi_en = 1;
            if(buf_empty && axi_rready) begin
                nxt_st[8:0] = FSM_IDLE;
              end
            else begin
                nxt_st[8:0] = WR_AXI;
              end
        end
        default:begin
            nxt_st[8:0] = WR_AXI;
        end  
    endcase
end

assign rd_axi_last = axi_wlast && axi_wvalid;
assign ahb_wr_cplt = (~|wr_cnt[7:0]) && ahb_hready; 
assign ahb_rd_cplt = (~|rd_cnt[7:0]) && ahb_hready; 

assign first_read_flag_clr = cur_st[5] && ahb_hready; //READ_AHB

always @(posedge clk) begin
  if(!rst_n)begin
      first_read_flag <= 1'b0;
    end
  else if(first_trans_en) begin
      first_read_flag <= 1'b1;
    end
  else if(first_read_flag_clr)begin
      first_read_flag <= 1'b0;
    end
  else begin
      first_read_flag <= first_read_flag;
    end    
end    

//{{------wr_cnt, rd_cnt load----------
assign wr_cnt_sub_en = wr_cnt_sub && ahb_hready;//WR_AHB
always @(posedge clk)begin
  if(!rst_n)begin
      wr_cnt[7:0] <= 8'b0;
    end
  else if(wr_cnt_ld) begin
      wr_cnt[7:0] <= axi_awlen[7:0];
    end
  else if(wr_cnt_sub_en) begin
      wr_cnt[7:0] <= wr_cnt[7:0]-1'b1;
    end
  else begin
      wr_cnt[7:0] <= wr_cnt[7:0];
    end    
end 
assign wr_cnt_zero = ~|wr_cnt[7:0];

assign rd_cnt_sub_en = rd_cnt_sub && ahb_hready;//RD_AHB
always @(posedge clk) begin
  if(!rst_n)begin
      rd_cnt[7:0] <= 8'b0;
    end
  else if(rd_cnt_ld) begin
      rd_cnt[7:0] <= axi_arlen[7:0];
    end
  else if(rd_cnt_sub_en)begin
      rd_cnt[7:0] <= rd_cnt[7:0] - 1'b1;
    end
  else begin
      rd_cnt[7:0] <= rd_cnt[7:0];
    end    
end 
assign rd_cnt_zero = ~|rd_cnt[7:0];

assign last_ctrl = ahb_hwrite ? wr_cnt_zero : rd_cnt_zero;
//}}------wr_cnt, rd_cnt load----------


//{{---------write databuf: RD_AHB || RD_AXI------------
assign databuf_wr = (ahb2buf_en && ahb_hready && !first_read_flag) || (axi2buf_en && axi_wvalid);
always @(posedge clk) begin
  if(!rst_n) begin
      wptr <= 8'b0;
    end
  else if(clr_ptr) begin //IDLE
      wptr <= 8'b0;
    end 
  else if(databuf_wr) begin
      wptr <= wptr + 1'b1;
    end
  else begin
      wptr <= wptr;
    end    
end 
//write buffer
assign i_databuf[31:0] = ahb_hwrite ? axi_wdata : ahb_hrdata;
assign ahb_tea  = ahb_hready && (|ahb_hresp[1:0]);//resp==0, ahb_tea=0
assign i_teabuf = ahb_hwrite ? 0 : ahb_tea;
always @(posedge clk) begin
  if(databuf_wr) begin
      data_buf[wptr] <= i_databuf[31:0];
      tea_buf [wptr] <= i_teabuf;
    end
end
//}}---------write databuf: RD_AHB || RD_AXI------------


//-----------read databuf: WR_AHB || WR_AXI-------------
assign databuf_rd = (buf2ahb_en && ahb_hready) || ((buf2axi_en && axi_rready)|| buf2axi_first);
always @(posedge clk) begin
  if(!rst_n) begin
      rptr <= 8'b0;
    end
  else if(clr_ptr) begin
      rptr <= 8'b0;
    end 
  else if(databuf_rd) begin
      rptr <= rptr + 1'b1;
    end
  else begin
      rptr <= rptr;
    end    
end 
always @(posedge clk) begin
  if(databuf_rd) begin
      o_databuf <= data_buf[rptr];
      o_teabuf[1:0] <= {tea_buf[rptr],1'b0};
    end
end
//}}-----------read databuf: WR_AHB || WR_AXI-------------

assign buf_empty = (wptr == rptr);

//{{-----------process axi_awid, axi_arid----------
assign axi_wr_vld = cur_st[0] && axi_awvalid;
assign axi_rd_vld = cur_st[0] && axi_arvalid && !axi_awvalid;
always @(posedge clk) begin
    if(axi_wr_vld) begin
        awid_flop[7:0] <= axi_awid[7:0];
      end
end
always @(posedge clk) begin
    if(axi_rd_vld) begin
        arid_flop[7:0] <= axi_arid[7:0];
      end
end
//}}-----------process axi_awid, axi_arid----------


//{{-------------AHB BUS OUTPUT---------------
//aw/ar valid ready addr burst size len
assign trans_req_vld = cur_st[0] && (axi_awvalid || axi_arvalid);

assign trans_addr = axi_awvalid ? axi_awaddr : axi_araddr;
assign trans_burst[1:0] = axi_awvalid ? axi_awburst[1:0] : axi_arburst[1:0];
assign trans_size[2:0]  = axi_awvalid ? axi_awsize[2:0]  : axi_arsize[2:0];


//process axi_axlen/burst, for generate haddr
assign trans_len = axi_awvalid ? axi_awlen : axi_arlen;
assign burst_type = (trans_burst==2'b01) ? 1 : 0;
assign haddr_update = ahb_trans_seq && ahb_hready && (!last_ctrl);
//generate ahb_haddr
always @(posedge clk) begin
    if(trans_req_vld) begin
        ahb_haddr <= trans_addr;     //first haddr
        trans_len_wrap <= trans_len;
        burst_type_reg <= burst_type;
      end
    else if(haddr_update) begin
        if(burst_type_reg) begin // INCR
            ahb_haddr <= ahb_haddr + 32'h4; //32bit-32/8=4, 64bit-64/8=8
        end
        else begin // WRAP
            ahb_haddr <= addr_wrap;
        end
      end
end

assign wrap4   = (trans_len_wrap[7:0] == 8'b00000011);
assign wrap8   = (trans_len_wrap[7:0] == 8'b00000111);
assign wrap16  = (trans_len_wrap[7:0] == 8'b00001111);
assign wrap32  = (trans_len_wrap[7:0] == 8'b00011111);
assign wrap64  = (trans_len_wrap[7:0] == 8'b00111111);
assign wrap128 = (trans_len_wrap[7:0] == 8'b01111111);
assign wrap256 = (trans_len_wrap[7:0] == 8'b11111111);

always @(*) begin
addr_wrap[31:10] = ahb_haddr[31:10];
addr_wrap[3:0]  = ahb_haddr[3:0];
    if(wrap4) begin
        addr_wrap[3:2] = ahb_haddr[3:2] + 1'b1;
        addr_wrap[9:4] = ahb_haddr[9:4];
    end
    else if(wrap8) begin
        addr_wrap[4:2] = ahb_haddr[4:2] + 1'b1;
        addr_wrap[9:5] = ahb_haddr[9:5];
    end
    else if(wrap16) begin
        addr_wrap[5:2] = ahb_haddr[5:2] + 1'b1;
        addr_wrap[9:6] = ahb_haddr[9:6];
    end
    else if(wrap32) begin
        addr_wrap[6:2] = ahb_haddr[6:2] + 1'b1;
        addr_wrap[9:7] = ahb_haddr[9:7];
    end
    else if(wrap64) begin
        addr_wrap[7:2] = ahb_haddr[7:2] + 1'b1;
        addr_wrap[9:8] = ahb_haddr[9:8];
    end
    else if(wrap128) begin
        addr_wrap[8:2] = ahb_haddr[8:2] + 1'b1;
        addr_wrap[9] = ahb_haddr[9];
    end
    else if(wrap256) begin
        addr_wrap[9:2] = ahb_haddr[9:2] + 1'b1;
    end
end

//generate ahb_htrans
always @(posedge clk) begin
    if(!rst_n) begin
        ahb_htrans[1:0] <=  2'b00;
      end
    else if(ahb_trans_noseq) begin
        ahb_htrans[1:0] <=  2'b10;
      end
    else if(ahb_wr_tea) begin
        ahb_htrans[1:0] <=  2'b00;   
      end 
    else if(ahb_trans_seq_en) begin
        ahb_htrans[1:0] <=  2'b11;
      end
    else if(ahb_trans_hold) begin
        ahb_htrans[1:0] <= ahb_htrans[1:0];
      end
    else begin
        ahb_htrans[1:0] <=  2'b00;
      end 
  end

assign ahb_wr_tea       = ahb_hwrite && ahb_trans_seq &&  ahb_tea;
assign ahb_trans_seq_en = ahb_trans_seq && ahb_hready && (!last_ctrl);
assign ahb_trans_hold   = ahb_trans_seq && !ahb_hready;

//generate ahb_hsize
always @(posedge clk) begin
    if(trans_req_vld) begin
        ahb_hsize[2:0]<=trans_size[2:0];
      end
  end

//generate ahb_hburst
always @(*) begin
    case({trans_burst[1:0],trans_len})
    10'b01????????: pre_hburst[2:0] = 3'b000;
    10'b1000000011: pre_hburst[2:0] = 3'b001;
    10'b1000000111: pre_hburst[2:0] = 3'b010;
    10'b1000001111: pre_hburst[2:0] = 3'b011;
    10'b1000011111: pre_hburst[2:0] = 3'b100;
    10'b1000111111: pre_hburst[2:0] = 3'b101;
    10'b1001111111: pre_hburst[2:0] = 3'b110;
    10'b1011111111: pre_hburst[2:0] = 3'b111;
    default: pre_hburst[2:0]=3'b000;    
    endcase
end

always @(posedge clk) begin
    if(trans_req_vld) begin
        ahb_hburst[2:0]<=pre_hburst[2:0];
      end
  end

//generate ahb_hwrite
always @(posedge clk) begin
    if(trans_req_vld) begin
        ahb_hwrite <= axi_awvalid;
      end
  end

//generate ahb_hwdata
assign ahb_hwdata = o_databuf;

//generate ahb_hbusreq
assign ahb_hbusreq = ahb_trans_noseq && ahb_hgrant;
//}}-------------AHB BUS OUTPUT---------------


//{{-------------AXI BUS OUTPUT---------------
//generate axi_wready, awready, arready
assign axi_wready = cur_st[1]; 
assign axi_awready = cur_st[0] && axi_awvalid;
assign axi_arready = cur_st[0] && axi_arvalid && !axi_awvalid;

//generate axi_r*
assign axi_rid    = arid_flop;
assign axi_rdata  = o_databuf;
assign axi_rresp  = o_teabuf;
assign axi_rvalid = cur_st[7];
assign axi_rlast  = cur_st[7] && buf_empty ;

//generate axi_b*
assign axi_bid[7:0] = awid_flop[7:0];
assign axi_bvalid = cur_st[4];

assign bresp_update = (cur_st[2] || cur_st[3]) && ahb_hready; //WR_AHB || WR_LAST_DATA
assign bresp_hold   = cur_st[4] && !axi_bready; //RESP_AXI
always @(posedge clk) begin
    if(bresp_update) begin
        axi_bresp[1:0] <= {ahb_tea,1'b0};
      end
    else if(bresp_hold) begin
        axi_bresp[1:0] <= axi_bresp[1:0];
      end
    else begin
        axi_bresp[1:0] <= 2'b0;
      end
end
//}}-------------AXI BUS OUTPUT---------------

endmodule
