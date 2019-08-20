`define size 31
`define full 32'hFFFF_FFFF
`define full1 31'h7FFF_FFFF
module a3(ina,outdata);
  input  [`size:0] ina;
  output [`size:0] outdata;
  wire [`size-1:0] a;
  wire [`size:0] outdata1;
  assign a = ina[`size-1:0];
  assign outdata1=(a)+(a>>1)+(a>>6)+(a>>7)+(a>>9)+(a>>10)+(a>>12)+(a>>13)+(a>>15)+(a>>16)+(a>>18)+(a>>22)+(a>>23)+(a>>24)+(a>>25)+(a>>28)+(a>>29)+(a>>30)+(a>>31)+(a>>32);
  assign outdata = (outdata1[`size])?({ina[`size],`full1}):({ina[`size],outdata1[`size-1:0]}); 
  
endmodule
