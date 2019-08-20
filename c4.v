`define size 31
`define full 32'hFFFF_FFFF
`define full1 31'h7FFF_FFFF
module c4(ina,outdata);
  input [`size:0] ina;
  output [`size:0] outdata;
  
  wire [`size-1:0] a,outdata1;
  assign a = ina[`size-1:0];
  assign outdata1=(a>>3)+(a>>5)+(a>>8)+(a>>12)+(a>>15)+(a>>16)+(a>>19)+(a>>20)+(a>>23)+(a>>24);
  assign outdata = {ina[`size],outdata1};
  
endmodule



