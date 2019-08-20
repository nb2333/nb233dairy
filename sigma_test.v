`timescale 1ns/1ns
module sigma_test;
  reg clk,rst;
  reg [31:0] a,b,counter;
  wire  out1,out2;
  
   initial
  begin
    clk=0;
    counter=32'd0;
    a=32'h0000_0003;
  
    rst=0;
    #10 rst=1;
    
  end
    
  always
  begin
    #1 clk=~clk;
  end  

sigmadel sigg1(a,out1,clk,rst);
  
  
  always@(posedge clk)
  begin
    counter=counter+32'd1;
  end
  
  
  integer w_file;
  initial 
  w_file = $fopen("dataout1.txt");
  
  always@(counter)
    begin
      if (counter>32'd000_000_000)
          $fdisplay(w_file,"%b",out1);
     
    end
  
  
endmodule