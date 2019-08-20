`define size 31
`define full 32'hFFFF_FFFF
`define full1 31'hFFFF_FFFF
module a1(ina,outdata);
  input  [`size:0] ina;
  output [`size:0] outdata;
  wire [`size-1:0] a;
  wire [`size:0] outdata1;
  assign a = ina[`size-1:0];
  assign outdata1=(a<<1)+(a>>2)+(a>>6)+(a>>7)+(a>>8)+(a>>12)+(a>>17)+(a>>19)+(a>>20)+(a>>22)+(a>>23)+(a>>24)+(a>>26)+(a>>27)+(a>>28)+(a>>31);
  assign outdata = (outdata1[`size])?({ina[`size],`full1}):({ina[`size],outdata1[`size-1:0]}); 
  
endmodule
  
  
