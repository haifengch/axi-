module apb_regs_cfg (
                 clk
                ,rst_n
                ,pwrite
                ,psel
                ,penable
                ,paddr
                ,pwdata
                ,prdata
                ,aw_decode_err_reg
                ,ar_decode_err_reg
                ,aw_sid_buffer3
                ,aw_sid_buffer2
                ,aw_sid_buffer1
                ,aw_sid_buffer0
                ,ar_sid_buffer3
                ,ar_sid_buffer2
                ,ar_sid_buffer1
                ,ar_sid_buffer0
                ,aw_transation_count
                ,ar_transation_count
                ,arbiter_type
                ,slaver2_en
                ,slaver1_en
                ,slaver0_en
                );
input           clk;
input           rst_n;
input           pwrite;
input           psel;
input           penable;
input  [31:0]   paddr;
input  [31:0]   pwdata;
output [31:0]   prdata;
input           aw_decode_err_reg;
input           ar_decode_err_reg;
input  [7:0]    aw_sid_buffer3;
input  [7:0]    aw_sid_buffer2;
input  [7:0]    aw_sid_buffer1;
input  [7:0]    aw_sid_buffer0;
input  [7:0]    ar_sid_buffer3;
input  [7:0]    ar_sid_buffer2;
input  [7:0]    ar_sid_buffer1;
input  [7:0]    ar_sid_buffer0;
input  [31:0]   aw_transation_count;
input  [31:0]   ar_transation_count;
output          arbiter_type;
output          slaver2_en;
output          slaver1_en;
output          slaver0_en;

wire            clk;
wire            rst_n;
wire            pwrite;
wire            psel;
wire            penable;
wire [31:0]     paddr;
wire [31:0]     pwdata;
reg  [31:0]     prdata;
wire            aw_decode_err_reg;
wire            ar_decode_err_reg;
wire [7:0]      aw_sid_buffer3;
wire [7:0]      aw_sid_buffer2;
wire [7:0]      aw_sid_buffer1;
wire [7:0]      aw_sid_buffer0;
wire [7:0]      ar_sid_buffer3;
wire [7:0]      ar_sid_buffer2;
wire [7:0]      ar_sid_buffer1;
wire [7:0]      ar_sid_buffer0;
wire [31:0]     aw_transation_count;
wire [31:0]     ar_transation_count;
reg             arbiter_type;
reg             slaver2_en;
reg             slaver1_en;
reg             slaver0_en;
wire [31:0]     DECODE_ERR_REG;
wire [31:0]     AW_SID_BUFFER;
wire [31:0]     AR_SID_BUFFER;
wire [31:0]     AW_TRANSATION_COUNT;
wire [31:0]     AR_TRANSATION_COUNT;
wire [31:0]     ARBITER_TYPE;
wire [31:0]     SLAVER_EN;
wire            decode_err_reg_wr;
wire            decode_err_reg_rd;
wire            aw_sid_buffer_wr;
wire            aw_sid_buffer_rd;
wire            ar_sid_buffer_wr;
wire            ar_sid_buffer_rd;
wire            aw_transation_count_wr;
wire            aw_transation_count_rd;
wire            ar_transation_count_wr;
wire            ar_transation_count_rd;
wire            arbiter_type_wr;
wire            arbiter_type_rd;
wire            slaver_en_wr;
wire            slaver_en_rd;
wire            reg_wr;
wire            reg_rd;
wire            apb_wr_en;
wire            apb_rd_en;

