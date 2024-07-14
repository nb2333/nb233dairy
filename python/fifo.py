import os


def fifo_normal ( fifo_list =[] , push_en , push_data  , pop_en ,FIFO_DEP  ) :
   if pop_en  == 1 and len(fifo_list) > 0 :
        rdata_valid = 1
        rdata = fifo_list.pop[1]


   if push_en  == 1 and len(fifo_list) < FIFO_DEP :
        fifo_list.append(push_data)
    
    
   return rdata_valid,rdata,fifo_list




#def fifo_new ( push_en, push_data, pop_en, FIFO_DEP , LMEM_DEP ,
#               mem_list = [] , rd_ptr, wr_ptr , 
#               l2h_l_ptr_vld, l2h_l_ptr ,
#               l2h_h_ptr_vld, l2h_h_ptr ,
#               h2l_h_ptr_vld, h2l_h_ptr , 
#               h2l_l_ptr_vld, h2l_l_ptr , 
#               l_cnt,h_cnt, fifo_fill_cnt   ) :


def fifo_new (push_en=0,push_data,pop_en =0,FIFO_DEP,LMEM_DEP ,
              mem_list    = [] , wr_ptr, h_wr_ptr ,
              rd_ptr, rd_l_vld, rd_start_ptr ,rd_stop_ptr, rd_stop_ptr_vld, rd_link_list = [] 
              l_cnt,h_cnt,fifo_fill_cnt) :

    HMEM_DEP = FIFO_DEP - LMEM_DEP

    #--------------------------------------------------------#
    if pop_en == 1 and fifo_fill_cnt > 0 :
        pop_en = 1
    else :
        pop_en = 0

    if push_en ==1 and fifo_fill_cnt < FIFO_DEP :
        push_en = 1
    else :
        push_en = 0

    #---------------------  write logic --------------------------------#
    this_write_l = 0
    this_write_h = 0

    if push_en == 1 :
        if l_cnt == 0 or (wr_ptr < LMEM_DEP and l_cnt < LMEM_DEP) or h_cnt == HMEM_DEP :
            this_write_l = 1
        else :
            this_write_h = 1
        
        #-----------------------------------------------------------------#
        if this_write_l == 1:
            if wr_ptr >= LMEM_DEP : # high change to low ,write to 0
                mem_list [0] = push_data
            else :
                nxt_h_wr_ptr = h_wr_ptr
                mem_list [wr_ptr] = push_data
        else :
            if wr_ptr < LMEM_DEP :
                mem_list [h_wr_ptr] = push_data
                nxt_wr_ptr = h_wr_ptr + 1
            else :
                mem_list [wr_ptr] = push_data
                
                if wr_ptr == FIFO_DEP -1 :
                    nxt_wr_ptr = LMEM_DEP
                else :
                    nxt_wr_ptr = wr_ptr + 1
     
    #----------------------- read logic --------------------------#
    rdata_valid = 0
    rdata       = 0
    
    this_read_l = 0
    this_read_h = 0
    if pop_en == 1 : 
        rdata_valid = 1
        rdata = mem_list [rd_ptr]

        if rd_ptr < LMEM_DEP :
            this_read_l = 1
        else :
            this_read_h = 1

    #---------------------- cnt logic -------------------------------#
    if push_en == 1 and pop_en == 0 :
        nxt_fifo_fill_cnt  = fifo_fill_cnt + 1
    elif push_en == 0 and pop_en == 1:
        nxt_fifo_fill_cnt  = fifo_fill_cnt - 1

    
    if this_write_l == 1 and this_read_l == 0 :
        nxt_l_cnt = l_cnt + 1
    else :
        nxt_l_cnt = l_cnt - 1
    
    if this_write_h == 1 and this_read_h == 0 :
        nxt_h_cnt = h_cnt + 1
    else :
        nxt_h_cnt = h_cnt - 1

    #------------------------- update read info ---------------------------------------#
        
    nxt_rd_link_list = rd_link_list.copy()

    #lcnt full 
    if nxt_l_cnt == LMEM_DEP and this_write_l == 1:
        if rd_l_vld == 1 and rd_stop_ptr_vld == 0 :
            nxt_stop_ptr_vld = 1
            nxt_stop_ptr     = wr_ptr
            nxt_rd_l_vld     = 1
            
            if rd_ptr == LMEM_DEP -1 :
                nxt_rd_ptr  = 0  
            else :
                nxt_rd_ptr  = rd_ptr + 1

        elif :
            nxt_rd_link_list.push( (wr_ptr, 1 ,   )  )







