//authored by ZhangGuorui
//zgrhit@hotmail.com
//2024.6.10

module wallace #
(
    parameter LEVEL       = 0  ,
    parameter DI_W        = 16 ,
    parameter DO_W        = 16 ,
    parameter D_N         = 28 ,


    parameter END_OF_LIST = 1 
)
(
    input  logic [D_N*DI_W  -1:0] i_add_i ,

    output logic [DO_W      -1:0] o_sum   ,
    output logic [DO_W      -1:0] o_carry 
);

genvar i,j;

generate
if (D_N == 1) begin : GEN_DN_1
    assign o_sum   = i_add_i ;
    assign o_carry = 'b0     ;
end
else if  (D_N == 2) begin : GEN_DN_2 
    assign o_sum   = i_add_i [0*DI_W  +: DI_W] ;
    assign o_carry = i_add_i [1*DI_W  +: DI_W] ;
end
else if (DN  == 3 ) begin ; GEN_DN_3
    logic [DI_W   -1:0] sum_tmp ;
    logic [DI_W   -1:0] carry_tmp ;

    unit3_2_compress #
    (
        .DI_W        (DI_W),
        .D_N         (D_N ),
        .DO_N        (GRP_N),
        .END_OF_LIST (1) 
    )
    U_PRESS (
        .i_add_i    (i_add_i  ),
        .o_sum      (sum_tmp  ),
        .o_carry    (carry_tmp),
    );

    assign o_sum   = sum_tmp ;
    assign o_carry = {carry_tmp,{1'b0}} ;


end
else begin : GEN_TREE_COMPRESS0
    localparam NXT_LEVEL = LEVEL + 1 ;
   
    localparam NXT_DW    = DI_W +1 > DO_W ? DO_W : DI_W + 1 ;

    localparam GRP_N = D_N/3 ;
    localparam MOD_N = D_N%3 ;  
    
    localparam NXT_DN = GRP_N*2 + MOD_N; 

    logic [DI_W*GRP_N  -1:0] sum_tmp   ;
    logic [DI_W*GRP_N  -1:0] carry_tmp ; 

    unit3_2_compress #
    (
        .DI_W        (DI_W    ),
        .D_N         (GRP_N*3 ),
        .DO_N        (GRP_N   ),
        .END_OF_LIST (1) 
    )
    U_PRESS (
        .i_add_i    (i_add_i [GRP_N*3*DI_W  -1:0] ),
        .o_sum      (sum_tmp                      ),
        .o_carry    (carry_tmp                    ),
    );

    
    logic [NXT_DW*NXT_DN  -1:0] nxt_add_i ;

    for (i=0;i<NXT_DN;i=i+1) begin : GEN_NEXT_ADDI
        if (i< MOD_N ) begin : GEN_MODE
            assign nxt_add_i [i*NXT_DW +: NXT_DW] = i_add_i[(GRP_N*3 + i)*DI_W +: DI_W] ;
        end
        else if (i<MOD_N + GRP_N) : GEN_SUM
            assign nxt_add_i [i*NXT_DW +: NXT_DW] = sum_tmp[(MOD_N +i)*DI_W +: DI_W] ;
        end
        else begin : GEN_CARRY
            assign nxt_add_i [i*NXT_DW +: NXT_DW] = {carry_tmp [(MOD_N + i + GRP_N)*DI_W +: DI_W],{1'b0}} ;
        end 
    end

    wallace #(
        .LEVEL ( NXT_LEVEL  ),       
        .DI_W  ( NXT_DW     ),   
        .DO_W  ( DO_W       ),   
        .D_N   ( NXT_DN     ),   
    )   
    U_WALLACE (
        .i_add_i (nxt_add_i),
        .o_sum   (o_sum    ),
        .o_carry (o_carry  )
    );

end


endgenerate

endmodule


//===========================================//
module unit3_2_compress #
(
    parameter DI_W        = 16 ,
    parameter D_N         = 28 ,
    
    parameter DO_N        = DI_N/3,
    parameter END_OF_LIST = 1 
)
(
    input  logic [D_N*DI_W  -1:0] i_add_i ,

    output logic [DI_W*DO_N -1:0] o_sum   ,
    output logic [DI_W*DO_N -1:0] o_carry 
);


generate

for (i=0;i<DI_W;i=i+1) begin : GEN_BIT
    for(j=0;j<GRP_N;j=j+1) begin : GEN_GRP
        assign {o_carry[j*DI_W + i ], o_sum [j*DI_W + i]} =  i_add_i [j*DI_W + i] + i_add_i[(j+1)*DI_W + i] + i_add_i[(j+2)*DI_W + i] ;
    end
end
endgenerate

endmodule












