import os
import pandas as pd
import filecmp

def fileCompare(file1,file2) :
    return filecmp.cmp(file1, file2, shallow=False)


file_path_array = ['','','']

def genFileDic (file_path_array) :
    file_dics = {}
    
    for file_path in file_path_array :
        for (dirpath,dirnames,filenames) in os.walk(file_path) :
            for filename in filenames :
                file_org_path = os.path.join(dirpath,filename)
                
                if filename not in file_dics :
                    file_dics[filename] = {}
                    file_dics[filename]['cnt'] = 0
    
                file_cnt =  file_dics [filename] ['cnt']
    
                file_dics [filename] [file_cnt] = file_org_path
                file_dics [filename] ['cnt'] = file_cnt + 1
    
    return file_dics


def unitDicClassic (file_dic,filename) :
    file_cnt = file_dic ['cnt']
    
    class_arry = []
    
    max_same_length = 1

    for i in range (0,file_cnt) :
        file_path = file_dic [i]
       
        if len(class_arry) == 0 :
            class_arry.append [ [file_path] ]
        else :
            file_same = False
            arry_cnt = 0 
            for class_u in class_arry :
                file_path1 = class_u[0]

                file_same =  fileCompare(file_path1,file_path)

                if file_same :
                    class_arry [arry_cnt].append(file_path)
                    if max_same_length < len(class_arry [arry_cnt]) :
                        max_same_length = len(class_arry[arry_cnt])

                    break
            
            if file_same == False :
                class_arry.append [ [file_path] ]


        file_dic ['max_same'] = max_same_length
        file_dic ['class_grp'] =class_arry.copy
        
    return file_dic


def dicClassify (file_dics) :
    new_dics = {}
    for file_name in file_dics :
        new_dic = unitDicClassic(file_dics[file_name])
        
        new_dics[file_name] = new_dic

    return new_dics



def genExcel (file_dics) :
    #there at least two is same
    common_dics       = {} 

    #the file is uniq
    single_uniq_dic   = {}

    #there is more than one,but all uniq
    all_uniq_dics     = {}

    for file_name in file_dics :
        unit_dic =  file_dics [file_name]

        if  unit_dic ['max_same']  > 1 :
            common_dics [file_name] = unit_dic.copy()
        
        elif  unit_dic ['cnt'] == 1 :
            single_uniq_dic [file_name] = unit_dic.copy()

        else :
            all_uniq_dics [file_name] = unit_dic.copy()




    comon_dic_list   = []
    single_uniq_list = []
    all_uniq_list    = []

    for  file_name in common_dics  :
        common_dic = common_dics[file_name]

        max_same   = common_dic['max_same']
        class_arry = common_dic['class_grp']
        
        class_arry_sort = []
        for i in range (max_same,0,-1) :
            for class_u in class_arry :
                if len(class_u) == i :
                    class_arry_sort.append(class_u)

        

    return 0