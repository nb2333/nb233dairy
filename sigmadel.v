module sigmadel(indata,outdata,clk,rst);

  input [31:0] indata;
  input clk,rst;
  output outdata;
  
  reg outdata;
  
  wire [31:0] k,k1;
  
  wire [31:0] a;
  b1_c1 b1_c11(indata,k);
  c1 c11(outdata,k1);
  adder adder15(k,k1,a);
  
  
 
  
  wire [31:0] b;
  delayintegrator delayin1(a,b,clk,rst);
  
  wire [31:0] c,d;
  c2 c21(b,c);
  delayintegrator delayin2(c,d,clk,rst);
  
  wire [31:0] e,f;
  c3 c31(d,e);
  delayintegrator delayin3(e,f,clk,rst);
  
  wire [31:0] g,h;
  c4 c41(f,g);
  delayintegrator delayin4(g,h,clk,rst);
  
  wire [31:0] j1,j2,j3,j4,j5;
  assign j1 = indata;
  a4 a41(h,j2);
  a1 a11(b,j3);
  a2 a21(d,j4);
  a3 a31(f,j5);
  
  wire [31:0] sum1,s1,s2,s3;
  adder adder11(j1,j2,s1);
  adder adder12(s1,j3,s2);
  adder adder13(s2,j4,s3);
  adder adder14(s3,j5,sum1);
 
  
  always@(sum1 or rst)
    begin
      if(!rst)
          outdata=1;
      else
       begin
         outdata=sum1[31];
       end
    end
  
  
  
  
endmodule

 
