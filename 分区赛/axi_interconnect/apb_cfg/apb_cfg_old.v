module apb_cfg_old (
     input  wire          clk 
    ,input  wire          rst_n 

    ,input  wire          pwrite 
    ,input  wire          psel 
    ,input  wire          penable 
    ,input  wire [31:0]   paddr 
    ,input  wire [31:0]   pwdata 
    ,output reg  [31:0]   prdata 

    ,input  wire [0:0]    aw_decode_err_reg 
    ,input  wire [0:0]    ar_decode_err_reg 
    ,input  wire [7:0]    aw_sid_buffer3 
    ,input  wire [7:0]    aw_sid_buffer2 
    ,input  wire [7:0]    aw_sid_buffer1 
    ,input  wire [7:0]    aw_sid_buffer0 
    ,input  wire [7:0]    ar_sid_buffer3 
    ,input  wire [7:0]    ar_sid_buffer2 
    ,input  wire [7:0]    ar_sid_buffer1 
    ,input  wire [7:0]    ar_sid_buffer0 
                );

wire            decode_err_reg_wr;
wire            decode_err_reg_rd;
wire            aw_sid_buffer_wr;
wire            aw_sid_buffer_rd;
wire            ar_sid_buffer_wr;
wire            ar_sid_buffer_rd;
wire            reg_wr;
wire            reg_rd;
wire            apb_wr_en;
wire            apb_rd_en;

//REGS
wire [31:0]     DECODE_ERR_REG;
wire [31:0]     AW_SID_BUFFER;
wire [31:0]     AR_SID_BUFFER;

reg  [31:0]     aw_transation_count;
reg  [31:0]     ar_transation_count;

assign reg_wr = psel & pwrite & penable;
assign reg_rd = psel & (~pwrite) & (~penable);

assign decode_err_reg_wr = (paddr == 32'h50000000 + 8'h00) & reg_wr;
assign decode_err_reg_rd = (paddr == 32'h50000000 + 8'h00) & reg_rd;
assign aw_sid_buffer_wr  = (paddr == 32'h50000000 + 8'h04) & reg_wr;
assign aw_sid_buffer_rd  = (paddr == 32'h50000000 + 8'h04) & reg_rd;
assign ar_sid_buffer_wr  = (paddr == 32'h50000000 + 8'h08) & reg_wr;
assign ar_sid_buffer_rd  = (paddr == 32'h50000000 + 8'h08) & reg_rd;

assign apb_wr_en = decode_err_reg_wr | aw_sid_buffer_wr | ar_sid_buffer_wr;
assign apb_rd_en = decode_err_reg_rd | aw_sid_buffer_rd | ar_sid_buffer_rd;

assign DECODE_ERR_REG[31:2] = 26'b0;
assign DECODE_ERR_REG[1]  = aw_decode_err_reg;
assign DECODE_ERR_REG[0]  = ar_decode_err_reg;

assign AW_SID_BUFFER[31:24] = aw_sid_buffer3;
assign AW_SID_BUFFER[23:16] = aw_sid_buffer2;
assign AW_SID_BUFFER[15:8]  = aw_sid_buffer1;
assign AW_SID_BUFFER[7:0]   = aw_sid_buffer0;

assign AR_SID_BUFFER[31:24] = ar_sid_buffer3;
assign AR_SID_BUFFER[23:16] = ar_sid_buffer2;
assign AR_SID_BUFFER[15:8]  = ar_sid_buffer1;
assign AR_SID_BUFFER[7:0]   = ar_sid_buffer0;

// ar/aw_transation_count
always @(posedge clk) begin
    if(!rst_n) begin
        aw_transation_count <= 0;
        ar_transation_count <= 0;
    end
    else begin
        aw_transation_count <= |aw_sid_buffer0 + |aw_sid_buffer1 + |aw_sid_buffer2 + |aw_sid_buffer3;
        ar_transation_count <= |ar_sid_buffer0 + |ar_sid_buffer1 + |ar_sid_buffer2 + |ar_sid_buffer3;
    end
end

always@(posedge clk) begin
    if(!rst_n) begin
        prdata <= 32'b0;
    end
    else if (apb_rd_en) begin
        case(paddr)
            32'h50000000 + 8'h00 : prdata <= DECODE_ERR_REG;
            32'h50000000 + 8'h04 : prdata <= AW_SID_BUFFER;
            32'h50000000 + 8'h08 : prdata <= AR_SID_BUFFER;
            32'h50000000 + 8'h0c : prdata <= aw_transation_count;
            32'h50000000 + 8'h10 : prdata <= ar_transation_count;
            default:prdata <= 32'b0;
        endcase
    end
end

endmodule
