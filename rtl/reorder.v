module reorder (
    input            clk        ,
    input            rstn       ,
    
    input [7:0]      sid_0      ,
    input            sid_0_vld  ,

    input [7:0]      sid_1      ,
    input            sid_1_vld  ,

    input [7:0]      sid_2      ,
    input            sid_2_vld  ,

    input wire [7:0] rob_buffer [0:3] ,

    output reg [2:0] order_grant   
);

// genvar i, j;

// wire [3:0] s_rid_low  [2:0];
// wire [3:0] s_rid_high [2:0];
wire [3:0] s0_rid_low, s0_rid_high;
wire [3:0] s1_rid_low, s1_rid_high;
wire [3:0] s2_rid_low, s2_rid_high;

//low 4-bit
// generate
//     for (i = 0; i<3; i++) begin
//         for (j = 0; j<4; j++) begin
//             assign s_rid_low[i][j] = (s_rid[i][3:0]==rob_buffer[j][3:0]) ? 1'b1 : 1'b0;
//         end
        
//     end
// endgenerate
assign s0_rid_low[0] = (sid_0_vld && sid_0[3:0]==rob_buffer[0][3:0]) ? 1'b1 : 1'b0;
assign s0_rid_low[1] = (sid_0_vld && sid_0[3:0]==rob_buffer[1][3:0]) ? 1'b1 : 1'b0;
assign s0_rid_low[2] = (sid_0_vld && sid_0[3:0]==rob_buffer[2][3:0]) ? 1'b1 : 1'b0;
assign s0_rid_low[3] = (sid_0_vld && sid_0[3:0]==rob_buffer[3][3:0]) ? 1'b1 : 1'b0;

assign s1_rid_low[0] = (sid_1_vld && sid_1[3:0]==rob_buffer[0][3:0]) ? 1'b1 : 1'b0;
assign s1_rid_low[1] = (sid_1_vld && sid_1[3:0]==rob_buffer[1][3:0]) ? 1'b1 : 1'b0;
assign s1_rid_low[2] = (sid_1_vld && sid_1[3:0]==rob_buffer[2][3:0]) ? 1'b1 : 1'b0;
assign s1_rid_low[3] = (sid_1_vld && sid_1[3:0]==rob_buffer[3][3:0]) ? 1'b1 : 1'b0;

assign s2_rid_low[0] = (sid_2_vld && sid_2[3:0]==rob_buffer[0][3:0]) ? 1'b1 : 1'b0;
assign s2_rid_low[1] = (sid_2_vld && sid_2[3:0]==rob_buffer[1][3:0]) ? 1'b1 : 1'b0;
assign s2_rid_low[2] = (sid_2_vld && sid_2[3:0]==rob_buffer[2][3:0]) ? 1'b1 : 1'b0;
assign s2_rid_low[3] = (sid_2_vld && sid_2[3:0]==rob_buffer[3][3:0]) ? 1'b1 : 1'b0;

//high 4-bit
// generate
//     for (i = 0; i<3; i++) begin
//         for (j = 0; j<4; j++) begin
//             assign s_rid_high[i][j] = (s_rid[i][7:4]==rob_buffer[j][7:4]) ? 1'b1 : 1'b0;
//         end 
//     end
// endgenerate
assign s0_rid_high[0] = (sid_0_vld && sid_0[7:4]==rob_buffer[0][7:4]) ? 1'b1 : 1'b0;
assign s0_rid_high[1] = (sid_0_vld && sid_0[7:4]==rob_buffer[1][7:4]) ? 1'b1 : 1'b0;
assign s0_rid_high[2] = (sid_0_vld && sid_0[7:4]==rob_buffer[2][7:4]) ? 1'b1 : 1'b0;
assign s0_rid_high[3] = (sid_0_vld && sid_0[7:4]==rob_buffer[3][7:4]) ? 1'b1 : 1'b0;

assign s1_rid_high[0] = (sid_1_vld && sid_1[7:4]==rob_buffer[0][7:4]) ? 1'b1 : 1'b0;
assign s1_rid_high[1] = (sid_1_vld && sid_1[7:4]==rob_buffer[1][7:4]) ? 1'b1 : 1'b0;
assign s1_rid_high[2] = (sid_1_vld && sid_1[7:4]==rob_buffer[2][7:4]) ? 1'b1 : 1'b0;
assign s1_rid_high[3] = (sid_1_vld && sid_1[7:4]==rob_buffer[3][7:4]) ? 1'b1 : 1'b0;

assign s2_rid_high[0] = (sid_2_vld && sid_2[7:4]==rob_buffer[0][7:4]) ? 1'b1 : 1'b0;
assign s2_rid_high[1] = (sid_2_vld && sid_2[7:4]==rob_buffer[1][7:4]) ? 1'b1 : 1'b0;
assign s2_rid_high[2] = (sid_2_vld && sid_2[7:4]==rob_buffer[2][7:4]) ? 1'b1 : 1'b0;
assign s2_rid_high[3] = (sid_2_vld && sid_2[7:4]==rob_buffer[3][7:4]) ? 1'b1 : 1'b0;

//s0 order_grant
always @(posedge clk) begin
    if(!rstn) begin
        order_grant[0] <= 'd0;
    end
    else begin
        if(s0_rid_high[0]==1'b1 && s0_rid_low[0]==1'b1)
            order_grant[0] <= 1'b1;
        else if(s0_rid_high[1:0]==2'b10 && s0_rid_low[1:0]==2'b10)
            order_grant[0] <= 1'b1;
        else if(s0_rid_high[2:0]==3'b100 && s0_rid_low[2:0]==3'b100)
            order_grant[0] <= 1'b1;
        else if(s0_rid_high[3:0]==4'b1000 && s0_rid_low[3:0]==4'b1000)
            order_grant[0] <= 1'b1;
        else
            order_grant[0] <= 1'b0;
    end
end  

//s1 order_grant
always @(posedge clk) begin
    if(!rstn) begin
        order_grant[1] <= 'd0;
    end
    else begin
        if(s1_rid_high[0]==1'b1 && s1_rid_low[0]==1'b1)
            order_grant[1] <= 1'b1;
        else if(s1_rid_high[1:0]==2'b10 && s1_rid_low[1:0]==2'b10)
            order_grant[1] <= 1'b1;
        else if(s1_rid_high[2:0]==3'b100 && s1_rid_low[2:0]==3'b100)
            order_grant[1] <= 1'b1;
        else if(s1_rid_high[3:0]==4'b1000 && s1_rid_low[3:0]==4'b1000)
            order_grant[1] <= 1'b1;
        else
            order_grant[1] <= 1'b0;
    end
end  

//s2 order_grant
always @(posedge clk) begin
    if(!rstn) begin
        order_grant[2] <= 'd0;
    end
    else begin
        if(s2_rid_high[0]==1'b1 && s2_rid_low[0]==1'b1)
            order_grant[2] <= 1'b1;
        else if(s2_rid_high[1:0]==2'b10 && s2_rid_low[1:0]==2'b10)
            order_grant[2] <= 1'b1;
        else if(s2_rid_high[2:0]==3'b100 && s2_rid_low[2:0]==3'b100)
            order_grant[2] <= 1'b1;
        else if(s2_rid_high[3:0]==4'b1000 && s2_rid_low[3:0]==4'b1000)
            order_grant[2] <= 1'b1;
        else
            order_grant[2] <= 1'b0;
    end
end  

endmodule