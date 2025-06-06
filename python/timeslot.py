import os
import pandas as pd
import filecmp
import math
import numpy as np
from numpy import random
from fractions import Fraction


def phy_paser (in_phy_map,phy_num) :
    phy_cfg_map = {}

    for phy_bw,phy_ids in in_phy_map.items() :
        
        phy_bw = phy_bw.split(',') 
        phy_org_bw = float(phy_bw[0])
        phy_act_bw = float(phy_bw[1])

        phy_id_list = phy_ids.split(',')

        for phy_id in  phy_id_list :
            
            if phy_id in phy_cfg_map :
                print('//------------------------ WRONG : the PHY is not uniq ' + phy_id + ' !!!--------------------//')
            else :
                phy_cfg_map[phy_id] = [phy_org_bw,phy_act_bw]


    return phy_cfg_map

#find the valid slotn,actually the max slot n is enough
def slotn_test (slotn,phy_bw_map,comb_bw,comb_real_bw) :
    slot_obw = comb_bw/slotn
    slot_rbw = comb_real_bw/slotn

    #--------------------------------#
    tot_rneed_slotn = 0
    tot_oneed_slotn = 0

    
    phy_cfg = {}

    phy_rcfg = {} #real bandwidth config
    phy_ocfg = {} #original bandwidt config
    
    bw_fail = 0
    #total slot n according to real band width      
    for phy_id,phy_bw in phy_bw_map.items() :
        phy_rbw = phy_bw [1]
        phy_obw = phy_bw [0]

        phy_rslot_n  = 0
        phy_rspeed_up = 0 

        if phy_rbw > 0 :
            if phy_rbw <= slot_rbw  :
                phy_rslot_n = 1 
            elif phy_rbw%slot_rbw == 0 :
                phy_rslot_n = int(phy_rbw/slot_rbw)
            else :
                phy_rslot_n = int(phy_rbw/slot_rbw) + 1
            
            phy_rspeed_up = phy_rslot_n*slot_rbw/phy_rbw
            tot_rneed_slotn = tot_rneed_slotn  + phy_rslot_n
    
        phy_rcfg [phy_id] = {}
        phy_rcfg [phy_id] ['RBW']      = phy_rbw
        phy_rcfg [phy_id] ['BW']       = phy_obw 
        phy_rcfg [phy_id] ['RSLOT_N']  = phy_rslot_n
        phy_rcfg [phy_id] ['SPEED_UP'] = "%.2f"% phy_rspeed_up
  

        #----------------------------------------------------#
        
        phy_oslot_n  = 0
        phy_ospeed_up = 0 

        if phy_obw > 0 :
            if phy_obw <= slot_obw  :
                phy_oslot_n = 1 
            elif phy_obw%slot_obw == 0 :
                phy_oslot_n = int(phy_obw/slot_obw)
            else :
                phy_oslot_n = int(phy_obw/slot_obw) + 1
            
            phy_ospeed_up = phy_oslot_n*slot_rbw/phy_rbw
            tot_oneed_slotn = tot_oneed_slotn  + phy_oslot_n
                
            if phy_ospeed_up < 1:
                bw_fail = 1

        phy_ocfg [phy_id] = {}
        phy_ocfg [phy_id] ['RBW']      = phy_obw
        phy_ocfg [phy_id] ['BW']       = phy_obw 
        phy_ocfg [phy_id] ['RSLOT_N']  = phy_oslot_n
        phy_ocfg [phy_id] ['SPEED_UP'] = "%.2f"% phy_ospeed_up
    
    ###---------------------------------------------------#
    slotn_vld = 1
    slotn_rvld = 1

    if tot_oneed_slotn > slotn or bw_fail == 1:
        slotn_vld = 0
    
    if tot_rneed_slotn > slotn :
        slotn_rvld = 0

    slot_bw= float(comb_bw)/slotn

    return (slotn_vld,slotn_rvld,slotn,"%.2f"%slot_rbw,"%.2f"%slot_bw,phy_ocfg,phy_rcfg)



def search_slot_n (comb_bw, comb_rbw, phy_bw_map, comb_slot_n ) :

    phy_cfg_list = []

    phy_num = len(phy_bw_map)
    

    #for slot_num in range(comb_slot_n,phy_num,-1) :
    #print(slot_num)
    slotn_vld,slotn_rvld,slotn,slot_rbw,slot_bw,phy_cfg,phy_rcfg =slotn_test (comb_slot_n,phy_bw_map,comb_bw,comb_rbw) 
    

    if slotn_vld == 1 :
    
        scene_cfg = {}

        scene_cfg['SLOT_N']   = slotn
        scene_cfg['SLOT_RBW'] = slot_rbw
        scene_cfg['SLOT_BW']  = slot_bw
        scene_cfg['PHY_CFG']  = phy_cfg

        phy_cfg_list.append(scene_cfg)

    if slotn_rvld == 1 :
    
        scene_cfg = {}

        scene_cfg['SLOT_N']   = slotn
        scene_cfg['SLOT_RBW'] = slot_rbw
        scene_cfg['SLOT_BW']  = slot_bw
        scene_cfg['PHY_CFG']  = phy_rcfg

        #phy_cfg_list.append(scene_cfg)

    return phy_cfg_list


