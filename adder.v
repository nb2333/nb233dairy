`define size 31
`define full 32'hFFFF_FFFF
`define full1 31'h7FFF_FFFF
`define mid  32'h8000_0000
module adder (ina,inb,sum); 
   output[`size:0]sum; 
 
   input [`size:0] ina,inb; 
   wire  [`size:0] ina1,inb1;
   wire  [`size:0] sum1,sum2;
  
  
   assign ina1 = (ina[`size])?(`mid-ina):(ina);
   assign inb1 = (inb[`size])?(`mid-inb):(inb);
   assign sum1 =(ina1+inb1);
   assign sum2 = (sum1[`size])?(`mid-sum1):(sum1);
   assign sum  =((ina[`size]==inb[`size])&&((sum1[`size]&(!ina[`size])|(ina[`size]&(!sum2[`size])))))?({ina[`size],`full1}):(sum2);  
    
endmodule 
