
module fifo #(
    parameter CACHE_DEP   = 3   ,
    parameter MEM_DEP     = 256 ,
    parameter LMEM_DEP    = 64  ,

    parameter DW          = 32  ,

    parameter MEM_RD_LAT  = 2   ,
    
    parameter FIFO_DEP    = CACHE_DEP + MEM_DEP ,
    parameter FIFO_AW     = $clog2(FIFO_DEP),
    parameter FIFO_CW     = $clog2(FIFO_DEP +1) ,

    parameter MEM_AW      = $clog2(ME_DEP) ,

    parameter END_OF_LIST = 1 
)
(
    input  logic                    i_clk     ,
    input  logic                    i_rst_n   ,

    input  logic                    i_wr_req  ,
    input  logic [DW          -1:0] i_wdata   ,

    input  logic                    i_rd_req  ,
    output logic [DW          -1:0] o_rdata   ,
    output logic                    o_rdata_valid ,

    output logic                    o_fifo_cerr ,
    output logic                    o_fifo_uerr ,

    //---------------- fifo status ------------------//
    output logic                    o_fifo_empty    ,
    output logic                    o_fifo_full     ,
    output logic                    o_fifo_overflow ,
    output logic [FIFO_CW     -1:0] o_fifo_fill_cnt ,

    input  logic [FIFO_CW     -1:0] i_alful_th      ,
    input  logic [FIFO_CW     -1:0] i_alempt_th     ,

    output logic                    o_fifo_alful    ,
    output logic                    i_fifo_alempt   ,

    //-------------------- memory ------------------//
    output logic                    o_mem_wr        ,
    output logic [MEM_AW      -1:0] o_mem_waddr     ,
    output logic [DW          -1:0] o_mem_wdata     ,
    output logic                    o_mem_rd        ,
    output logic [MEM_AW      -1:0] o_mem_raddr     ,
   
    input  logic [DW          -1:0] i_mem_rdata     , 
    input  logic                    i_mem_cerr      ,
    input  logic                    i_mem_uerr      
);

genvar i;


localparam CACHE_AW = $clog2(CACHE_DEP)    ;
localparam CACHE_CW = $clog2(CACHE_DEP +1) ;

localparam MEM_CW   = $clog2(MEM_DEP   +1) ;


//----------------- fifo cnt -----------------------//
logic [FIFO_CW    -1:0] fifo_cnt   ;

logic                   fifo_full  ;
logic                   fifo_empty ;

logic                   fifo_wr ;
logic                   fifo_rd ;

assign fifo_wr = i_wr_req & (~fifo_full)  ;
assign fifo_rd = i_rd_req & (~fifo_empty) ;

