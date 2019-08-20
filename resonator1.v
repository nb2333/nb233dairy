module resonator1(clk,rst,d);
  input clk,rst;
  output [31:0] d;
  
  wire outdata;
  
  integer L=8;//the bit we need to shift
 
 
  
  wire [31:0] a,b;
  
  gain21 gaina211(d,a);
  
  
  nodelayintegrator1 nodelayin1(a,b,clk,rst);
  
  wire [31:0] c;
  
  assign c = {b[31],((b[30:0])>>L)};  
  wire [31:0] d;
  
  delayintegrator1 nodelayin2(c,d,clk,rst);
   
  
endmodule
   
