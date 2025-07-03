module round_robin_m2s (
    input        clk    ,
    input        rst_n  ,

    input        arbiter_type, // 0: Round Robin, 1: Fixed Priority
 
    input  [2:0] req    ,
    output [2:0] sel     
);

wire          rr_vld       ;     
 
reg [2:0]    last_winner   ;     
reg [2:0]    curr_winner   ;     
 
assign rr_vld = req[0] | req[1] | req[2];   // 产生调度使能信号 
 
always @ (posedge clk) begin 
    if (!rst_n) 
        last_winner <= 3'b0; 
    else if (rr_vld == 1'b1)  
        last_winner <= curr_winner;           // 记录上一次调度的队列 
end 

// 0: Round Robin 
always @ (*) begin 
    if (last_winner == 3'b001) begin      // 轮询当前队列 
        if(req[1] == 1'b1)
            curr_winner = 3'b010;           
        else if(req[2] == 1'b1)
            curr_winner = 3'b100;        
        else if(req[0] == 1'b1)
            curr_winner = 3'b001; 
        else  
            curr_winner = 3'b000;    
    end 
    else if(last_winner == 3'b010)begin 
        if(req[2] == 1'b1)
            curr_winner = 3'b100;        
        else if(req[0] == 1'b1)
            curr_winner = 3'b001; 
        else if(req[1] == 1'b1)
            curr_winner = 3'b010;    
        else  
            curr_winner = 3'b000;    
    end     
    else if(last_winner == 3'b100)begin 
        if(req[0] == 1'b1)
            curr_winner = 3'b001; 
        else if(req[1] == 1'b1)
            curr_winner = 3'b010;    
        else if(req[2] == 1'b1)
            curr_winner = 3'b100; 
        else  
            curr_winner = 3'b000;    
    end     
    else begin 
        if(req[0] == 1'b1)
            curr_winner = 3'b001; 
        else if(req[1] == 1'b1)
            curr_winner = 3'b010;    
        else if(req[2] == 1'b1)
            curr_winner = 3'b100; 
        else  
            curr_winner = 3'b000;    
    end     
end 
   
parameter NUM = 3;
// 1: Fixed Priority
function [NUM-1:0] priority_sel;
     input    [NUM-1:0] request;
     begin
          casex (request)
          3'bxx1: priority_sel = 3'h1;
          3'bx10: priority_sel = 3'h2;
          3'b100: priority_sel = 3'h4;
          default:   priority_sel = 3'h0;
          endcase
     end
endfunction

assign sel = arbiter_type ? priority_sel(req) : curr_winner;

endmodule