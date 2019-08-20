`define size 31
`define full 32'hFFFF_FFFF
module delayintegrator1(inp,outp,clk,rst); 
     input [`size:0]inp; 
     input clk,rst; 
     output [`size:0]outp; 
     wire [`size:0]w1;
     reg [`size:0] outp; 
     
     adder add1(inp,outp,w1); 
 
     always@(posedge clk or posedge rst)
     begin
       if (!rst)
         outp = 32'h4001_0000;
       else
         outp  = w1;
      end
endmodule 


