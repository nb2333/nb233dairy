`define size 31
`define full 32'hFFFF_FFFF
`define full1 31'h7FFF_FFFF
module a4(ina,outdata);
  input [`size:0] ina;
  output [`size:0] outdata;
  
  wire [`size-1:0] a,outdata1;
  assign a = ina[`size-1:0];
  assign outdata1=(a>>1)+(a>>2)+(a>>3)+(a>>6)+(a>>7)+(a>>8)+(a>>11)+(a>>14)+(a>>16)+(a>>17)+(a>>18)+(a>>21)+(a>>22)+(a>>23)+(a>>24)+(a>>25)+(a>>26)+(a>>27)+(a>>31);
  assign outdata = {ina[`size],outdata1};
  
endmodule




