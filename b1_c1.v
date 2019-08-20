`define size 31
`define full 32'hFFFF_FFFF
`define full1 31'h7FFF_FFFF
module b1_c1(ina,outdata);
  input [`size:0] ina;
  output [`size:0] outdata;
  
  wire [`size-1:0] a,outdata1;
  assign a = ina[`size-1:0];
  assign outdata1=(a>>2)+(a>>4)+(a>>5)+(a>>7)+(a>>9)+(a>>13)+(a>>15)+(a>>18)+(a>>19)+(a>>20)+(a>>22)+(a>>24)+(a>>25)+(a>>27)+(a>>28)+(a>>32);
  assign outdata = {ina[`size],outdata1};
  
endmodule




