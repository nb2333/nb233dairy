`define size 31
`define full 32'hFFFF_FFFF
`define full1 31'h7FFF_FFFF
module c3(ina,outdata);
  input [`size:0] ina;
  output [`size:0] outdata;
  
  wire [`size-1:0] a,outdata1;
  assign a = ina[`size-1:0];
  assign outdata1=(a>>2)+(a>>5)+(a>>6)+(a>>7)+(a>>14)+(a>>15)+(a>>16)+(a>>19)+(a>>21)+(a>>23)+(a>>24)+(a>>25)+(a>>27)+(a>>28)+(a>>29)+(a>>30)+(a>>31)+(a>>32);
  assign outdata = {ina[`size],outdata1};
  
endmodule


