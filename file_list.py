# coding=UTF-8
#-------------------------------------------------------------------------------
# Name:        ģ��1
# Purpose:
#
# Author:      wangjk
#
# Created:     22/06/2013
# Copyright:   (c) wangjk 2013
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python


import os,sys,string,datetime,time 
from ftp_lib import MYFTP,debug_print,deal_error




if __name__ == '__main__':  
    file = open("d:/log.txt", "a")  
    timenow  = time.localtime()  
    datenow  = time.strftime('%Y-%m-%d', timenow)  
    logstr = datenow
    now = datetime.datetime.now()
    delta=datetime.timedelta(days=1)
    n_days = now - delta
    time_dir=n_days.strftime('%Y%m%d')
    # time_dir='20130719'
    # �������±���  
    hostaddr = '192.168.1.90' # ftp��ַ  
    username = 'anonymous' # �û���  
    password = '' # ����  
    port  =  21   # �˿ں�

    rootdir_local  = '../' # ����Ŀ¼
    # rootdir_remote = os.sep+'log'  + os.sep  + time_dir + os.sep + version + os.sep      # Զ��Ŀ¼  
    rootdir_remote = os.sep+'log'  + os.sep  + time_dir + os.sep       # Զ��Ŀ¼ 
    f = MYFTP(hostaddr, username, password, rootdir_remote, port)  
    f.login()  
    
    dir_list=[]
    dir_list=f.get_dir_list()    
    file_dir = open('dir_list_tmp.ini', 'w')
    dir_list_len=len(dir_list)
    # print dir_list_len
    # file_dir.write(str(dir_list_len)+"\n")
    for dir in dir_list:
        if dir != '3.0.0.10' and dir != '2.8.9.7' and dir !='2.8.9.10':
            file_dir.write(dir+"\n")
    file_dir.close()


    timenow  = time.localtime()  
    datenow  = time.strftime('%Y-%m-%d', timenow)  
    logstr += " - %s get file list succeed\n" %datenow  
    # debug_print(logstr)  
      
    file.write(logstr)  
    file.close()

