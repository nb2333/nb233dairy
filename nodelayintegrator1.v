`define size 31
`define full 32'hFFFF_FFFF
module nodelayintegrator1(inp,outp,clk,rst); 
     input [`size:0]inp; 
     input clk,rst; 
     output [`size:0]outp; 
     reg [`size:0]w1; 
     
     adder add1(inp,w1,outp); 
     
     always@(posedge clk or posedge rst)
     begin
       if (!rst)
         w1 = 32'h0000_0000;
       else
         w1 =outp;
      end
     
endmodule 

