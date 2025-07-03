module round_robin_s2m (
    input        clk    ,
    input        rst_n  ,
 
    input  [3:0] req    ,
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
   
assign sel = curr_winner;  

endmodule