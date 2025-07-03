module round_robin_m2s (
    input        clk    ,
    input        rst_n  ,
 
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
   
assign sel = curr_winner;  

endmodule