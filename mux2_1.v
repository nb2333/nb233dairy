module mux2_1(in1,in2,sel,out);
input [31:0] in1,in2;
input sel;
output [31:0] out;
reg [31:0] out;

always@(in1 or in2 or sel)
begin
if (sel)
  out = in1;
else 
  out = in2;
end
endmodule 
