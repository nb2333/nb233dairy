`timescale 1ns/1ns

module resonator_test;
  reg clk,rst;
  wire outdata,d2;
  wire [31:0] d,d1;
  reg [31:0] counter;
  initial
  begin
    clk =0;
    rst=0;
    counter =32'd0;
    #100 rst=1;
  end
  
  
  always
  begin
    #1 clk = ~clk;
  end
  
  always@(posedge clk)
  begin
    counter=counter+32'd1;
  end
  
  
  resonator resonator11(clk,outdata,rst,d);
  //resonator1 resonator12(clk,rst,d1);
  //sigmadel adc44(d1,d2,clk,rst);
  integer w_file,w_fil;
  initial 
  w_file = $fopen("dataout2noadc.txt");
  //w_fil  = $fopen("dataoutadc.txt");
  always@(counter)
    begin
      if (counter>32'd000_000_000)
         $fdisplay(w_file,"%d",outdata);
      // $fdisplay(w_fil,"%d",d1);
     
    end
  
endmodule