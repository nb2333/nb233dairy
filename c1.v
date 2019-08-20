`define size 31
`define full 32'hFFFF_FFFF
`define full1 31'h7FFF_FFFF
`define mid  32'h8000_0000
module c1(ina,outdata);
  input   ina;
  output [`size:0] outdata;
  
  wire [`size:0] a,outdata1;
  assign a = `full1;
  assign outdata1=(a>>2)+(a>>4)+(a>>5)+(a>>7)+(a>>9)+(a>>13)+(a>>15)+(a>>18)+(a>>19)+(a>>20)+(a>>22)+(a>>24)+(a>>25)+(a>>27)+(a>>28)+(a>>32);
  assign outdata = {!ina,outdata1[`size-1:0]};
  
endmodule






