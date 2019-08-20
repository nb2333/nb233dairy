`define size 31
`define full 32'hFFFF_FFFF
module delayintegrator(inp,outp,clk,rst); 
     input [`size:0]inp; 
     input clk,rst; 
     output [`size:0]outp; 
     wire [`size:0]w1; 
     
     adder add1(inp,outp,w1); 
     
     diff diff1(w1,outp,clk,rst); 
     
endmodule 

