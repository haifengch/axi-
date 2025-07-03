module rr_fixed_arbiter (
    input        clk         ,
    input        rst_n       ,
    
    input        arbiter_type, // 0: Round Robin, 1: Fixed Priority
 
    input  [3:0] req         ,
    output [3:0] sel     
);

wire          rr_vld       ;     
 
reg [3:0]    last_winner   ;     
reg [3:0]    curr_winner   ;     
 
assign rr_vld = req[0] | req[1] | req[2] | req[3];   // 产生调度使能信号 
 
always @ (posedge clk) begin 
    if (!rst_n) 
        last_winner <= 4'b0; 
    else if (rr_vld == 1'b1)  
        last_winner <= curr_winner;           // 记录上一次调度的队列 
end 

// 0: Round Robin 
always @ (*) begin 
    if (last_winner == 4'b0001) begin      // 轮询当前队列 
        if(req[1] == 1'b1)
            curr_winner = 4'b0010;           
        else if(req[2] == 1'b1)
            curr_winner = 4'b0100;
        else if(req[3] == 1'b1)
                curr_winner = 4'b1000;        
        else if(req[0] == 1'b1)
            curr_winner = 4'b0001; 
        else  
            curr_winner = 4'b0000;    
    end 
    else if(last_winner == 4'b0010)begin 
        if(req[2] == 1'b1)
            curr_winner = 4'b0100;
        else if(req[3] == 1'b1)
            curr_winner = 4'b1000;        
        else if(req[0] == 1'b1)
            curr_winner = 4'b0001; 
        else if(req[1] == 1'b1)
            curr_winner = 4'b0010;    
        else  
            curr_winner = 4'b0000;    
    end  
    else if(last_winner == 4'b0100)begin 
        if(req[3] == 1'b1)
            curr_winner = 4'b1000; 
        else if(req[0] == 1'b1)
            curr_winner = 4'b0001; 
        else if(req[1] == 1'b1)
            curr_winner = 4'b0010;    
        else if(req[2] == 1'b1)
            curr_winner = 4'b0100; 
        else  
            curr_winner = 4'b0000;    
    end
    else begin 
        if(req[0] == 1'b1)
            curr_winner = 4'b0001; 
        else if(req[1] == 1'b1)
            curr_winner = 4'b0010;    
        else if(req[2] == 1'b1)
            curr_winner = 4'b0100; 
        else if(req[3] == 1'b1)
            curr_winner = 4'b1000; 
        else  
            curr_winner = 4'b0000;    
    end     
end 

// 1: Fixed Priority
parameter NUM = 4;
function [NUM-1:0] priority_sel;
     input    [NUM-1:0] request;
     begin
          casex (request)
          4'bxxx1: priority_sel = 4'h1;
          4'bxx10: priority_sel = 4'h2;
          4'bx100: priority_sel = 4'h4;
          4'b1000: priority_sel = 4'h8;
          default: priority_sel = 4'h0;
          endcase
     end
endfunction

assign sel = arbiter_type ? priority_sel(req) : curr_winner;

endmodule