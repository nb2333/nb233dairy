`define size 31
`define full 32'hFFFF_FFFF
`define full1 31'h7FFF_FFFF
module gain21(ina,outdata);
  input [`size:0] ina;
  output [`size:0] outdata;
  
  wire [`size-1:0] a,outdata1;
  assign a = ina[`size-1:0];
  assign outdata1=(a>>13)+(a>>16)+(a>>17)+(a>>18)+(a>>20)+(a>>21)+(a>>22)+(a>>23)+(a>>25)+(a>>28)+(a>>29)+(a>>30)+(a>>31);

  assign outdata = {!ina[`size],outdata1};
  
endmodule

