# coding=UTF-8
#-------------------------------------------------------------------------------
# Name:        模块1
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
    # 配置如下变量  
    hostaddr = '192.168.1.90' # ftp地址  
    username = 'anonymous' # 用户名  
    password = '' # 密码  
    port  =  21   # 端口号
    # version = "2.8.3.38" # 版本号
    version = sys.argv[1]
    print 'version:' + version
    rootdir_local  = '../' + version + os.sep # 本地目录
    rootdir_remote = os.sep+'log'  + os.sep  + time_dir + os.sep + version + os.sep      # 远程目录  
    print rootdir_remote
    # rootdir_remote = os.sep+'log'  + os.sep  + time_dir + os.sep       # 远程目录 
    f = MYFTP(hostaddr, username, password, rootdir_remote, port)  
    f.login()  
    f.download_files(rootdir_local, rootdir_remote)  
      
    timenow  = time.localtime()  
    datenow  = time.strftime('%Y-%m-%d', timenow)  
    logstr += " - %s backup succeed\n" %datenow  
    debug_print(logstr)  
      
    file.write(logstr)  
    file.close()
