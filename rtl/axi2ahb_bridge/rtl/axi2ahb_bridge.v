module axi2ahb_bridge(
    input  wire          clk        ,   
    input  wire          rst_n      , 

    input  wire [7 :0]   axi_arid   ,     
    input  wire [31:0]   axi_araddr ,   
    input  wire [7 :0]   axi_arlen  ,    
    input  wire [2 :0]   axi_arsize ,   
    input  wire [1 :0]   axi_arburst,   
    input  wire          axi_arvalid,  
    output wire          axi_arready,  

    output reg  [7:0]    axi_rid    ,       
    output reg  [31:0]   axi_rdata  ,     
    output reg  [1:0]    axi_rresp  ,     
    output reg           axi_rlast  ,     
    output reg           axi_rvalid ,    
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

    output reg [7:0]     axi_bid    ,       
    output reg  [1:0]    axi_bresp  ,     
    output reg           axi_bvalid , 
    input  wire          axi_bready ,   

    input  wire          ahb_hgrant ,    
    output wire          ahb_hbusreq,   
    output reg  [31:0]   ahb_haddr  ,     
    output reg  [1 :0]   ahb_htrans ,  
    output reg           ahb_hwrite ,
    output reg  [2:0]    ahb_hsize  ,     
    output reg  [2:0]    ahb_hburst ,
    output reg  [31:0]   ahb_hwdata , 
    input  wire [31:0]   ahb_hrdata ,  
    input  wire          ahb_hready ,    
    input  wire [1:0]    ahb_hresp  

);

wire    axi_rvalid_01, axi_rvalid_10, axi_rvalid_11;
wire    axi_rready_01, axi_rready_10, axi_rready_11;

