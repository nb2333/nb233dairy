import os
import pandas as pd
import filecmp
import math
import numpy as np
from numpy import random

def data_random (min = 0,max =1) :
    d_range = max - min
    random_data = min + math.ceil( random.random()*d_range  )
    return random_data


#def buffer (cur_cnt, tcl_vld , in_cnt, req_vld ,req_cnt ) :

#port speed
S = 100
W_DW = 2560
W_T = 1/1.25
W_SLOT_N = 32
W_PORT_SLOT_N = 2
W_MAX_SLOT_INT = 24


R_DW = 1536
R_T  = 1/1.25
R_SLOT_N = 32

#max pkt_bit
N = 16000*8

MAX_PKT_T = N/S

print('//==========================================================//')
print('The max pkt is ' + str(N) + ' bits' )
print('The max pkt send on sds needs ' + str(MAX_PKT_T) + ' ns' )

#one pkt need write this cycle
W_CYC_N = math.ceil(N/W_DW)

#the mean write slot interval
W_SLOT_INT = math.ceil(W_DW/S)
W_IDEAL_CYC_T = W_CYC_N*W_SLOT_INT

#the two cycle between two cycle of write cycle
if W_MAX_SLOT_INT == 0 :
    W_MAX_INT = math.ceil(math.ceil(W_DW/S)/W_T) *W_T
else :
    W_MAX_INT = math.ceil(W_DW/S) + W_MAX_SLOT_INT*W_T

#the pkt sds time plus 1 round
W_SLOT_ROUND_T = W_T*W_SLOT_N
W_IDEAL_ROUND_T = math.ceil(N/S/W_SLOT_ROUND_T)*W_SLOT_ROUND_T + W_MAX_INT
W_IDEAL_MAX_T  = math.ceil(N/S/W_SLOT_ROUND_T +1) * W_SLOT_ROUND_T

#one slot round should write these bits
W_SLOT_TBIT  = W_SLOT_N*W_T*S

#the min bits write in one slot round
W_MIN_SLOT_TBIT =  math.floor(W_SLOT_TBIT/W_DW -1)*W_DW
W_SLOT_ROUND = math.floor(N/W_SLOT_TBIT)

if N%W_SLOT_TBIT == 0 :
    W_SLOT_ROUND = W_SLOT_ROUND -1    

W_ROUND_RMN_BITS = N-W_SLOT_ROUND*W_SLOT_TBIT
W_MAX_ROUND_TAIL_T = W_T*W_SLOT_N*W_SLOT_ROUND + (math.floor( (W_ROUND_RMN_BITS)/W_DW) + 1)*W_MAX_INT

if  W_IDEAL_MAX_T < W_IDEAL_ROUND_T :
    W_MAX_T = W_IDEAL_MAX_T
else :
    W_MAX_T = W_IDEAL_ROUND_T

if W_MAX_ROUND_TAIL_T < W_MAX_T :
    W_MAX_T = W_MAX_ROUND_TAIL_T

print('//==========================================================//')
print("The max pkt need to write " +  str(W_CYC_N) + ' cycles')
print("The mean write slot interval is " + str(W_SLOT_INT) + ' ns')
print("The max slot interval is " + str(W_MAX_INT) + ' ns')

print('//==========================================================//')
print("The write time of a pkt is W_CYC_N*W_SLOT_INT that is " + str(W_IDEAL_CYC_T) + ' ns')

print('//==========================================================//')
print("Write side One rounds takes " + str(W_SLOT_ROUND_T) +' ns')
print("The write time of a pkt counted by (slot round)   is " + str(W_IDEAL_ROUND_T) + ' ns')

print('//==========================================================//')
print("The write time of a pkt counted by (slot round +1)   is " + str(W_IDEAL_MAX_T) + ' ns')

print('//==========================================================//')
print("The write base rounds is " + str(W_SLOT_ROUND) + ' rounds')
print("The tails bits remain is " + str(W_ROUND_RMN_BITS) + 'bits')
print("The write time count by round and tail is " + str(W_MAX_ROUND_TAIL_T) + 'ns' )
print("The max pkt write time is " + str(W_MAX_T) + ' ns')

#=============read ========================#
R_CYC_N = math.ceil(N/R_DW)
R_SLOT_TBIT = R_SLOT_N*R_T*S

R_MIN_INT = math.floor(R_DW/S/R_T)*R_T

R_IDEAL_CYC_T = R_CYC_N*R_MIN_INT

R_SLOT_ROUND = math.floor(N/R_SLOT_TBIT)

if N%R_SLOT_TBIT == 0 :
    R_SLOT_ROUND = R_SLOT_ROUND -1
    

R_ROUND_RMN_BITS = N - R_SLOT_ROUND*R_SLOT_TBIT

R_MIN_ROUN_TAIL_T = R_T*R_SLOT_ROUND*R_SLOT_N + (math.floor((R_ROUND_RMN_BITS)/R_DW) -1)*R_MIN_INT
R_MIN_T = R_MIN_ROUN_TAIL_T 

print('//==========================================================//')
print("The max pkt need to read " + str(R_CYC_N) + " cycles")
print("Read mean interval is " + str(R_MIN_INT) + 'ns')

print('//==========================================================//')
print("The ideal read time counted by R_CYC_N*R_MIN_INT is " + str(R_IDEAL_CYC_T) + ' ns')

print('//==========================================================//')
print("The max pkt read base round is " + str(R_SLOT_ROUND) + ' rounds')
print("The tail bits remain is " + str(R_ROUND_RMN_BITS) + ' bits' )
print("Read one pkt min time is " + str(R_MIN_T) + 'ns')


start_th0 = math.ceil(W_MAX_T - R_MIN_T)*S
start_th1 = math.ceil(W_MAX_SLOT_INT/R_MIN_INT)*R_DW - W_DW
start_th2 = (math.ceil(W_SLOT_N*W_T/R_MIN_INT)*R_DW ) - W_MIN_SLOT_TBIT

print(start_th0,start_th1,start_th2)




