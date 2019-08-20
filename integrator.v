`define size 31
`define full 32'hFFFF_FFFF
module integrator(inp,outp,clk,rst); 
     input [`size:0]inp; 
     input clk,rst; 
     output [`size:0]outp; 
     wire [`size:0]w1; 
     
     adder add1(inp,w1,outp); 
     
     diff diff1(outp,w1,clk,rst); 
     
endmodule 
