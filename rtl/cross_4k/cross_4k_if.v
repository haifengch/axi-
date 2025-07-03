// INCR BURST ONLY
module cross_4k_if #(
      parameter W_ID   = 4           // ID width
              , W_CID  = 4
              , W_ADDR = 32          // address width
              , W_LEN  = 8
              , W_DATA = 32          // data width
              , W_STRB = (W_DATA/8)  // data strobe width
              , W_SID  = (W_CID+W_ID)// slave ID
) (
      input                          clk        
    , input                          rst_n      

    // input
    , input  wire    [W_ID-1 :0]     m_axi_arid    
    , input  wire    [W_ADDR-1:0]    m_axi_araddr  
    , input  wire    [W_LEN-1 :0]    m_axi_arlen   
    , input  wire    [2 :0]          m_axi_arsize  
    , input  wire    [1 :0]          m_axi_arburst 
    , input  wire                    m_axi_arvalid 
    , output reg                     m_axi_arready 

    , input  wire    [W_ID-1 :0]     m_axi_awid    
    , input  wire    [W_ADDR-1:0]    m_axi_awaddr  
    , input  wire    [W_LEN-1 :0]    m_axi_awlen   
    , input  wire    [2 :0]          m_axi_awsize  
    , input  wire    [1 :0]          m_axi_awburst 
    , input  wire                    m_axi_awvalid 
    , output reg                     m_axi_awready 

    // output
    , output  reg    [W_ID-1:0]      s_axi_arid    
    , output  reg    [W_ADDR-1:0]    s_axi_araddr  
    , output  reg    [W_LEN-1:0]     s_axi_arlen   
    , output  reg    [2:0]           s_axi_arsize  
    , output  reg    [1:0]           s_axi_arburst 
    , output  reg                    s_axi_arvalid 
    , input   wire                   s_axi_arready

    , output  reg    [W_ID-1:0]      s_axi_awid    
    , output  reg    [W_ADDR-1:0]    s_axi_awaddr  
    , output  reg    [W_LEN-1:0]     s_axi_awlen   
    , output  reg    [2:0]           s_axi_awsize  
    , output  reg    [1:0]           s_axi_awburst 
    , output  reg                    s_axi_awvalid 
    , input   wire                   s_axi_awready

);

wire [W_ADDR-1 : 0]    m_araddr_end  ;
wire [W_ADDR-1 : 0]    m_awaddr_end  ;

assign m_araddr_end = m_axi_araddr + (m_axi_arlen << 2); //m_axi_arlen*4, 4*8=32
assign m_awaddr_end = m_axi_awaddr + (m_axi_awlen << 2);

assign ar_cross4k_flag = m_axi_araddr[12] ^ m_araddr_end[12];
assign aw_cross4k_flag = m_axi_awaddr[12] ^ m_awaddr_end[12];

//signal for split to 2-transactions
reg [W_ID-1:0]      trans_arid    ; 
reg [2:0]           trans_arsize  ; 
reg [1:0]           trans_arburst ; 
reg [W_ADDR-1:0]    trans1_araddr ; 
reg [W_LEN-1:0]     trans1_arlen  ; 
reg [W_ADDR-1:0]    trans2_araddr ; 
reg [W_LEN-1:0]     trans2_arlen  ; 
reg                 trans_arvalid ; 

reg [W_ID-1:0]      trans_awid    ; 
reg [2:0]           trans_awsize  ; 
reg [1:0]           trans_awburst ; 
reg [W_ADDR-1:0]    trans1_awaddr ; 
reg [W_LEN-1:0]     trans1_awlen  ; 
reg [W_ADDR-1:0]    trans2_awaddr ; 
reg [W_LEN-1:0]     trans2_awlen  ; 
reg                 trans_awvalid ; 
reg                 aw_trans_stall;

