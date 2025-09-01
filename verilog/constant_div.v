//authored by ZhangGuorui

module constant_div #(
    parameter DIV_MODE  = 0  , //0: the constant is send by parameter; 1 : the constant is send by input multi quan
    parameter DIV       = 38 ,
    parameter DIV_END_W = 16 ,
    parameter RES_W     = $clog2({DIV_END_W{1'b1}}/DIV) ,
    parameter END_OF_LIST = 1
)
(
    input  logic [DIV_END_W  -1:0] i_div_end    ,
    input  logic [DIV_END_W  -1:0] i_multi_quan ,
    output logic [RES_W      -1:0] o_res     
);

genvar i;

localparam QUAN = {{1'b1},{DIV_END_W{1'b1}}/DIV ;

logic [DIV_END_W   -1:0] multi_quan ;

generate
if (DIV_MODE == 0 ) begin : GEN_MOD_PAR
    assign multi_quan = QUAN         ;
end
else begin : GEN_MOD_IN
    assign multi_quan = i_multi_quan ;
end
endgenerate

//-------------------------------------------------//
localparam TAIL_W     =  $clog2(DIV_END_W)  ;
localparam TAIL_SUM_W =  2*TAIL_W           ;

logic [RES_W       -1:0] div_end_quan_vec     [DIV_END_W   -1:0] ;
logic [TAIL_W      -1:0] div_end_quan_dec_vec [DIV_END_W   -1:0] ;

generate
for(i=0;i<DIV_END_W;i=i+1) begin : GEN_QUAN
    logic [RES_W       -1:0] div_end_quan_vec_pre ;
    logic [TAIL_W      -1:0] div_end_quan__dec_vec_pre ;
    assign div_end_quan_vec_pre     = i_div_end >> (DIV_END_W -1 -i)                ;

    if (i<TAIL_W)  begin  : GEN_I_STW
        assign div_end_quan_dec_vec_pre =  i_div_end [i:0] << (TAIL_W -1 -i) ;
    end
    else begin : GEN_I_LTW
        assign div_end_quan_dec_vec_pre =  i_div_end [i -: TAIL_W] ;
    end
        

    assign div_end_quan_vec     [i] = {RES_W { multi_quan [i]}} & div_end_quan_vec_pre      ;
    assign div_end_quan_dec_vec [i] = {TAIL_W{ multi_quan [i]}} & div_end_quan_dec_vec_pre  ;
end
endgenerate


logic [RES_W       -1:0] num_sum ;
logic [TAIL_SUM_W  -1:0] dec_sum_pre ;

always_comb begin
    integer i0;
    num_sum     = 'b0 ;
    dec_sum_pre = 'b0 ;
    for(i0=0;i0<DIV_END_W;i0=i0+1) begin
        num_sum     = num_sum     + div_end_quan_vec     [i0] ;
        dec_sum_pre = dec_sum_pre + div_end_quan_dec_vec [i0] ;
    end
end

logic [TAIL_W   -1:0] dec_sum ;

assign dec_sum = dec_sum_pre [TAIL_SUM_W -1:TAIL_W] ;

assign o_res = dec_sum + num_sum ;

endmodule