#============= mapping to slot table ============================#
def mapToCalendarTbl (slot_n,phy_cfg) :
    work_slot_n = phy_cfg['SLOT_N']

    slot_width = 0
    slot_m = slot_n

    while slot_m > 0: 
        slot_m = int(slot_m/10)
        slot_width = slot_width +1
        
    slot_idx = []
    slot_id_tbl  = [] 
    
    #------------- init -----------------#
    for i in range(0,slot_n) :
        slot_idx.append( str(i).rjust(slot_width,' ') )

        if i < work_slot_n :
            slot_id_tbl.append( 'NA' )
        else:
            slot_id_tbl.append( ' '.rjust(slot_width,' ') )            

    #print(slot_idx)
    #print(slot_id_tbl)
 
    #sort the phy as band width from big to small
    phy_sort_list = []


    for phy_1cfg in phy_cfg['PHY_CFG'].items() :
        #print( phy_1cfg )

        if len(phy_sort_list) == 0 :
            phy_sort_list.append(phy_1cfg)
        else :
            phy_idx =0
            phy_1cfg_bw = phy_1cfg[1]['RBW']

            ins_flag = 0
            for phy_sort_u in phy_sort_list :
                phy_sort_u_bw = phy_sort_u[1] ['RBW']
                
                if phy_1cfg_bw > phy_sort_u_bw :
                    #print(phy_sort_list)
                    phy_sort_list.insert(phy_idx,phy_1cfg)
                    ins_flag =1
                    break
                else :
                    phy_idx = phy_idx +1
            
            if ins_flag == 0 :
                phy_sort_list.insert(phy_idx,phy_1cfg)
                    
    #print("#================================================#")
    #print( phy_sort_list)
 
    print(phy_sort_list)
    slot_gap_list = []
    for phy_1cfg in phy_sort_list :
        #print(phy_1cfg,slot_id_tbl)
        phy_id     = phy_1cfg [0]
        phy_slotn  = phy_1cfg [1]['RSLOT_N']

        #------------ TBD --------------------
        slot_id_tbl,max_gap,min_gap = map1Phy(phy_id=phy_id.rjust(slot_width,' '),phy_slotn=phy_slotn,work_slot_n = work_slot_n,slot_id_tbl=slot_id_tbl)
        slot_gap_list.append([phy_id,phy_slotn,max_gap,min_gap,max_gap-min_gap])

    #print(slot_idx)
    print(slot_id_tbl)
    print(phy_cfg['SLOT_N'],phy_cfg['SLOT_BW'],phy_cfg['SLOT_RBW'])
    print(slot_gap_list)


def map1Phy(phy_id,phy_slotn,work_slot_n,slot_id_tbl) :
    #print(phy_id,phy_slotn,work_slot_n)
   
    actual_slot_gap = work_slot_n/phy_slotn
    slot_gap = int(actual_slot_gap)
    slot_gap_decimal = actual_slot_gap - slot_gap

    print('//=================================================//')
    print(actual_slot_gap,slot_gap,slot_gap_decimal)
    
    #find the first NA as slot bias
    slot_bias = 0
    for slot_id in slot_id_tbl :
        if slot_id == 'NA' :
            break
        else :
            slot_bias = slot_bias + 1

    slot_decimal_sum = 0
    last_slot_id = 0
    max_gap  = 0
    min_gap  = work_slot_n
    first_slot_pos = 0
    max_slot_pos = 0
    min_slot_pos = work_slot_n

    for i in range(0,phy_slotn) :
        if i == 0 :
            slot_best = slot_bias 
        else :
            slot_decimal_sum = slot_decimal_sum + slot_gap_decimal
            print(slot_decimal_sum)
            slot_decimal_sum_dec = slot_decimal_sum - int(slot_decimal_sum)
            
            if  slot_decimal_sum_dec > 0.85 :
                integer_of_dec = int(slot_decimal_sum) +1
            elif  slot_decimal_sum_dec < -0.85 :
                integer_of_dec = int(slot_decimal_sum) -1
            else :
                integer_of_dec = int(slot_decimal_sum)

            slot_best = last_slot_id + slot_gap  + integer_of_dec

        #print(i,last_slot_id,slot_best)                 
        #print(i,last_slot_id,slot_best)  
        if slot_best > work_slot_n -1 :
            slot_best = work_slot_n -1

        slot_pos = 0
        if slot_id_tbl[slot_best] == 'NA' :
            slot_pos = slot_best
        else :
            left_exit   = 0
            left_jitter = 1
            left_pos    = 0

            for i in range(slot_best -1, 0, -1):
                if slot_id_tbl [i]  == 'NA' :
                    left_exit = 1
                    left_pos = i
                    break
                else :
                    left_jitter = left_jitter + 1
               
            right_exit = 0
            right_jitter= 1
            right_pos = 0
            for i in range(slot_best +1,work_slot_n,1):
                if slot_id_tbl[i] == 'NA' :
                    right_exit = 1
                    right_pos = i
                    break
                else:
                    right_jitter = right_jitter + 1
                    

            slot_decimal_sum_dec = slot_decimal_sum - integer_of_dec 
 
            left_dec_sum  = abs(slot_decimal_sum_dec + left_jitter  + slot_gap_decimal )
            right_dec_sum = abs(slot_decimal_sum_dec - right_jitter + slot_gap_decimal )
            
            
            if left_dec_sum <right_dec_sum :
                slot_pos = left_pos
            else :
                slot_pos = right_pos
            

        slot_id_tbl[slot_pos] = phy_id
        
        if i == 0 :
            slot_gitter  = 0
            first_slot_pos = slot_pos
            
            max_slot_pos = slot_pos 
            min_slot_pos = slot_pos

        else :
            slot_gap_cur = slot_pos - last_slot_id
            slot_gitter  = slot_gap_cur - slot_gap

            if max_gap < slot_gap_cur :
                max_gap = slot_gap_cur

            if min_gap > slot_gap_cur :
                min_gap = slot_gap_cur

            if slot_pos > max_slot_pos :
                max_slot_pos = slot_pos

            if slot_pos < min_slot_pos :
                min_slot_pos = slot_pos

            
        slot_decimal_sum =  slot_decimal_sum - slot_gitter
        last_slot_id = slot_pos
        
    
    if  phy_slotn == 1:
        max_gap = work_slot_n
        min_gap = work_slot_n
    else :
        slot_gap_cur = work_slot_n - 1 - max_slot_pos  + min_slot_pos

        if max_gap < slot_gap_cur :
            max_gap = slot_gap_cur

        if min_gap > slot_gap_cur :
            min_gap = slot_gap_cur
    
    return slot_id_tbl,max_gap,min_gap



