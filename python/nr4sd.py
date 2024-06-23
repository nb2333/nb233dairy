import os
import pandas as pd
import filecmp
import math

def binMulti (a,b) :
    return a*b

def dec2bin(a,out_len = 0) :
    abs_a = abs(a)
    abs_a_bin = bin(abs_a)[2:]
    len_a = len(abs_a_bin)


    if a < 0 :
        
        abs_a_com = 2**len_a - abs_a

        if 2**(len_a -1) == abs_a and len_a > 1:
            a_bin = abs_a_bin
        else:
            abs_com_bin =  bin(abs_a_com)[2:]
            a_bin ='1' + '0'*(len_a - len(abs_com_bin)) + abs_com_bin
        #a_bin = '1' + abs_a_bin
    else :
        a_bin = '0' + abs_a_bin

    len_a = len(a_bin)

    if len_a >= out_len :
        a_bin = a_bin
    else :
        a_bin = a_bin[0]*(out_len - len_a)  + a_bin

    return a_bin

#print(dec2bin(-1))
#print(dec2bin(-12))
#print(dec2bin(-32,10))
#print(dec2bin(32,10))


def dec2nr4sd (a) :
    a_bin_org = dec2bin(a)

    # calculate grp
    len_a = len(a_bin_org)

    if len_a%2 == 0 :
        grp = int(len_a/2)
    else :
        grp = math.floor(len_a/2) +1

    full_a = 2*grp

    if full_a > len_a :
        a_bin = a_bin_org [0] + a_bin_org
    else :
        a_bin = a_bin_org
    
    a_bin_org = a_bin_org [:: -1]
    ###===========================#
    #print(a_bin)
    a_bin = a_bin[::-1]
    
    nrsd_c = []
    nrsd_b = []

    nrsd_p  = []
    nrsd_pc = [0]

    nrsd_n  = []
    nrsd_nc = [0]
    for i in range(0,grp) :
        b2j   = int( a_bin[2*i])
        b2jp1 = int( a_bin[2*i +1])
        if i == 0 :
            c2j = 0
        else :
            c2j   = nrsd_c [2*(i-1)+1]
       
        n2j   = b2j ^ c2j
        c2jp1 = b2j & c2j

        n2jp1 = b2jp1 ^ c2jp1
        
        c2jp2 = b2jp1 | c2jp1
            

        nrsd_c.append(c2jp1)
        nrsd_c.append(c2jp2)

        if i < grp -1 :
            bj = -2*n2jp1 + n2j
        else :
            bj = -2*b2jp1 + b2j + c2j

        #print(a_bin[2*i +1],a_bin[2*i],c2j)
        #print(bj,c2jp2)
        
        nrsd_b.append(bj)                         

    #nrsd -
    grp = math.floor(len(a_bin_org)/2)
    for i in range(0,grp) :
        c2j = nrsd_nc [i]
        
        b2j   = int(a_bin_org [2*i])
        b2jp1 = int(a_bin_org [2*i + 1])

        c2jp2 =  b2jp1 | (b2j & c2j)
        
        eq_p1  = (~b2jp1) & ( b2j ^ c2j )
        eq_n1  =   b2jp1  & ( b2j ^ c2j )
        eq_n2  = ( b2jp1 & (~b2j) & (~c2j) )  | ( (~b2jp1) & b2j & c2j )

        
        if eq_p1 == 1 :
            bj = 1 
        elif eq_n1 == 1 :
            bj = -1
        elif eq_n2 == 1 :
            bj = -2
        else :
            bj = 0

        if i >= grp -1 and len_a%2 ==0:
            bj = -2*b2jp1 + b2j + c2j
        else :
            bj = bj
            
        nrsd_nc.append (c2jp2)
        nrsd_n.append (bj)

    if len_a%2 != 0:
        nrsd_n.append ( -int(a_bin_org[-1]) + nrsd_nc[-1] )


    #nrsd +
    for i in range(0,grp) :
        c2j = nrsd_pc [i]
        
        b2j   = int(a_bin_org [2*i])
        b2jp1 = int(a_bin_org [2*i + 1])

        c2jp2 =  b2jp1 & (b2j | c2j)
        
        eq_p1  = (~b2jp1) & ( b2j ^ c2j )
        eq_n1  =   b2jp1  & ( b2j ^ c2j )
        eq_p2  = ( b2jp1 & (~b2j) & (~c2j) )  | ( (~b2jp1) & b2j & c2j )

        
        if eq_p1 == 1 :
            bj = 1 
        elif eq_n1 == 1 :
            bj = -1
        elif eq_p2 == 1 :
            bj = 2
        else :
            bj = 0

        if i >= grp -1 and len_a%2 ==0:
            bj = -2*b2jp1 + b2j + c2j
        else :
            bj = bj
            
        nrsd_pc.append (c2jp2)
        nrsd_p.append (bj)

    if len_a%2 != 0:
        nrsd_p.append ( -int(a_bin_org[-1]) + nrsd_pc[-1] )



    res_b  = 0
    res_bn = 0
    res_bp = 0
    for i in range(0,len(nrsd_b)) :
        res_b = 2**(2*i)*nrsd_b[i] + res_b
    
    for i in range(0,len(nrsd_n)) :
        res_bn = 2**(2*i)*nrsd_n[i] +res_bn

    for i in range(0,len(nrsd_p)) :
        res_bp = 2**(2*i)*nrsd_p[i] +res_bp

    return  a_bin_org[::-1], nrsd_b,res_b,nrsd_n,res_bn,nrsd_p,res_bp



#print(dec2nr4sd (6))

for i in range (-128,128) :
    
    a_bin_org, nrsd_b,res_b,nrsd_n,res_bn,nrsd_p,res_bp = dec2nr4sd (i)

    #print (i,a_bin_org, nrsd_b,res_b,nrsd_n,res_bn,nrsd_p,res_bp)
    if res_b != i or res_b != res_bn or res_b != res_bp:
        print (i,a_bin_org, nrsd_b,res_b,nrsd_n,res_bn)

    #if nrsd_n[-1] == 2 :
    #    print (i)



    
