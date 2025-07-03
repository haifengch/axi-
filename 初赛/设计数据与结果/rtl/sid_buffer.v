
module sid_buffer(
    input            clk          ,
    input            rstn         ,

//----------------Write buffer-------------------
    input [7:0]      s0_axid      ,
    input            s0_axid_vld  ,
    input            s0_fifo_rdy  ,
    output           s0_push_rdy  ,

    input [7:0]      s1_axid      ,
    input            s1_axid_vld  ,
    input            s1_fifo_rdy  ,
    output           s1_push_rdy  ,

    input [7:0]      s2_axid      ,
    input            s2_axid_vld  ,
    input            s2_fifo_rdy  ,
    output           s2_push_rdy  ,

//--------Clean buffer and ajust position--------
    input            last_0       ,      
    input [7:0]      sid_0        ,
    input            sid_0_vld    ,
    output           sid_0_clr_rdy,

    input            last_1       ,      
    input [7:0]      sid_1        ,
    input            sid_1_vld    ,
    output           sid_1_clr_rdy,

    input            last_2       ,      
    input [7:0]      sid_2        ,
    input            sid_2_vld    ,
    output           sid_2_clr_rdy,

    output reg [7:0] sid_buffer [0:3]
);

parameter NUM = 3;

reg  [2:0] push_select;
wire [2:0] push_grant;
wire       full;

wire [2:0] clr_select;
wire [2:0] clr_grant;
wire [3:0] clr_idx;
wire       clr_rdy;

//----------------Write buffer-------------------
always @(*) begin
    if (!rstn) begin
        push_select = 'd0;
    end else begin
        push_select[0] = s0_axid_vld & s0_fifo_rdy;
        push_select[1] = s1_axid_vld & s1_fifo_rdy;
        push_select[2] = s2_axid_vld & s2_fifo_rdy;
    end
end

assign push_grant = priority_sel(push_select);

assign clr_rdy = (~|clr_grant) && (~full);

assign s0_push_rdy = ~(push_select[0] ^ push_grant[0]) && clr_rdy;
assign s1_push_rdy = ~(push_select[1] ^ push_grant[1]) && clr_rdy;
assign s2_push_rdy = ~(push_select[2] ^ push_grant[2]) && clr_rdy;

always @(posedge clk ) begin
    if(!rstn) begin
        sid_buffer[0] <= 1'b0;
        sid_buffer[1] <= 1'b0;
        sid_buffer[2] <= 1'b0;
        sid_buffer[3] <= 1'b0;
    end 
    else if(push_grant[0] && s0_push_rdy) begin
        if (sid_buffer[0] == 1'b0) begin
            sid_buffer[0] <= s0_axid;
        end 
        else if (sid_buffer[1] == 1'b0) begin
            sid_buffer[1] <= s0_axid;
        end
        else if (sid_buffer[2] == 1'b0) begin
            sid_buffer[2] <= s0_axid;
        end
        else if (sid_buffer[3] == 1'b0) begin
            sid_buffer[3] <= s0_axid;
        end
    end
    else if(push_grant[1] && s1_push_rdy) begin
        if (sid_buffer[0] == 1'b0) begin
            sid_buffer[0] <= s1_axid;
        end 
        else if (sid_buffer[1] == 1'b0) begin
            sid_buffer[1] <= s1_axid;
        end
        else if (sid_buffer[2] == 1'b0) begin
            sid_buffer[2] <= s1_axid;
        end
        else if (sid_buffer[3] == 1'b0) begin
            sid_buffer[3] <= s1_axid;
        end
    end
    else if(push_grant[2] && s2_push_rdy) begin
        if (sid_buffer[0] == 1'b0) begin
            sid_buffer[0] <= s2_axid;
        end 
        else if (sid_buffer[1] == 1'b0) begin
            sid_buffer[1] <= s2_axid;
        end
        else if (sid_buffer[2] == 1'b0) begin
            sid_buffer[2] <= s2_axid;
        end
        else if (sid_buffer[3] == 1'b0) begin
            sid_buffer[3] <= s2_axid;
        end
    end
end

assign full = (sid_buffer[3] == 1'b0) ? 0 : 1;

//----------------Clean buffer and ajust position-------------------
assign clr_select[0] = last_0 & sid_0_vld;
assign clr_select[1] = last_1 & sid_1_vld;
assign clr_select[2] = last_2 & sid_2_vld;

assign clr_grant = priority_sel(clr_select);

assign sid_0_clr_rdy = ~(clr_select[0] ^ clr_grant[0]);
assign sid_1_clr_rdy = ~(clr_select[1] ^ clr_grant[1]);
assign sid_2_clr_rdy = ~(clr_select[2] ^ clr_grant[2]);

genvar i;
generate
    for (i = 0; i < 4; i=i+1) begin : idx_loop
        assign clr_idx[i] = (clr_grant[0] && (sid_0 == sid_buffer[i])) ? 1'b1 :
                            (clr_grant[1] && (sid_1 == sid_buffer[i])) ? 1'b1 :
                            (clr_grant[2] && (sid_2 == sid_buffer[i])) ? 1'b1 : 1'b0;
    end
endgenerate


always @(posedge clk) begin
    if (clr_idx[0]) begin
        sid_buffer[0] <= sid_buffer[1];
        sid_buffer[1] <= sid_buffer[2];
        sid_buffer[2] <= sid_buffer[3];
        sid_buffer[3] <= 1'b0;
    end 
    else if (clr_idx[1]) begin
        sid_buffer[1] <= sid_buffer[2];
        sid_buffer[2] <= sid_buffer[3];
        sid_buffer[3] <= 1'b0;
    end
    else if(clr_idx[2]) begin
        sid_buffer[2] <= sid_buffer[3];
        sid_buffer[3] <= 1'b0;
    end
    else if (clr_idx[3]) begin
        sid_buffer[3] <= 1'b0;
    end
end

function [NUM-1:0] priority_sel;
    input    [NUM-1:0] request;
    begin
        casex (request)
            3'bxx1: priority_sel = 3'h1;
            3'bx10: priority_sel = 3'h2;
            3'b100: priority_sel = 3'h4;
            default:priority_sel = 3'h0;
        endcase
    end
endfunction

endmodule