//authored by Zhang Guorui

module lqm_ctrl #(
    parameter QUE_N      = 100 ,
    parameter DW         = 20  ,
    
    parameter QM_DEP_N   = 1024  ,
    parameter QM_SUB_DEP = 4     ,
    
    parameter LLIST_MEM_RD_DLY = 3 ,
    parameter LLIST_RD_PIPE = 1 ,   

    parameter DMEM_RD_DLY = 3 ,
    parameter DMEM_RD_PIPE = 1 ,   


    //-------- deprived parameter------------------//
    parameter QM_LL_N   = QM_DEP_N/QM_SUB_DEP ,
    parameter QM_LL_AW  = $clog2(QM_LL_N),
    parameter QM_LL_CW  = $clog2(QM_LL_N +1),
   
    parameter QUE_W     = QUE_N < 2  ?  1 : $clog2(QUE_N)  ,

    parameter QM_SUB_AW = $clog2(QM_SUB_DEP),

    parameter QM_DEP_AW = $clog2(QM_DEP_N),
    parameter QM_DEP_CW = $clog2(QM_DEP_N +1) ,

    parameter END_OF_LIST = 1

)
(
    input  logic                           i_clk,
    input  logic                           i_rst_n ,

    //------------------ enq --------------------------//
    input  logic                           i_que_enq_vld_pre ,
    input  logic  [QUE_W             -1:0] i_que_enq_qid_pre ,

    input  logic                           i_que_enq_vld  ,
    input  logic  [QUE_W             -1:0] i_que_enq_qid  ,
    input  logic  [DW                -1:0] i_que_enq_data ,

    //------------------ deq -------------------------//
    input  logic                           i_que_deq_vld_pre ,
    input  logic  [QUE_W             -1:0] i_que_deq_qid_pre ,

    input  logic                           i_que_deq_vld  ,
    input  logic  [QUE_W             -1:0] i_que_deq_qid  ,

    output logic                           o_que_deq_data_vld ,
    output logic  [DW                -1:0] o_que_deq_data     ,

    //----------------- th ----------------------------//
    input  logic  [QM_LL_CW*QUE_N    -1:0] i_qm_drop_th ,
    input  logic  [QM_DEP_CW*QUE_N   -1:0] i_qm_xoff_th ,

    //---------------- memory access ---------------------//
    
    //---link list memory
    output logic                           o_llmem_wr    , 
    output logic  [QM_LL_AW          -1:0] o_llmem_waddr ,
    output logic  [QM_LL_AW          -1:0] o_llmem_wdata ,

    output logic                           o_llmem_rd    , 
    output logic  [QM_LL_AW          -1:0] o_llmem_raddr ,
    input  logic  [QM_LL_AW          -1:0] i_llmem_rdata ,
    input  logic                           i_llmem_ecc_cerr ,
    input  logic                           i_llmem_ecc_uerr 


    //---------------------------------------------------//
    //---data memory
    output logic                           o_dmem_wr    , 
    output logic  [QM_DEP_AW         -1:0] o_dmem_waddr ,
    output logic  [DW                -1:0] o_dmem_wdata ,

    output logic                           o_dmem_rd    , 
    output logic  [QM_DEP_AW         -1:0] o_dmem_raddr ,
    input  logic  [DW                -1:0] i_dmem_rdata ,
    input  logic                           i_dmem_ecc_cerr ,
    input  logic                           i_dmem_ecc_uerr 





    //---------------- dfx ----------------------------//
    input  logic                           i_mem_init_start ,
    output logic                           o_mem_init_done  


    //---------------- end of port ----------------------------//
);

genvar i;

localparam QM_SUB_DEP_M1 = QM_SUB_DEP - 1 ;

logic                           que_enq_vld_pre     : 
logic  [QUE_W             -1:0] que_enq_qid_pre     : 

logic                           que_enq_vld         : 
logic  [QUE_W             -1:0] que_enq_qid         : 
logic  [DW                -1:0] que_enq_data        : 

//------------------ deq -----------------------//
logic                           que_deq_vld_pre     : 
logic  [QUE_W             -1:0] que_deq_qid_pre     : 

logic                           que_deq_vld         : 
logic  [QUE_W             -1:0] que_deq_qid         : 
logic  [DW                -1:0] que_deq_data        : 

//--------------------------------------------------------//
assign que_enq_vld_pre  =  i_que_enq_vld_pre ; 
assign que_enq_qid_pre  =  i_que_enq_qid_pre ; 

