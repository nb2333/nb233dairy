//authored by ZhangGuorui

module draw_back #(
    parameter PORT_N      = 20 ,
    parameter MEM_DW      = 10 ,
    parameter CAL_DW      = 10 ,

    parameter PORT_W      = PORT_N ==1 ? 1 : $clog2(PORT_N) ,
    parameter END_OF_LIST = 1
)
(
    input  logic                   i_clk       ,
    input  logic                   i_rst_n     ,

    input  logic                   i_port_vld  ,
    input  logic [PORT_W    -1:0]  i_port_id   ,

    input  logic [MEM_DW    -1:0]  i_mem_rdata ,
    output logic [MEM_DW    -1:0]  o_app_rdata ,

    input  logic [MEM_DW    -1:0]  i_app_wadta ,

   //----------------------------------------------------// 
    output logic                   o_mem_wdata_vld  ,
    output logic [PORT_W    -1:0]  o_mem_waddr  ,
    output logic [MEM_DW    -1:0]  o_mem_wdata ,
    
    input  logic [CAL_DW    -1:0]  i_app_cal_data ,
    output logic [CAL_DW    -1:0]  o_down_cal_data ,

    input  logic                   i_draw_back 

);

logic                   port_vld_ff;
logic [PORT_W   -1:0]   port_id_ff ;


always_ff @(posedge i_clk) begin
    if (i_rst_n == 1'b0) begin
        port_vld_ff <= 'b0 ;
    end
    else begin
        port_vld_ff <= i_port_vld ;
    end 
end

always_ff @(posedge i_clk) begin
    if (i_port_vld == 1'b1) begin
        port_id_ff <= i_port_id ;
    end
end

logic burst_vld      ;
logic burst_draw_vld ;

assign burst_vld      = i_port_vld & port_vld_ff & (i_port_id == port_id_ff) ;
assign burst_draw_vld = burst_vld & i_draw_back;

logic [MEM_DW  -1:0] mem_rdata_ff ;

logic                mem_wdata_vld     ;
logic [PORT_W  -1:0] mem_waddr         ;
logic [MEM_DW  -1:0] mem_wdata_ff      ; 

assign mem_wdata_vld = port_vld_ff & (~i_draw_back);
assign mem_waddr     = port_id_ff  ;

always_ff @(posedge i_clk) begin
    if (i_port_vld == 1'b1) begin
        mem_wdata_ff      <= burst_draw_vld ? mem_wdata_ff : i_app_wadta  ;
    end
end

always_ff @(posedge i_clk) begin
    if (i_rst_n == 1'b0) begin
        o_mem_wdata_vld <= 1'b0 ;
    end
    else begin
        o_mem_wdata_vld <= mem_wdata_vld ;
    end
end

always_ff @(posedge i_clk) begin
    if (mem_wdata_vld == 1'b1) begin
        o_mem_wdata <= mem_wdata_ff ;
    end
end

assign o_app_rdata = burst_vld ? mem_wdata_ff : i_mem_rdata ;

logic [CAL_DW   -1:0] app_cal_data_ff  ;
always_ff @(posedge i_clk) begin
    if (i_port_vld == 1'b1) begin
        app_cal_data_ff <= burst_draw_vld ? app_cal_data_ff : i_app_cal_data ;
    end
end



assign o_down_cal_data = app_cal_data_ff ;





endmodule