always @(*) begin
    if (m_axi_arvalid & ar_cross4k_flag) begin
        trans_arid    = m_axi_arid   ;
        trans_arsize  = m_axi_arsize ;
        trans_arburst = m_axi_arburst;
        trans1_araddr = m_axi_araddr ;
        trans1_arlen  = ({m_axi_araddr[29:12], 12'hfff} - m_axi_araddr + 1'b1) >> 2;
        trans2_araddr = {m_axi_araddr[29:12] + 1'b1, 12'h0};
        trans2_arlen  = (m_araddr_end - {m_axi_araddr[29:12] + 1'b1, 12'h0} + 1'b1) >> 2;
        trans_arvalid = m_axi_arvalid;
    end
    if (m_axi_awvalid & aw_cross4k_flag) begin
        trans_awid    = m_axi_awid   ;
        trans_awsize  = m_axi_awsize ;
        trans_awburst = m_axi_awburst;
        trans1_awaddr = m_axi_awaddr ;
        trans1_awlen  = ({m_axi_awaddr[29:12], 12'hfff} - m_axi_awaddr + 1'b1) >> 2;
        trans2_awaddr = {m_axi_awaddr[29:12] + 1'b1, 12'h0};
        trans2_awlen  = (m_awaddr_end - {m_axi_awaddr[29:12] + 1'b1, 12'h0} + 1'b1) >> 2;
        trans_awvalid = m_axi_awvalid;
    end
end

reg [2:0] ST_AR_C4K, ST_AW_C4K;
parameter IDLE   = 3'h0,
          TRANS1 = 3'h1,
          TRANS2 = 3'h2;

//ARADDR
always @(posedge clk) begin
    if (!rst_n) begin
        ST_AR_C4K <= 0;
    end else begin
        case (ST_AR_C4K)
            IDLE: begin 
                if (ar_cross4k_flag) begin
                    ST_AR_C4K  <= TRANS1;
                end
            end
            TRANS1: begin
                if (s_axi_arready) begin
                    ST_AR_C4K  <= TRANS2;
                end
            end
            TRANS2: if (s_axi_arready) begin
                ST_AR_C4K  <= IDLE;
            end
        endcase
    end
end

always @(*) begin
    if (ST_AR_C4K==TRANS1) begin
        s_axi_arid    = trans_arid   ;
        s_axi_araddr  = trans1_araddr ;
        s_axi_arlen   = trans1_arlen  ;
        s_axi_arsize  = trans_arsize ;
        s_axi_arburst = trans_arburst;
        s_axi_arvalid = trans_arvalid;
        m_axi_arready = 0;
    end
    else if (ST_AR_C4K==TRANS2) begin
        s_axi_arid    = trans_arid   ;
        s_axi_araddr  = trans2_araddr ;
        s_axi_arlen   = trans2_arlen  ;
        s_axi_arsize  = trans_arsize ;
        s_axi_arburst = trans_arburst;
        s_axi_arvalid = trans_arvalid;
        m_axi_arready = 1;
    end
    else if(ST_AR_C4K==IDLE) begin
        if(!ar_cross4k_flag && s_axi_arready) begin
            s_axi_arid    = m_axi_arid   ;
            s_axi_araddr  = m_axi_araddr ;
            s_axi_arlen   = m_axi_arlen  ;
            s_axi_arsize  = m_axi_arsize ;
            s_axi_arburst = m_axi_arburst;
            s_axi_arvalid = m_axi_arvalid;
            m_axi_arready = 1;
        end
        else begin
            s_axi_arid    = 0;
            s_axi_araddr  = 0;
            s_axi_arlen   = 0;
            s_axi_arsize  = 0;
            s_axi_arburst = 0;
            s_axi_arvalid = 0;
            m_axi_arready = 0;
        end
    end
end

//AWADDR
always @(posedge clk) begin
    if (!rst_n) begin
        ST_AW_C4K <= 0;
    end else begin
        case (ST_AW_C4K)
            IDLE: begin 
                if (aw_cross4k_flag) begin
                    ST_AW_C4K  <= TRANS1;
                end
            end
            TRANS1: begin
                if (s_axi_awready) begin
                    ST_AW_C4K  <= TRANS2;
                end
            end
            TRANS2: if (s_axi_awready) begin
                ST_AW_C4K  <= IDLE;
            end
        endcase
    end
end

always @(*) begin
    if (ST_AW_C4K == TRANS1) begin
        s_axi_awid    = trans_awid   ;
        s_axi_awaddr  = trans1_awaddr ;
        s_axi_awlen   = trans1_awlen  ;
        s_axi_awsize  = trans_awsize ;
        s_axi_awburst = trans_awburst;
        s_axi_awvalid = trans_awvalid;
        m_axi_awready = 0;
    end
    else if (ST_AW_C4K == TRANS2) begin
        s_axi_awid    = {(trans_awid[3:2] + 2'b1), trans_awid[1:0]};
        s_axi_awaddr  = trans2_awaddr ;
        s_axi_awlen   = trans2_awlen  ;
        s_axi_awsize  = trans_awsize ;
        s_axi_awburst = trans_awburst;
        s_axi_awvalid = trans_awvalid;
        m_axi_awready = 1;
    end
    else if(ST_AW_C4K == IDLE) begin
        if(!aw_cross4k_flag && s_axi_awready) begin
            s_axi_awid    = m_axi_awid   ;
            s_axi_awaddr  = m_axi_awaddr ;
            s_axi_awlen   = m_axi_awlen  ;
            s_axi_awsize  = m_axi_awsize ;
            s_axi_awburst = m_axi_awburst;
            s_axi_awvalid = m_axi_awvalid;
            m_axi_awready = 1;
        end
        else begin
            s_axi_awid    = 0;
            s_axi_awaddr  = 0;
            s_axi_awlen   = 0;
            s_axi_awsize  = 0;
            s_axi_awburst = 0;
            s_axi_awvalid = 0;
            m_axi_awready = 0;
        end
    end
end

endmodule