always_ff @(posedge i_clk) begin
    if ( i_rst_n == 1'b0 ) begin
        fifo_cnt <= 'b0 ;
    end 
    else if (fifo_wr != fifo_rd) begin
        fifo_cnt <= fifo_cnt + {{(FIFO_CW -1){fifo_rd}},{1'b1}} ;
    end 
end 

assign fifo_full  = fifo_cnt == FIFO_DEP ;
assign fifo_empty = ~(|fifo_cnt) ;

//---------------- cache && mem -----------------------//
logic [CACHE_CW  -1:0] cache_cnt ;

logic                  cache_usr_wr     ;
logic                  cache_mem_wr_pre ;
logic                  cache_mem_wr     ;
logic [CACHE_DW  -1:0] cache_mem_wr_ptr ;

logic                  cache_wr         ;

logic                  cache_rd         ;

logic                  cache_full       ;
logic                  cache_nempty     ;

localparam CACHE_DW = DW + 2 ;

logic  [CACHE_DW -1:0] cache_data [CACHE_DEP  -1:0] ;

//-------------------//
logic  [MEM_CW        -1:0] mem_cnt          ;
logic                       mem_nempty       ;
logic                       mem_rd_en        ;
logic  [MEM_RD_LAT +1 -1:0] mem_rd_en_ff     ;

logic                       mem_wr_en        ; 

//----------------------------------------------------//
assign cache_wr = cache_usr_wr | cache_mem_wr_pre ;

always_ff @(posedge i_clk) begin
    if ( i_rst_n == 1'b0 ) begin
        cache_cnt <= 'b0 ;
    end 
    else if ( cache_wr != cache_rd ) begin
        cache_cnt <= cache_cnt + {{(CACHE_CW -1){cache_rd}},{1'b1}} ;
    end 
end 

assign cache_nempty = |cache_cnt ;
assign cache_rd = cache_nempty &  i_rd_req ;

assign cache_usr_wr     = (~cache_full) & i_wr_req ;
assign cache_mem_wr_pre = mem_nempty & i_rd_req  ;


logic [CACHE_AW  -1:0] cache_wr_ptr     ;
logic [CACHE_AW  -1:0] cache_wr_ptr_ff  [MEM_RD_LAT +1  -1:0];
logic [CACHE_DEP -1:0] cache_rd_ptr ;

always_ff @(posedge i_clk) begin
    if ( i_rst_n == 1'b0 ) begin
        cache_wr_ptr <= 'b0 ;
    end
    else if ( cache_wr == 1'b1 ) begin
        cache_wr_ptr <= (cache_wr_ptr == CACHE_DEP -1) ? 'b0 : cache_wr_ptr + 1'b1 ;
    end
end 

always_ff @(posedge i_clk) begin
    if ( i_rst_n == 1'b0 ) begin
        cache_rd_ptr <= 1'b1 ;
    end 
    else if (cache_rd == 1'b1) begin
        cache_rd_ptr <= {cache_rd_ptr,cache_rd_ptr[CACHE_DEP -1]} ;
    end
end 


generate
for(i=0;i<MEM_RD_LAT +1;i=i+1) begin : GEN_MRM_RD_DLY
    if (i==0) begin : GEN_I_EQ0
        assign mem_rd_en_ff    [i] =  mem_rd_en    ;
        assign cache_wr_ptr_ff [i] =  cache_wr_ptr ;
    end
    else begin : GEN_I_NE0
        always_ff @(posedge i_clk) begin
            mem_rd_en_ff    [i] <=  mem_rd_en_ff    [i -1] ;           
            cache_wr_ptr_ff [i] <=  cache_wr_ptr_ff [i -1] ;
        end 
    end 
end
endgenerate

assign cache_mem_wr     = mem_rd_en_ff    [MEM_RD_LAT] ;
assign cache_mem_wr_ptr = cache_wr_ptr_ff [MEM_RD_LAT] ;

logic [DW   -1:0] wdata_mask ;

assign wdata_mask = i_wdata & {DW{cache_usr_wr}} ;

generate
for (i=0;i<CACHE_DEP;i=i+1) begin : GEN_CACHE_DATA
    always_ff @(posedge i_clk) begin
        if (cache_mem_wr == 1'b1 && cache_mem_wr_ptr == i ) begin
            cache_data [i] <= i_mem_rdata ;
        end
        else if ( cache_usr_wr == 1'b1 && cache_wr_ptr[i] == 1'b1 ) begin
            cache_data [i] <= wdata_mask  ;
        end
    end 
end
endgenerate

//---------------------- mem ctrl logic --------------------------------//
assign mem_rd_en  = cache_mem_wr_pre ;
assign mem_wr_en  = cache_full & fifo_wr ;

localparam HMEM_DEP = MEM_DEP - LMEM_DEP ;

localparam LMEM_AW  = $clog2(LMEM_DEP) ;
localparam HMEM_AW  = $clog2(HMEM_DEP) ;

logic [LMEM_AW    -1:0] lmem_wr_ptr     ;
logic [LMEM_AW    -1:0] lmem_rd_ptr     ;

logic [HMEM_AW    -1:0] hmem_wr_ptr     ;
logic [HMEM_AW    -1:0] hmem_rd_ptr     ;

logic                  lmem_empty     ;
logic                  cross_addr_vld ;
logic [LMEM_AW   -1:0] cross_addr     ;





















endmodule

