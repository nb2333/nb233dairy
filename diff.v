module diff ( d,q, clk, rst); 
output [31:0]q; 
input [31:0]d; 
input rst,clk; 
reg [31:0]q; 

always @(posedge clk) 
    if(rst==0) 
         q<=0; 
    else                                          
      q<=d; 
endmodule 
