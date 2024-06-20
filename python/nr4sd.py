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
    a_bin = dec2bin(a)

    # calculate grp
    len_a = len(a_bin)

    if len_a%2 == 0 :
        grp = int(len_a/2)
    else :
        grp = math.floor(len_a/2) +1

    full_a = 2*grp

    if full_a > len_a :
        a_bin = a_bin[0] + a_bin

    ###===========================#
    print(a_bin)
    a_bin = a_bin[::-1]
    
    nrsd_n = []
    nrsd_c = []
    nrsd_b = []

    for i in range(0,grp) :

        
        if i == 0 :
            n2j   = int( a_bin[2*i]   )
            c2jp1 = 0

            n2jp1 = int( a_bin[2*i +1])
            c2jp2 = int( a_bin[2*i +1])

            c2j = 0

        else :

            c2j   = nrsd_c [2*(i-1)+1]
            n2j   = int( a_bin[2*i])^ nrsd_c [2*(i-1)+1]
            c2jp1 = int( a_bin[2*i])& nrsd_c [2*(i-1)+1]

            n2jp1 = int( a_bin[2*i +1]) ^ c2jp1
            
            c2jp2 = int( a_bin[2*i +1]) | c2jp1
            


        nrsd_n.append(n2j )
        nrsd_n.append(n2jp1)

        nrsd_c.append(c2jp1)
        nrsd_c.append(c2jp2)

        bj = -2*n2jp1 + n2j

        print(a_bin[2*i +1],a_bin[2*i],c2j)
        print(bj,c2jp2)
        
        nrsd_b.append(bj)                         

    res_b = 0
    for i in range(0,len(nrsd_b)) :
        res_b = 2**(2*i)*nrsd_b[i] +res_b
    
    return nrsd_b,res_b



print(dec2nr4sd (-13))