assign que_enq_vld      =  i_que_enq_vld     ; 
assign que_enq_qid      =  i_que_enq_qid     ; 
assign que_enq_data     =  i_que_enq_data    ; 

//---------//
assign que_deq_vld_pre  =  i_que_deq_vld_pre ;
assign que_deq_qid_pre  =  i_que_deq_qid_pre ;

assign que_deq_vld      =  i_que_deq_vld     ;
assign que_deq_qid      =  i_que_deq_qid     ;
assign o_que_deq_data   =  que_deq_data      ;

//==================================================//
logic [QM_DEP_CW   -1:0] enq_que_drop_th ;
logic [QM_DEP_CW   -1:0] enq_que_xoff_th ;

logic [QM_DEP_CW   -1:0] deq_que_xoff_th ;


//---------------------- use que_enq_vld_pre and qid_pre fetch the que status ---------------------------------//
logic [QM_DEP_CW   -1:0]  enq_que_cnt       ; 
logic [QM_LL_CW    -1:0]  enq_que_ll_cnt    ; 
logic                     enq_que_head_rptr ; //use for write through
logic [QM_LL_AW    -1:0]  enq_que_tail      ; 
logic [QM_SUB_AW   -1:0]  enq_que_sub_waddr ; 
logic [QM_SUB_AW   -1:0]  enq_que_sub_raddr ; 
logic                     enq_que_w2r_same  ;

logic [QM_LL_AW    -1:0]  enq_que_fst_head  ; //use for write through 
logic [QM_LL_AW    -1:0]  enq_que_sec_head  ; //use for write through


//-----------------------------------------------//
logic [QM_DEP_CW   -1:0]  enq_que_nxt_cnt       ; 
logic [QM_LL_CW    -1:0]  enq_que_nxt_ll_cnt    ; 
logic                     enq_que_nxt_head_rptr ; 
logic [QM_LL_AW    -1:0]  enq_que_nxt_tail      ; 
logic [QM_SUB_AW   -1:0]  enq_que_nxt_sub_waddr ; 
logic [QM_SUB_AW   -1:0]  enq_que_nxt_sub_raddr ; 
logic                     enq_que_nxt_w2r_same  ;

logic [QM_LL_AW    -1:0]  enq_que_nxt_fst_head  ; 
logic [QM_LL_AW    -1:0]  enq_que_nxt_sec_head  ; 

//-----------------------//
logic [QM_DEP_CW   -1:0]  enq_que_nxtm_cnt       ; 
logic [QM_LL_CW    -1:0]  enq_que_nxtm_ll_cnt    ; 
logic                     enq_que_nxtm_head_rptr ; 
logic [QM_LL_AW    -1:0]  enq_que_nxtm_tail      ; 
logic [QM_SUB_AW   -1:0]  enq_que_nxtm_sub_waddr ; 
logic [QM_SUB_AW   -1:0]  enq_que_nxtm_sub_raddr ; 
logic                     enq_que_nxtm_w2r_same  ;



//----------------------- que deq status -----------------------------------------------------//
logic [QM_DEP_CW   -1:0]  deq_que_cnt       ; 
logic [QM_LL_CW    -1:0]  deq_que_ll_cnt    ; 
logic                     deq_que_head_rptr ; //
logic [QM_LL_AW    -1:0]  deq_que_tail      ; 
logic [QM_SUB_AW   -1:0]  deq_que_sub_waddr ; 
logic [QM_SUB_AW   -1:0]  deq_que_sub_raddr ; 
logic                     deq_que_w2r_same  ;

logic [QM_LL_AW    -1:0]  deq_que_fst_head  ; 
logic [QM_LL_AW    -1:0]  deq_que_sec_head  ; 


logic [QM_DEP_CW   -1:0]  deq_que_nxt_cnt       ; 
logic                     deq_que_nxt_ll_cnt    ; 
logic [QM_LL_AW    -1:0]  deq_que_nxt_head_rptr ; //
logic [QM_LL_AW    -1:0]  deq_que_nxt_tail      ; 
logic [QM_SUB_AW   -1:0]  deq_que_nxt_sub_waddr ; 
logic [QM_SUB_AW   -1:0]  deq_que_nxt_sub_raddr ; 
logic                     deq_que_nxt_w2r_same  ;

logic [QM_LL_AW    -1:0]  deq_que_nxt_fst_head  ; 
logic [QM_LL_AW    -1:0]  deq_que_nxt_sec_head  ; 