reg     axi_awvalid_01, axi_awvalid_10, axi_awvalid_11;
wire    axi_awready_01, axi_awready_10, axi_awready_11;
always @(*) begin
    if(!rst_n) begin
        axi_awvalid_01 = 0;
        axi_awvalid_10 = 0;
        axi_awvalid_11 = 0;
    end
    else begin
        if (axi_awvalid) begin
            if(axi_awid[1:0] == 2'b01) begin
                axi_awvalid_01 = 1;
                axi_awvalid_10 = 0;
                axi_awvalid_11 = 0;
            end
            else if (axi_awid[1:0] == 2'b10) begin
                axi_awvalid_01 = 0;
                axi_awvalid_10 = 1;
                axi_awvalid_11 = 0;
            end
            else if (axi_awid[1:0] == 2'b11) begin
                axi_awvalid_01 = 0;
                axi_awvalid_10 = 0;
                axi_awvalid_11 = 1;
            end
            else begin
                axi_awvalid_01 = 0;
                axi_awvalid_10 = 0;
                axi_awvalid_11 = 0;
            end
        end
        else begin
            axi_awvalid_01 = 0;
            axi_awvalid_10 = 0;
            axi_awvalid_11 = 0;
        end
    end
end
assign axi_awready = axi_awready_01 | axi_awready_10 | axi_awready_11;

reg     axi_wvalid_01, axi_wvalid_10, axi_wvalid_11;
wire    axi_wready_01, axi_wready_10, axi_wready_11;
always @(*) begin
    if(!rst_n) begin
        axi_wvalid_01 = 0;
        axi_wvalid_10 = 0;
        axi_wvalid_11 = 0;
    end
    else begin
        if (axi_wvalid) begin
            if(axi_wid[1:0] == 2'b01) begin
                axi_wvalid_01 = 1;
                axi_wvalid_10 = 0;
                axi_wvalid_11 = 0;
            end
            else if (axi_wid[1:0] == 2'b10) begin
                axi_wvalid_01 = 0;
                axi_wvalid_10 = 1;
                axi_wvalid_11 = 0;
            end
            else if (axi_wid[1:0] == 2'b11) begin
                axi_wvalid_01 = 0;
                axi_wvalid_10 = 0;
                axi_wvalid_11 = 1;
            end
            else begin
                axi_wvalid_01 = 0;
                axi_wvalid_10 = 0;
                axi_wvalid_11 = 0;
            end
        end
        else begin
            axi_wvalid_01 = 0;
            axi_wvalid_10 = 0;
            axi_wvalid_11 = 0;
        end
    end
end
assign axi_wready = axi_wready_01 | axi_wready_10 | axi_wready_11;

wire        hbusreq_01, hbusreq_10, hbusreq_11;
wire [31:0]   haddr_01,   haddr_10,   haddr_11;
wire [1 :0]  htrans_01,  htrans_10,  htrans_11;
wire         hwrite_01,  hwrite_10,  hwrite_11;
wire [2:0]    hsize_01,   hsize_10,   hsize_11;
wire [2:0]   hburst_01,  hburst_10,  hburst_11;
wire [31:0]  hwdata_01,  hwdata_10,  hwdata_11;

wire buf2ahb_en_01, buf2ahb_en_10, buf2ahb_en_11;
wire ahb2buf_en_01, ahb2buf_en_10, ahb2buf_en_11;
reg  ahb_hready_01, ahb_hready_10, ahb_hready_11;

reg ahb2buf_en_01_reg, ahb2buf_en_10_reg, ahb2buf_en_11_reg;
reg buf2ahb_en_01_reg, buf2ahb_en_10_reg, buf2ahb_en_11_reg;

wire [7:0] axi_bid_01   , axi_bid_10   , axi_bid_11   ;
wire [1:0] axi_bresp_01 , axi_bresp_10 , axi_bresp_11 ;
wire       axi_bvalid_01, axi_bvalid_10, axi_bvalid_11;

axi2ahb u_axi2ahb_ID01(
.clk        (clk  ),   
.rst_n      (rst_n),     

.axi_arid   (axi_arid   ), //input       
.axi_araddr (axi_araddr ), //input     
.axi_arlen  (axi_arlen  ), //input      
.axi_arsize (axi_arsize ), //input     
.axi_arburst(axi_arburst), //input    
.axi_arvalid(axi_arvalid), //input   
.axi_arready(axi_arready), //output    
.axi_rid    (axi_rid    ), //output       
.axi_rdata  (axi_rdata  ), //output     
.axi_rresp  (axi_rresp  ), //output     
.axi_rlast  (axi_rlast  ), //output     
.axi_rvalid (axi_rvalid ), //output    
.axi_rready (axi_rready ), //input 

.axi_awid   (axi_awid   ), //input       
.axi_awaddr (axi_awaddr ), //input     
.axi_awlen  (axi_awlen  ), //input      
.axi_awsize (axi_awsize ), //input     
.axi_awburst(axi_awburst), //input    
.axi_awvalid(axi_awvalid_01), //input    
.axi_awready(axi_awready_01), //output  
.axi_wid    (axi_wid    ), //input        
.axi_wdata  (axi_wdata  ), //input      
.axi_wlast  (axi_wlast  ), //input      
.axi_wstrb  (axi_wstrb  ), //input      
.axi_wvalid (axi_wvalid_01 ), //input   
.axi_wready (axi_wready_01 ), //output
.axi_bid    (axi_bid_01    ), //output       
.axi_bresp  (axi_bresp_01  ), //output     
.axi_bvalid (axi_bvalid_01 ), //output 
.axi_bready (axi_bready    ), //input    

.ahb_hgrant (ahb_hgrant), //input     
.ahb_hbusreq(hbusreq_01), //output   
.ahb_haddr  (haddr_01  ), //output     
.ahb_htrans (htrans_01 ), //output  
.ahb_hwrite (hwrite_01 ), //output
.ahb_hsize  (hsize_01  ), //output     
.ahb_hburst (hburst_01 ), //output
.ahb_hwdata (hwdata_01 ), //output 
.ahb_hrdata (ahb_hrdata), //input   
.ahb_hready (ahb_hready), //input     
// .ahb_hready (ahb_hready_01), //input     
.ahb_hresp  (ahb_hresp ), //input 

.ahb2buf_en (ahb2buf_en_01),
.buf2ahb_en (buf2ahb_en_01)
);

axi2ahb u_axi2ahb_ID10(
.clk        (clk  ),   
.rst_n      (rst_n),     

.axi_arid   (/*not used*/),      
.axi_araddr (/*not used*/),    
.axi_arlen  (/*not used*/),     
.axi_arsize (/*not used*/),    
.axi_arburst(/*not used*/),   
.axi_arvalid(/*not used*/),  
.axi_arready(/*not used*/),    
.axi_rid    (/*not used*/),       
.axi_rdata  (/*not used*/),     
.axi_rresp  (/*not used*/),     
.axi_rlast  (/*not used*/),     
.axi_rvalid (/*not used*/),    
.axi_rready (/*not used*/),

.axi_awid   (axi_awid   ), //input       
.axi_awaddr (axi_awaddr ), //input     
.axi_awlen  (axi_awlen  ), //input      
.axi_awsize (axi_awsize ), //input     
.axi_awburst(axi_awburst), //input    
.axi_awvalid(axi_awvalid_10), //input    
.axi_awready(axi_awready_10), //output  
.axi_wid    (axi_wid    ), //input        
.axi_wdata  (axi_wdata  ), //input      
.axi_wlast  (axi_wlast  ), //input      
.axi_wstrb  (axi_wstrb  ), //input      
.axi_wvalid (axi_wvalid_10), //input   
.axi_wready (axi_wready_10), //output
.axi_bid    (axi_bid_10    ), //output      
.axi_bresp  (axi_bresp_10  ), //output    
.axi_bvalid (axi_bvalid_10 ), //output
.axi_bready (axi_bready    ), //input 

.ahb_hgrant (ahb_hgrant), //input     
.ahb_hbusreq(hbusreq_10), //output   
.ahb_haddr  (  haddr_10), //output     
.ahb_htrans ( htrans_10), //output  
.ahb_hwrite ( hwrite_10), //output
.ahb_hsize  (  hsize_10), //output     
.ahb_hburst ( hburst_10), //output
.ahb_hwdata ( hwdata_10), //output 
.ahb_hrdata (/*not used*/),    
// .ahb_hready (ahb_hready_10), //input     
.ahb_hready (ahb_hready), //input     
.ahb_hresp  (ahb_hresp ), //input 

.ahb2buf_en (ahb2buf_en_10),
.buf2ahb_en (buf2ahb_en_10)
);

axi2ahb u_axi2ahb_ID11(
.clk        (clk  ),   
.rst_n      (rst_n),     

.axi_arid   (/*not used*/),      
.axi_araddr (/*not used*/),    
.axi_arlen  (/*not used*/),     
.axi_arsize (/*not used*/),    
.axi_arburst(/*not used*/),   
.axi_arvalid(/*not used*/),  
.axi_arready(/*not used*/),    
.axi_rid    (/*not used*/),       
.axi_rdata  (/*not used*/),     
.axi_rresp  (/*not used*/),     
.axi_rlast  (/*not used*/),     
.axi_rvalid (/*not used*/),    
.axi_rready (/*not used*/),

.axi_awid   (axi_awid   ), //input       
.axi_awaddr (axi_awaddr ), //input     
.axi_awlen  (axi_awlen  ), //input      
.axi_awsize (axi_awsize ), //input     
.axi_awburst(axi_awburst), //input    
.axi_awvalid(axi_awvalid_11), //input    
.axi_awready(axi_awready_11), //output  
.axi_wid    (axi_wid    ), //input        
.axi_wdata  (axi_wdata  ), //input      
.axi_wlast  (axi_wlast  ), //input      
.axi_wstrb  (axi_wstrb  ), //input      
.axi_wvalid (axi_wvalid_11), //input   
.axi_wready (axi_wready_11), //output
.axi_bid    (axi_bid_11    ), //output      
.axi_bresp  (axi_bresp_11  ), //output    
.axi_bvalid (axi_bvalid_11 ), //output
.axi_bready (axi_bready    ), //input 

.ahb_hgrant (ahb_hgrant), //input     
.ahb_hbusreq(hbusreq_11), //output   
.ahb_haddr  (  haddr_11), //output     
.ahb_htrans ( htrans_11), //output  
.ahb_hwrite ( hwrite_11), //output
.ahb_hsize  (  hsize_11), //output     
.ahb_hburst ( hburst_11), //output
.ahb_hwdata ( hwdata_11), //output 
.ahb_hrdata (/*not used*/),    
.ahb_hready (ahb_hready), //input     
// .ahb_hready (ahb_hready_11), //input     
.ahb_hresp  (ahb_hresp ), //input 

.ahb2buf_en (ahb2buf_en_11),
.buf2ahb_en (buf2ahb_en_11)
);

assign ahb_hbusreq = hbusreq_01 | hbusreq_10 | hbusreq_11;

always @(posedge clk) begin
    if (!rst_n) begin
        ahb2buf_en_01_reg <= 0;
        ahb2buf_en_10_reg <= 0;
        ahb2buf_en_11_reg <= 0;
        buf2ahb_en_01_reg <= 0;
        buf2ahb_en_10_reg <= 0;
        buf2ahb_en_11_reg <= 0;
    end
    else begin
        ahb2buf_en_01_reg <= ahb2buf_en_01;
        ahb2buf_en_10_reg <= ahb2buf_en_10;
        ahb2buf_en_11_reg <= ahb2buf_en_11;
        buf2ahb_en_01_reg <= buf2ahb_en_01;
        buf2ahb_en_10_reg <= buf2ahb_en_10;
        buf2ahb_en_11_reg <= buf2ahb_en_11;
    end
end

always @(*) begin
    if (!rst_n) begin
          ahb_haddr = 0;
         ahb_htrans = 0;
         ahb_hwrite = 0;
          ahb_hsize = 0;
         ahb_hburst = 0;
        //  ahb_hwdata = 0;
    end else begin
        if (ahb2buf_en_01 || buf2ahb_en_01) begin
              ahb_haddr =   haddr_01;
             ahb_htrans =  htrans_01;
             ahb_hwrite =  hwrite_01;
              ahb_hsize =   hsize_01;
             ahb_hburst =  hburst_01;
            //  ahb_hwdata =  hwdata_01;

            //  ahb_hready_01 = ahb_hready;
            //  ahb_hready_10 = 0;
            //  ahb_hready_11 = 0;
        end
        else if (ahb2buf_en_10 || buf2ahb_en_10) begin
              ahb_haddr =   haddr_10;
             ahb_htrans =  htrans_10;
             ahb_hwrite =  hwrite_10;
              ahb_hsize =   hsize_10;
             ahb_hburst =  hburst_10;
            //  ahb_hwdata =  hwdata_10;

             ahb_hready_01 = 0;
             ahb_hready_10 = ahb_hready;
             ahb_hready_11 = 0;
        end
        else if (ahb2buf_en_11 || buf2ahb_en_11) begin
              ahb_haddr =   haddr_11;
             ahb_htrans =  htrans_11;
             ahb_hwrite =  hwrite_11;
              ahb_hsize =   hsize_11;
             ahb_hburst =  hburst_11;
            //  ahb_hwdata =  hwdata_11;

            //  ahb_hready_01 = 0;
            //  ahb_hready_10 = 0;
            //  ahb_hready_11 = ahb_hready;
        end
        else begin
              ahb_haddr = 0;
             ahb_htrans = 0;
             ahb_hwrite = 0;
              ahb_hsize = 0;
             ahb_hburst = 0;
        end
    end
end

always @(*) begin
    if (!rst_n) begin
         ahb_hwdata = 0;
    end else begin
        if (ahb2buf_en_01_reg || buf2ahb_en_01_reg) begin
             ahb_hwdata =  hwdata_01;

            //  ahb_hready_01 = ahb_hready;
            //  ahb_hready_10 = 0;
            //  ahb_hready_11 = 0;
        end
        else if (ahb2buf_en_10_reg || buf2ahb_en_10_reg) begin
             ahb_hwdata =  hwdata_10;

            //  ahb_hready_01 = 0;
            //  ahb_hready_10 = ahb_hready;
            //  ahb_hready_11 = 0;
        end
        else if (ahb2buf_en_11_reg || buf2ahb_en_11_reg) begin
             ahb_hwdata =  hwdata_11;

            //  ahb_hready_01 = 0;
            //  ahb_hready_10 = 0;
            //  ahb_hready_11 = ahb_hready;
        end
    end
end

always @(*) begin
    if (axi_bvalid_01) begin
        axi_bid    = axi_bid_01   ;
        axi_bresp  = axi_bresp_01 ;
        axi_bvalid = axi_bvalid_01;
    end
    else if (axi_bvalid_10) begin
        axi_bid    = axi_bid_10   ;
        axi_bresp  = axi_bresp_10 ;
        axi_bvalid = axi_bvalid_10;
    end
    else if (axi_bvalid_11) begin
        axi_bid    = axi_bid_11   ;
        axi_bresp  = axi_bresp_11 ;
        axi_bvalid = axi_bvalid_11;
    end
    else begin
        axi_bid    = 0;
        axi_bresp  = 0;
        axi_bvalid = 0;
    end
end

endmodule
