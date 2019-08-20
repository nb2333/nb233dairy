`define size 31
`define full 32'hFFFF_FFFF
`define full1 31'h7FFF_FFFF
module a2(ina,outdata);
  input  [`size:0] ina;
  output [`size:0] outdata;
  wire [`size-1:0] a;
  wire [`size:0] outdata1;
  assign a = ina[`size-1:0];
  assign outdata1=(a<<1)+(a>>3)+(a>>4)+(a>>5)+(a>>13)+(a>>14)+(a>>15)+(a>>20)+(a>>21)+(a>>22)+(a>>23)+(a>>24)+(a>>25)+(a>>26)+(a>>28)+(a>>30)+(a>>31);
  assign outdata = (outdata1[`size])?({ina[`size],`full1}):({ina[`size],outdata1[`size-1:0]}); 
  
endmodule