//logic [QM_DEP_CW   -1:0]  deq_que_nxtm_cnt       ; 
//logic [QM_LL_CW    -1:0]  deq_que_nxtm_ll_cnt    ; 
//logic [QM_LL_AW    -1:0]  deq_que_nxtm_head_rptr ; //
//logic [QM_LL_AW    -1:0]  deq_que_nxtm_tail      ; 
//logic [QM_SUB_AW   -1:0]  deq_que_nxtm_sub_waddr ; 
//logic [QM_SUB_AW   -1:0]  deq_que_nxtm_sub_raddr ; 
//logic                     deq_que_nxtm_w2r_same  ;

logic [QM_LL_AW    -1:0]  deq_que_nxtm_fst_head  ; 
logic [QM_LL_AW    -1:0]  deq_que_nxtm_sec_head  ; 



//---------------------- free addr ctrl  -------------------------------//
logic                     fam_addr_rdy  ;
logic                     fam_addr_req  ;
logic [QM_LL_AW    -1:0]  fam_alc_addr  ;

logic                     fam_addr_rls_vld  ;
logic [QM_LL_AW    -1:0]  fam_rls_addr  ;


//-----------------------------------------------------------------------//

//======================= enq logic ==========================//

//judge the que full and can be written to qm
logic       enq_que_ll_full_pre1 ;
logic       enq_que_ll_full_pre2 ;
logic       enq_que_ll_full_pre3 ;

logic       enq_que_ll_full;
logic       enq_w2rsame_full ;

//que_link list full
//the pre2 is for recycle the head addr
//the pre3 is for total drop th larger than llink number
logic enq_llist_req_pre ;
assign enq_llist_req_pre = |enq_que_sub_waddr == 1'b0 ;

assign enq_que_ll_full_pre1  = enq_que_ll_cnt > enq_que_drop_th ;
//assign enq_que_ll_full_pre2  = enq_llist_req_pre && enq_que_sub_raddr == 'b0 && (fam_addr_rdy == 'b0 || enq_que_ll_cnt == enq_que_drop_th ) ;
assign enq_que_ll_full_pre2  = enq_que_ll_cnt == enq_que_drop_th  && enq_llist_req_pre  && enq_que_sub_raddr == 'b0 ;
assign enq_que_ll_full_pre3  = enq_que_ll_cnt < enq_que_drop_th   && enq_llist_req_pre  && fam_addr_rdy == 'b0 ;

assign enq_que_ll_full = enq_que_ll_full_pre1 |  enq_que_ll_full_pre2  | enq_que_ll_full_pre3 ; 

assign enq_w2rsame_full = enq_que_w2r_same & (enq_que_sub_waddr == enq_que_sub_raddr) ;

logic enq_que_full  ;

assign enq_que_full = enq_que_ll_full | enq_w2rsame_full ;

logic enq_que_ovf  ;

assign enq_que_ovf = enq_que_full & que_enq_vld ;

//------------------------------------------------------------//
logic enq_que_vld ; //true vld 

assign enq_que_vld = (~enq_que_full) & que_enq_vld ;


//------------- deq_vld ---------------------------//
logic deq_que_vld ;
assign deq_que_vld = (|deq_que_cnt) & que_deq_vld ;


logic edeq_same_qid_vld ;

assign edeq_same_qid_vld = deq_que_vld & (que_enq_qid == que_deq_qid) ;


//---------------------que cnt-----------------------------//
assign enq_que_nxt_cnt = enq_que_cnt + 1'b1 ;



//------------------- enq link list control ----------------//
assign enq_que_nxt_sub_waddr = enq_que_sub_waddr == QM_SUB_DEP_M1 ? 'b0 : enq_que_sub_waddr + 1'b1 ; 

//-------------------- llist_req ----------------------//
logic enq_llist_req ;

//if it's 0, means it need a new addr. when  link list
assign enq_llist_req     =  enq_llist_req_pre & ( enq_que_ll_cnt < enq_que_drop_th );

assign enq_que_nxt_ll_cnt = enq_llist_req ? enq_que_ll_cnt + 1'b1 : enq_que_ll_cnt ;

assign fam_addr_req = enq_llist_req & enq_que_vld ;

//---------- calculate tail addr ------------//
logic [QM_LL_AW  -1:0] enq_new_que_addr ;

