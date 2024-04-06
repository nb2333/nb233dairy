# -*- coding: utf-8 -*-

import pandas as pd
import os

class module :
    #here, we define port as dictionary
    #the port name as the key
    #however the port info we define as follows:
    #verilog direction : input/output/inout
    #the port position : S: south N: notrh W: west E: east
    #the port width   : 1 to others 
    #the connection : it's a dic, contains several options,such as 
    #   name,[portnames]

    port = {}

    #port that have done connections 
    #key is port name, the info :
    #   the pair module 
    #   the pair port
    #   the pair cost, when there is options, we choose the best. which means the cost is minimum.

    #we only store the input or the inout
    #because the input is only one, however the inout, we should deal with it later
    port_done = {}


    #the module name and level, level 0 means top module.
    def __init__ (self,name:str,inst_name:str,short_name:str,level:int =1,position= (0,0) ) :
        self.name      = name 
        self.level     = level
        self.inst_name = inst_name
        
        if short_name == '' :
            self.short_name = short_name 
        else :
            self.short_name = inst_name

        self.position   = position 

        print("!!!\nCreate Module: " + self.name  + '\nInst name: ' + self.inst_name \
                + '\nPostion: ' + str(self.position) + '\nLevel: '+ str(self.level) + '\n!!!\n' )


    #here comes the question, what info should the port csv contains :
    #   portname
    #   direction
    #   width = []
    #   postion(or other information can make us decide the connection. If there is some options we can choose)
    #  connection options, we define it as this 'moudule name, port \n module name, port'
    def genPortInfo(self,df_port_csv) : 
        print ('!!! Now get the port information !!!')

        for index,row in df_port_csv.iterrows() :
            port_name = row['portname']
            port_dir  = row['direction']
            port_position = row['position']
            port_width = row ['width']
            row_connection = row['connection']
            
            port_connection = {}

            row_connection = row_connection.split('\n')

            for connect in row_connection :
                connect = connect.split(',')
                conn_module = connect[0]
                conn_port   = connect[1]

                #print(conn_module,conn_port)
                #print(port_connection)
                
                if conn_module in port_connection :
                    port_connection [conn_module].append(conn_port)
                else :
                    port_connection [conn_module] = [conn_port]

            if port_name not in self.port :
                self.port [port_name]  = {}
                self.port [port_name]['dir']        = port_dir
                self.port [port_name]['position']   = port_position
                self.port [port_name]['width']      = port_width
                self.port [port_name]['connect_option'] = port_connection.copy()

        print ( self.name + ' gets the port informatiion done!\n')
  

    POSSUCCEED = {(0,1) : 'SN' , (0,-1):'NS' , (1,0) : 'WE', (-1,0):'EW'}


    #=============================#
    def calModuleCost (mod_a_pos, mod_a_port_pos, mod_b_pos, mod_b_port_pos) :
        mod_a_pos_x , mod_a_pos_y = mod_a_pos
        mod_b_pos_x , mod_b_pos_y = mod_b_pos
        
        ab_x = mod_a_pos_x - mod_b_pos_x
        ab_y = mod_a_pos_y - mod_b_pos_y

        ab_succeed_mod = POSSUCCEED( (ab_x,ab_y) ) 
        
        if ab_x == 0 and ab_y ==0 :
            return 1
        elif ab_succeed_mod == (mod_a_port_pos,mod_b_port_pos) :
            return 1
        else :
            return 1000


    def topModuleCost (top_x_index,top_y_index,top_port_pos,mod_pos,mod_port_pos) :
        mod_pos_x,mod_pos_y = mod_pos

        if mod_pos_x == top_x_index  and mod_port_pos == 'E' :
            return 1
        elif mod_pos_x == 0  and mod_port_pos == 'W' :
            return 1
        elif mod_pos_y == top_y_index and mod_port_pos == 'N' :
            return 1
        elif mod_pos_y == 0 and mod_port_pos == 'S' :
            return 1
        else :
            return 1000

    #########
    ##connect the port of this module to another module
    def port_connect (self, mod_a: module ) :
        
        mod_a_port = mod_a.port
        mod_a_name = mod_a.name
    
        for port_name in self.port :
            port_info    = self.port[port_name]

            if port_name in self.port_done :
                connect_cost = self.port_done [port_name]['cost']
            else :
                connect_cost = 999

            if  (mod_a_name not in port_info['connect_option'] or port_info['dir'] == 'output') and self.level > 0 :
                continue
            else :
                mod_a_position  = mod_a.position
                mod_a_ports     = port_info['connect_option'][mod_a.name] 
                
                for mod_a_port_name in mod_a_ports :
                    if self.level == 0 :
                        this_cost = topModuleCost(self.postion[0], self.postion[1], port_info['position'], mod_a_position ,mod_a.port[mod_a_ports]['position'] ) 
    




                     

            

###########################################################################################

def readcsv (file_path) :
    file_path = os.path.join(file_path)
    xls = pd.ExcelFile(file_path)
    
    df = {}

    for sheet_name  in xls.sheet_names : 
        df[sheet_name] = xls.parse(sheet_name) 

    return df



csv_path = 'connect_test.xlsx'

df_module = readcsv(csv_path)

df_obj = []
i =0 
for module_name in df_module :
    df = df_module[module_name]
    df_obj_u = module(name=module_name, inst_name = 'U_'+ module_name.upper(), short_name=module_name, position = (0,i) )
    df_obj_u.genPortInfo(df)
    i=i +1
    print(df_obj_u.port)

    df_obj.append(df_obj_u)







 
























