assign reg_wr = psel & pwrite & penable;
assign reg_rd = psel & (~pwrite) & (~penable);
assign decode_err_reg_wr = (paddr == 32'h50000000 + 8'h00) & reg_wr;
assign decode_err_reg_rd = (paddr == 32'h50000000 + 8'h00) & reg_rd;
assign aw_sid_buffer_wr = (paddr == 32'h50000000 + 8'h04) & reg_wr;
assign aw_sid_buffer_rd = (paddr == 32'h50000000 + 8'h04) & reg_rd;
assign ar_sid_buffer_wr = (paddr == 32'h50000000 + 8'h08) & reg_wr;
assign ar_sid_buffer_rd = (paddr == 32'h50000000 + 8'h08) & reg_rd;
assign aw_transation_count_wr = (paddr == 32'h50000000 + 8'h0c) & reg_wr;
assign aw_transation_count_rd = (paddr == 32'h50000000 + 8'h0c) & reg_rd;
assign ar_transation_count_wr = (paddr == 32'h50000000 + 8'h10) & reg_wr;
assign ar_transation_count_rd = (paddr == 32'h50000000 + 8'h10) & reg_rd;
assign arbiter_type_wr = (paddr == 32'h50000000 + 8'h14) & reg_wr;
assign arbiter_type_rd = (paddr == 32'h50000000 + 8'h14) & reg_rd;
assign slaver_en_wr = (paddr == 32'h50000000 + 8'h18) & reg_wr;
assign slaver_en_rd = (paddr == 32'h50000000 + 8'h18) & reg_rd;
assign apb_wr_en = decode_err_reg_wr | aw_sid_buffer_wr | ar_sid_buffer_wr | aw_transation_count_wr | ar_transation_count_wr | arbiter_type_wr | slaver_en_wr;
assign apb_rd_en = decode_err_reg_rd | aw_sid_buffer_rd | ar_sid_buffer_rd | aw_transation_count_rd | ar_transation_count_rd | arbiter_type_rd | slaver_en_rd;


//regs defination
assign DECODE_ERR_REG[31:2] = 30'b0;
assign DECODE_ERR_REG[1] = aw_decode_err_reg;
assign DECODE_ERR_REG[0] = ar_decode_err_reg;
assign AW_SID_BUFFER[31:24] = aw_sid_buffer3;
assign AW_SID_BUFFER[23:16] = aw_sid_buffer2;
assign AW_SID_BUFFER[15:8] = aw_sid_buffer1;
assign AW_SID_BUFFER[7:0] = aw_sid_buffer0;
assign AR_SID_BUFFER[31:24] = ar_sid_buffer3;
assign AR_SID_BUFFER[23:16] = ar_sid_buffer2;
assign AR_SID_BUFFER[15:8] = ar_sid_buffer1;
assign AR_SID_BUFFER[7:0] = ar_sid_buffer0;
assign AW_TRANSATION_COUNT[31:0] = aw_transation_count;
assign AR_TRANSATION_COUNT[31:0] = ar_transation_count;
assign ARBITER_TYPE[31:1] = 31'b0;
assign ARBITER_TYPE[0] = 1'b0;
assign SLAVER_EN[31:3] = 29'b0;
assign SLAVER_EN[2] = 1'b1;
assign SLAVER_EN[1] = 1'b1;
assign SLAVER_EN[0] = 1'b1;

//write regs
always@(posedge clk) begin
    if(!rst_n) begin
        arbiter_type <= 1'b0;
    end
    else if(arbiter_type_wr) begin
        arbiter_type <= pwdata[0];
    end
end

always@(posedge clk) begin
    if(!rst_n) begin
        slaver2_en <= 1'b1;
    end
    else if(slaver_en_wr) begin
        slaver2_en <= pwdata[2];
    end
end

always@(posedge clk) begin
    if(!rst_n) begin
        slaver1_en <= 1'b1;
    end
    else if(slaver_en_wr) begin
        slaver1_en <= pwdata[1];
    end
end

always@(posedge clk) begin
    if(!rst_n) begin
        slaver0_en <= 1'b1;
    end
    else if(slaver_en_wr) begin
        slaver0_en <= pwdata[0];
    end
end

//read regs
always@(posedge clk) begin
    if(!rst_n) begin
        prdata <= 32'b0;
    end
    else if (apb_rd_en) begin
        case(paddr)
        32'h50000000 + 8'h00 : prdata = DECODE_ERR_REG;
        32'h50000000 + 8'h04 : prdata = AW_SID_BUFFER;
        32'h50000000 + 8'h08 : prdata = AR_SID_BUFFER;
        32'h50000000 + 8'h0c : prdata = AW_TRANSATION_COUNT;
        32'h50000000 + 8'h10 : prdata = AR_TRANSATION_COUNT;
        32'h50000000 + 8'h14 : prdata = ARBITER_TYPE;
        32'h50000000 + 8'h18 : prdata = SLAVER_EN ;
        default:prdata = 32'b0;
        endcase
    end
end
endmodule