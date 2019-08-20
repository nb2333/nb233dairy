module resonator(clk,outdata,rst,d);
  input clk,rst;
  output outdata;
  output [31:0] d;
  
  wire outdata;
  
  integer L=9;//the bit we need to shift
  
  wire [31:0] a211,a212;
  assign a211 = 32'b00000000000010011101111010011110;
  assign a212 = 32'b10000000000010011101111010011110; 
 
 
 
 
  wire [31:0] a;
  
  mux2_1 mux1(a211,a212,outdata,a);
  
  wire [31:0] b;
  
  integrator nodelayin1(a,b,clk,rst);
  
  wire [31:0] c;
  
  assign c = {b[31],(b[30:0]>>L)};
  
  wire [31:0] d;
  
  delayintegrator1 nodelayin2(c,d,clk,rst);
  
  sigmadel sig1(d,outdata,clk,rst); 
  
endmodule
   