#comb parameter
TOTAL_SLOTN = 160 
COMB_BW     = 1600
COMB_DW     = 1600
COMB_FREQ   = 1 
PHY_N       = 32

#real band width
COMB_RBW = COMB_DW*COMB_FREQ 
comb_rbw_f = Fraction(int(COMB_RBW*100) ,100)

#user config
slot_bw_list = [200,100,50,25,12.5,10]

#in_phy_map = {'25,25.78125':'0,1,2,3,4,5,6,7'}
#in_phy_map = {'25,25.78125':'0,1,2,3','10,10.3125':'4,5,7','40,42.3':'6'}
in_phy_map = {'300,300':'0,2','110,110':'3'}
#in_phy_map = {'110,110':'3'}

old_table_slotbw = '' 

#float the slot bw
slot_bw_list_f = []
for slot_bw in slot_bw_list :
    slot_bw_list_f.append("%.2f"%slot_bw)

#stat the total working bandwidth and phy number
phy_bw_set = set()
phy_tot_bw = 0
work_phy_n = 0

phy_bw_map = phy_paser (in_phy_map,PHY_N)

print(phy_bw_map)

for bw in phy_bw_map.values() :
    bw = bw[0]

    if bw > 0 :
        phy_bw_set.add(bw)
        phy_tot_bw = phy_tot_bw + bw
        work_phy_n = work_phy_n +1
print(phy_tot_bw)

if phy_tot_bw > COMB_BW :
    print(phy_tot_bw)
    print('//============== WRONG : THIS SCENE TOTAL BANDWITH BEYOND COMB BANDWIDTH !!!==================//')
    exit


possible_slotn = search_slot_n(comb_bw = COMB_BW , comb_rbw=COMB_RBW, phy_bw_map = phy_bw_map,comb_slot_n = TOTAL_SLOTN)

if len(possible_slotn) == 0 :
    print('//======================= WRONG : CANT FIND A SLOT FOR THIS SCENE ==========================//')

##-------------------------------------#
#cfg_in_bw_list = []
#cfg_ngood = []
#
#for posb_cfg in possible_slotn :
#    if posb_cfg['SLOT_BW'] in slot_bw_list_f :
#        cfg_in_bw_list.append(posb_cfg)
#    else :
#        cfg_ngood.append(posb_cfg)
#
#if len(cfg_in_bw_list) > 0 :
#    posb_cfg_list = cfg_in_bw_list 
#else :
#    posb_cfg_list = cfg_ngood
#
#
##-------------- most time we hope it keeps the same slot number ---------------------#
#cfg_eq_last_slotbw = []
#cfg_noeq_last_slot_bw = []
#
#for posb_cfg in posb_cfg_list :
#    if posb_cfg['SLOT_BW'] == old_table_slotbw :
#        cfg_eq_last_slotbw.append(posb_cfg)
#    else :
#        cfg_noeq_last_slot_bw.append(posb_cfg)
#
#if len(cfg_eq_last_slotbw) == 0 :
#    posb_cfg_list = cfg_noeq_last_slot_bw
#else:
#    posb_cfg_list = cfg_eq_last_slotbw
#
#print(posb_cfg_list)
#posb_cfg = posb_cfg_list [0]
#
##print(posb_cfg)
#
#mapToCalendarTbl (TOTAL_SLOTN,posb_cfg)


for posb_cfg in possible_slotn :
    mapToCalendarTbl(TOTAL_SLOTN,posb_cfg)