//if req from link list, just use new addr. else means its full, recycle the last sub addr;
always_comb begin
    if ( fam_addr_req == 1'b1 ) begin
        enq_new_que_addr = fam_alc_addr ;
    end
    else begin
        enq_new_que_addr = enq_que_head_rptr ? enq_que_sec_head :  enq_que_fst_head ;
    end  
end 

always_comb begin
    if (enq_llist_req_pre == 1'b1) begin
        enq_que_nxt_tail = enq_new_que_addr ; 
    end
    else begin
        enq_que_nxt_tail = enq_que_tail ;  
    end  
end 


logic                    llist_mem_wr    ;
logic [QM_LL_AW   -1:0]  llist_mem_waddr ;
logic [QM_LL_AW   -1:0]  llist_mem_wdata ;


assign llist_mem_wr    = (|enq_que_ll_cnt) & enq_llist_req_pre & enq_que_vld ;
assign llist_mem_waddr = enq_que_tail     ;
assign llist_mem_wdata = enq_new_que_addr ;

//------------enq sub raddr ---------------------//
assign enq_que_nxt_sub_raddr = enq_que_sub_raddr ;

//----------- bypass the lilst head ----------------//
//the deq side update head
logic                  ffw_llist_mem_rd        ;
logic                  ffw_llist_mem_rh_rptr   ; //head ptr
logic [QM_LL_AW  -1:0] ffw_llist_mem_rfst_head ;
logic [QM_LL_AW  -1:0] ffw_llist_mem_rsec_head ;
logic [QUE_W     -1:0] ffw_llist_mem_rqid      ; // use for head write back

//the enq update head when ll cnt <= 1;
logic  enq_que_head_update ;
assign enq_que_head_update    = enq_que_vld & (enq_que_ll_cnt [QM_LL_CW -1:1] == 'b0) ;


//if the que is empty,write the ptr  head, else write another head ;
logic enq_write_fst_head ;
logic enq_write_sec_head ;                                              

assign enq_write_fst_head = enq_llist_req_pre && ( (enq_que_ll_cnt == 'b0  && enq_que_head_rptr == 1'b0 ) || 
                                                   (enq_que_ll_cnt == 1'b1 && enq_que_head_rptr == 1'b1 )  ) ;

assign enq_write_sec_head = enq_llist_req_pre && ( (enq_que_ll_cnt == 'b0  && enq_que_head_rptr == 1'b1 ) || 
                                                   (enq_que_ll_cnt == 1'b1 && enq_que_head_rptr == 1'b0)   );

logic edeq_head_same_qid_vld ;
assign edeq_head_same_qid_vld = ffw_llist_mem_rd & (ffw_llist_mem_rqid == que_enq_qid)  ;

always_comb begin
    if ( enq_write_fst_head == 1'b1 ) begin
        enq_que_nxt_fst_head = fam_alc_addr ;
    end
    else begin
        enq_que_nxt_fst_head = edeq_head_same_qid_vld & ffw_llist_mem_rh_rptr == 1'b0 ? i_llmem_rdata  : enq_que_fst_head ; 
    end
end 

always_comb begin
    if ( enq_write_sec_head == 1'b1 ) begin
        enq_que_nxt_sec_head = fam_alc_addr ;
    end
    else begin
        enq_que_nxt_sec_head = edeq_head_same_qid_vld & ffw_llist_mem_rh_rptr ? i_llmem_rdata : enq_que_sec_head ; 
    end
end 

assign enq_que_nxt_head_rptr = enq_que_head_rptr ;

always_comb begin
    if (enq_que_ll_cnt == enq_que_drop_th && enq_llist_req_pre == 1'b1 ) begin
        enq_que_nxt_w2r_same = 1'b1 ;
    end
    else begin
        enq_que_nxt_w2r_same = enq_que_w2r_same ; 
    end 
end 

//=============================== deq ================================// 
logic  deq_que_update_vld = deq_que_vld & (~ (enq_que_vld & (que_enq_qid == que_deq_qid) ))  ;

assign deq_que_nxt_tail = deq_que_tail ; 
assign deq_que_nxt_sub_waddr = deq_que_sub_waddr ;

//nxt cnt 
assign deq_que_nxt_cnt  = deq_que_cnt - 1'b1 ;

assign deq_que_nxt_sub_raddr = deq_que_sub_raddr == QM_SUB_DEP_M1 ? 'b0 : deq_que_sub_raddr + 1'b1 ;

//===============llist logic ========================//
logic deq_head_rls_vld ;

assign deq_head_rls_vld = deq_que_sub_raddr == QM_SUB_DEP_M1 ;

assign deq_que_nxt_head_rptr = deq_head_rls_vld ? ~deq_que_head_rptr : deq_que_head_rptr ;

logic deq_que_llist_req ;

assign deq_que_llist_req = deq_head_rls_vld == 1'b1 && deq_que_ll_cnt >= 'd2 ;

assign deq_que_nxt_w2r_same = (~deq_head_rls_vld) & deq_que_w2r_same ;


//fam rls 
assign fam_addr_rls_vld = deq_head_rls_vld & deq_que_vld ;
assign fam_rls_addr     = deq_que_head_rptr ? deq_que_sec_head : deq_que_fst_head ;


assign deq_que_nxt_ll_cnt = deq_head_rls_vld ? deq_que_ll_cnt - 1'b1 : deq_que_ll_cnt ;


//---------------------link list rd -----------------------//

logic                  llist_mem_rd    ;
logic [QM_LL_AW  -1:0] llist_mem_raddr ;

logic                  llist_mem_rh_rptr   ; //head ptr
logic [QM_LL_AW  -1:0] llist_mem_rfst_head ;
logic [QM_LL_AW  -1:0] llist_mem_rsec_head ;
logic [QUE_W     -1:0] llist_mem_rqid      ; // use for head write back

logic                  ff_llist_mem_rd        [LLIST_MEM_RD_DLY +1   -1:0];
logic                  ff_llist_mem_rh_rptr   [LLIST_MEM_RD_DLY +1   -1:0]; //head ptr
logic [QM_LL_AW  -1:0] ff_llist_mem_rfst_head [LLIST_MEM_RD_DLY +1   -1:0];
logic [QM_LL_AW  -1:0] ff_llist_mem_rsec_head [LLIST_MEM_RD_DLY +1   -1:0];
logic [QUE_W     -1:0] ff_llist_mem_rqid      [LLIST_MEM_RD_DLY +1   -1:0]; // use for head write back


assign llist_mem_rd    = deq_que_llist_req & deq_que_vld ;

//the last valid head in addr is head
assign llist_mem_raddr = deq_que_head_rptr ?  deq_que_fst_head : deq_que_sec_head ;

//-----------------------------------------------
assign llist_mem_rh_rptr   = deq_que_head_rptr ;
assign llist_mem_rfst_head = deq_que_fst_head  ;
assign llist_mem_rsec_head = deq_que_sec_head  ;
assign llist_mem_rqid      = que_deq_qid       ;

generate
for (i=0;i<LLIST_MEM_RD_DLY + 1 ;i=i+1) begin : GEN_LLIST_RD_FF
    if (i == 0) begin : GEN_I_EQ0
        always_comb begin
            ff_llist_mem_rd        [i] = llist_mem_rd        ; 
            ff_llist_mem_rh_rptr   [i] = llist_mem_rh_rptr   ;
            ff_llist_mem_rfst_head [i] = llist_mem_rfst_head ;
            ff_llist_mem_rsec_head [i] = llist_mem_rsec_head ;
            ff_llist_mem_rqid      [i] = llist_mem_rqid      ;
        end 
    end 
    else begin : GEN_I_NE0
        always_ff @(posedge i_clk) begin
            if ( i_rst_n == 1'b0 ) begin
                ff_llist_mem_rd [i] <= 'b0; 
            end 
            else begin
                ff_llist_mem_rd [i] <= ff_llist_mem_rd [i -1] ;
            end 
        end 

        always_ff @(posedge i_clk) begin
            ff_llist_mem_rd        [i] <= ff_llist_mem_rd        [i -1] ; 
            ff_llist_mem_rh_rptr   [i] <= ff_llist_mem_rh_rptr   [i -1] ;
            ff_llist_mem_rfst_head [i] <= ff_llist_mem_rfst_head [i -1] ;
            ff_llist_mem_rsec_head [i] <= ff_llist_mem_rsec_head [i -1] ;
            ff_llist_mem_rqid      [i] <= ff_llist_mem_rqid      [i -1] ;
        end 
    end 
end
endgenerate


assign ffw_llist_mem_rd        = ff_llist_mem_rd        [LLIST_MEM_RD_DLY];
assign ffw_llist_mem_rh_rptr   = ff_llist_mem_rh_rptr   [LLIST_MEM_RD_DLY];
assign ffw_llist_mem_rfst_head = ff_llist_mem_rfst_head [LLIST_MEM_RD_DLY];
assign ffw_llist_mem_rsec_head = ff_llist_mem_rsec_head [LLIST_MEM_RD_DLY];
assign ffw_llist_mem_rqid      = ff_llist_mem_rqid      [LLIST_MEM_RD_DLY];

always_comb begin
    if (ffw_llist_mem_rd == 1'b1 && ffw_llist_mem_rh_rptr == 1'b0) begin
        deq_que_nxt_fst_head = i_llmem_rdata
    end
    else begin
        deq_que_nxt_fst_head = ffw_llist_mem_rfst_head ;
    end 
end 

always_comb begin
    if (ffw_llist_mem_rd == 1'b1 && ffw_llist_mem_rh_rptr == 1'b1) begin
        deq_que_nxt_sec_head = i_llmem_rdata
    end
    else begin
        deq_que_nxt_sec_head = ffw_llist_mem_rsec_head ;
    end 
end 

//============================================================================================//
//{{{assign deq_que_nxtm_cnt = edeq_same_qid_vld ? deq_que_cnt : deq_que_nxt_cnt ;
//
//always_comb begin
//    if (edeq_same_qid_vld == 1'b1) begin
//        if (enq_llist_req == 1'b1 && deq_head_rls_vld == 1'b0) begin
//            deq_que_nxtm_ll_cnt = deq_que_ll_cnt + 1'b1 ;
//        end
//        else if ( enq_llist_req == 1'b0 && deq_head_rls_vld == 1'b1   ) begin
//            deq_que_nxtm_ll_cnt = deq_que_ll_cnt - 1'b1 ;
//        end
//        else begin
//            deq_que_nxtm_ll_cnt = deq_que_ll_cnt ;
//        end 
//    end
//    else begin
//        deq_que_nxtm_ll_cnt = deq_head_rls_vld ? deq_que_ll_cnt - 1'b1 : deq_que_ll_cnt ;
//    end  
//end 
//
//assign deq_que_nxtm_head_rptr  = deq_que_nxt_head_rptr ;
//assign deq_que_nxtm_tail       = edeq_same_qid_vld ? enq_que_nxt_tail : deq_que_nxt_tail;
//assign deq_que_nxtm_sub_waddr  = edeq_same_qid_vld ? enq_que_nxt_sub_waddr : deq_que_nxt_sub_waddr ; 
//assign deq_que_nxtm_sub_raddr  = deq_que_nxt_sub_raddr ;
//}}}assign deq_que_nxtm_w2r_same   = edeq_same_qid_vld ?  (~deq_head_rls_vld)&enq_que_nxt_w2r_same : deq_que_nxt_w2r_same ; 

//-------------------------------------------//
assign enq_que_nxtm_cnt  =    edeq_same_qid_vld ? enq_que_cnt : enq_que_nxt_cnt ;    
always_comb begin
    if (edeq_same_qid_vld == 1'b1) begin
        if (enq_llist_req == 1'b1 && deq_head_rls_vld == 1'b0) begin
            enq_que_nxtm_ll_cnt = enq_que_ll_cnt + 1'b1 ;
        end
        else if ( enq_llist_req == 1'b0 && deq_head_rls_vld == 1'b1   ) begin
            enq_que_nxtm_ll_cnt = enq_que_ll_cnt - 1'b1 ;
        end
        else begin
            enq_que_nxtm_ll_cnt = enq_que_ll_cnt ;
        end 
    end
    else begin
        enq_que_nxtm_ll_cnt = enq_que_nxt_ll_cnt ;
    end  
end 

assign enq_que_nxtm_head_rptr  = edeq_same_qid_vld ? deq_que_nxt_head_rptr : enq_que_nxt_head_rptr ;
assign enq_que_nxtm_tail       = enq_que_nxt_tail       ;
assign enq_que_nxtm_sub_waddr  = enq_que_nxtm_sub_waddr ;
assign enq_que_nxtm_sub_raddr  = edeq_same_qid_vld ? deq_que_nxt_sub_raddr : enq_que_nxt_sub_raddr ;
assign enq_que_nxtm_w2r_same   = edeq_same_qid_vld ? (~deq_head_rls_vld)&enq_que_nxt_w2r_same : enq_que_nxt_w2r_same ;
                      

//============================= RAM NPORT INST =============================//

localparam QUE_INFO_W = QM_DEP_CW + QM_LL_CW + 1 + QM_LL_AW + QM_SUB_AW*2 + 1 ; 

logic [2              -1:0] info_ram_rd    ;
logic [2*QUE_W        -1:0] info_ram_raddr ;
logic [2*QUE_INFO_W   -1:0] info_ram_rdata ;

logic [2              -1:0] info_ram_wr    ;
logic [2*QUE_W        -1:0] info_ram_waddr ;
logic [2*QUE_INFO_W   -1:0] info_ram_wdata ;


assign info_ram_rd    = {i_que_deq_vld_pre , i_que_enq_vld_pre } ;
assign info_ram_raddr = {i_que_deq_qid_pre , i_que_enq_qid_pre } ;

assign {
    enq_que_cnt       ,
    enq_que_ll_cnt    ,
    enq_que_head_rptr ,
    enq_que_tail      ,
    enq_que_sub_waddr ,
    enq_que_sub_raddr ,
    enq_que_w2r_same   } = info_ram_rdata [QUE_INFO_W -1 :0] ;

assign {
    deq_que_cnt       ,
    deq_que_ll_cnt    ,
    deq_que_head_rptr ,
    deq_que_tail      ,
    deq_que_sub_waddr ,
    deq_que_sub_raddr ,
    deq_que_w2r_same   } = info_ram_rdata [2*QUE_INFO_W -1 :QUE_INFO_W] ;


//----------------------------------------------------//
always_ff @(posedge i_clk) begin
    if (i_rst_n == 1'b0 ) begin
        info_ram_wr <= 'b0 ;
    end
    else begin
        info_ram_wr <= {enq_que_vld , deq_que_update_vld} ;
    end
end 

always_ff @(posedge i_clk) begin
    if (enq_que_vld  == 1'b1) begin
        info_ram_waddr [QUE_W  -1:0] <= que_enq_qid ;
    end
end 

always_ff @(posedge i_clk) begin
    if (enq_que_vld == 1'b1 ) begin
        info_ram_wdata [QUE_INFO_W  -1:0] <= {
                enq_que_nxtm_cnt        ,     
                enq_que_nxtm_ll_cnt     ,
                enq_que_nxtm_head_rptr  ,
                enq_que_nxtm_tail       ,
                enq_que_nxtm_sub_waddr  ,      
                enq_que_nxtm_sub_raddr  ,      
                enq_que_nxtm_w2r_same    };
    end 
end 


always_ff @(posedge i_clk) begin
    if (enq_que_vld  == 1'b1) begin
        info_ram_waddr [2*QUE_W  -1: QUE_W] <= que_deq_qid ;
    end
end 


always_ff @(posedge i_clk) begin
    if (deq_que_update_vld == 1'b1 ) begin
        info_ram_wdata [2*QUE_INFO_W  -1: QUE_INFO_W] <= {
                deq_que_nxt_cnt        ,     
                deq_que_nxt_ll_cnt     ,
                deq_que_nxt_head_rptr  ,
                deq_que_nxt_tail       ,
                deq_que_nxt_sub_waddr  ,      
                deq_que_nxt_sub_raddr  ,      
                deq_que_nxt_w2r_same    };
    end 
end 

//===========================================================================//

localparam HEAD_RAM_W = 2*QM_LL_AW ;

logic [2              -1:0] head_ram_rd    ;
logic [2*QUE_W        -1:0] head_ram_raddr ;
logic [2*HEAD_RAM_W   -1:0] head_ram_rdata ;

logic [2              -1:0] head_ram_wr    ;
logic [2*QUE_W        -1:0] head_ram_waddr ;
logic [2*HEAD_RAM_W   -1:0] head_ram_wdata ;


assign head_ram_rd    = {i_que_deq_vld_pre , i_que_enq_vld_pre } ;
assign head_ram_raddr = {i_que_deq_qid_pre , i_que_enq_qid_pre } ;

assign {enq_que_sec_head,enq_que_fst_head} = head_ram_rdata [HEAD_RAM_W -1:0] ;
assign {deq_que_sec_head,deq_que_fst_head} = head_ram_rdata [2*HEAD_RAM_W -1: HEAD_RAM_W] ;

logic deq_head_update_vld ;
assign deq_head_update_vld = ffw_llist_mem_rd & (~(enq_que_head_update & (que_enq_qid == ffw_llist_mem_rqid) )) ;

always_ff @(posedge i_clk) begin
    if (i_rst_n == 1'b0 ) begin
        head_ram_wr <= 'b0 ;
    end
    else begin
        head_ram_wr <= {enq_que_vld , deq_head_update_vld};
    end
end 

always_ff @(posedge i_clk) begin
    if (enq_que_vld  == 1'b1) begin
        head_ram_waddr [QUE_W  -1:0] <= que_enq_qid ;
    end
end 

always_ff @(posedge i_clk) begin
    if (enq_que_vld == 1'b1 ) begin
        head_ram_wdata [HEAD_RAM_W -1:0] <= {enq_que_nxt_sec_head,enq_que_nxt_fst_head} ;
    end 
end 


always_ff @(posedge i_clk) begin
    if (deq_head_update_vld  == 1'b1) begin
        head_ram_waddr [2*QUE_W  -1: QUE_W] <= ffw_llist_mem_rqid ;
    end
end 

always_ff @(posedge i_clk) begin
    if (enq_que_vld == 1'b1 ) begin
        head_ram_wdata [2*HEAD_RAM_W -1: HEAD_RAM_W] <= {deq_que_nxt_sec_head,deq_que_nxt_fst_head} ;
    end 
end 

//-------------------------- link list wr && rd------------------------//
always_ff @(posedge i_clk) begin
    if ( i_rst_n == 1'b0 ) begin
        o_llmem_wr <= 'b0 ;
    end 
    else begin
        o_llmem_wr <= llist_mem_wr;
    end  

end 

always_ff @(posedge i_clk) begin
    if ( llist_mem_wr == 1'b1) begin
        o_llmem_waddr <= llist_mem_waddr ;
        o_llmem_wdata <= llist_mem_wdata ;
    end 
end 

//--read -----------//
generate
if (LLIST_RD_PIPE == 1 ) begin : GEN_LLIST_RD_PIP
    always_ff @(posedge i_clk) begin
        if (i_rst_n == 1'b0 ) begin
            o_llmem_rd <= 'b0 ;
        end
        else begin
            o_llmem_rd <= llist_mem_rd;
        end  
    end 

    always_ff @(posedge i_clk) begin
        if ( llist_mem_rd == 1'b1 ) begin
            o_llmem_raddr <= llist_mem_raddr ;
        end 
    end 

end
else begin : GEN_LLIST_NOPIP
    assign o_llmem_rd = llist_mem_rd ;
    assign o_llmem_raddr = llist_mem_raddr ;
    
end 
endgenerate


//=====    DMEM WR && RD====================================================================//

always_ff @(posedge i_clk) begin
    if ( i_rst_n == 1'b0 ) begin
        o_dmem_wr <= 'b0 ;
    end
    else begin
        o_dmem_wr <= enq_que_vld ;
    end
end 

always_ff @(posedge i_clk) begin
    if ( enq_que_vld == 1'b1 ) begin
        o_dmem_waddr <= enq_llist_req_pre ? {enq_new_que_addr,{QM_SUB_AW{1'b0}}} : {enq_new_que_addr,enq_que_sub_waddr};
        o_dmem_wdata <= que_enq_data ;
    end 
end 

logic [QM_LL_AW   -1:0] dmem_raddr_ll ;
logic [QM_DEP_AW  -1:0] dmem_raddr ;

assign dmem_raddr_ll = deq_que_head_rptr ? deq_que_sec_head :  deq_que_fst_head ;
assign dmem_raddr = {dmem_raddr_ll ,deq_que_sub_raddr} ;

generate
if ( DMEM_RD_PIPE == 1'b1 ) begin : GEN_DMEM_RD_PIP
    always_ff @(posedge i_clk) begin
        if ( i_rst_n == 1'b0 ) begin
            o_dmem_rd <= 'b0 ;
        end 
        else begin
            o_dmem_rd <= deq_que_vld ;
        end 
    end 

    always_ff @(posedge i_clk) begin
        if (deq_que_vld == 1'b1 ) begin
            o_dmem_raddr <= dmem_raddr;  
        end 
    end 
end
else begin : GEN_DMEM_NOPIP
    assign o_dmem_rd = deq_que_vld ;
    assign o_dmem_raddr = dmem_raddr ; 
end
endgenerate


logic [DMEM_RD_DLY  -1:0] dmem_rd_ff;

always_ff @(posedge i_clk) begin
    if (i_rst_n == 1'b0 ) begin
        dmem_rd_ff <= 'b0 ;
    end  
    else begin
        dmem_rd_ff <= {dmem_rd_ff,o_dmem_rd} ;
    end 
end 

assign o_que_deq_data_vld = dmem_rd_ff[DMEM_RD_DLY -1] ;

assign o_que_deq_data = i_dmem_rdata ;





endmodule





















