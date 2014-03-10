#-*- coding:utf-8 -*-
#-------------------------------------------------------------------------------
# Name:     
# Purpose:
#
# Author:      wangjk
#
# Created:     22/06/2013
# Copyright:   (c) wangjk 2013
# Licence:     <your licence>
#-------------------------------------------------------------------------------
#!/usr/bin/env python
import win32con
import win32gui
import win32process
import webbrowser
import win32api
import subprocess
import time,os,sys,stat
from _winreg import * 
from ftp_lib import MYFTP,debug_print,deal_error

def delete_file_folder(src):
    if os.path.isfile(src):
        try:
            os.remove(src)
        except:
            pass
    elif os.path.isdir(src):
        for item in os.listdir(src):
            itemsrc=os.path.join(src,item)
            delete_file_folder(itemsrc) 
        try:
            os.rmdir(src)
        except:
            pass

def download_build(build_dir,version):  
    hostaddr = '192.168.1.81' 
    username = 'anonymous' 
    password = '' 
    port  =  21   
    sub_version1=version[0:5]
    #print sub_version1
    sub_version2='Build'+version[6:]
    rootdir_local  = build_dir
    rootdir_remote = os.sep+'Build'  + os.sep  + 'Funshion' + os.sep + sub_version1 + os.sep + sub_version2 + os.sep     
    #print rootdir_remote
    f = MYFTP(hostaddr, username, password, rootdir_remote, port)  
    f.login()  
    print rootdir_local
    print rootdir_remote
    f.download_files(rootdir_local, rootdir_remote)  
    
def get_build_name(dir):
    file_list = os.listdir(dir)  
    for file_name in file_list:
        if 'FunshionInstall' in file_name and '.exe' in file_name and 'Beta' in file_name:
            return file_name
    for file_name in file_list:
        if 'FunshionInstall' in file_name and '.exe' in file_name:
            return file_name
    print 'get build name error!'
    return '0'

def get_hwnds_for_pid (pid):
    def callback (hwnd, hwnds):
        if win32gui.IsWindowVisible (hwnd) and win32gui.IsWindowEnabled (hwnd):
            _, found_pid = win32process.GetWindowThreadProcessId (hwnd)
            if found_pid == pid:
                hwnds.append (hwnd)
            return True
    hwnds = []
    win32gui.EnumWindows (callback, hwnds)
    return hwnds

def click_at_pos(hwnd,point):
    old_point=point
    new_point=win32gui.ClientToScreen(hwnd,old_point)
    win32api.SetCursorPos(new_point)
    win32api.mouse_event(win32con.MOUSEEVENTF_LEFTDOWN,0,0,0,0)
    win32api.mouse_event(win32con.MOUSEEVENTF_LEFTUP,0,0,0,0)

def getFunshionInstallPath():        
    path = 'SOFTWARE\\Wow6432Node\\Funshion\\Funshion'
    funshion=OpenKey(HKEY_LOCAL_MACHINE, path)
    path,type=QueryValueEx(funshion,"Install Path")
    return path

def getFunshionVersion():
    path = 'SOFTWARE\\Wow6432Node\\Funshion\\Funshion'
    funshion=OpenKey(HKEY_LOCAL_MACHINE, path)
    version,type=QueryValueEx(funshion,"Version")
    return version

def install_main(path,funshionname):
    # runpath='D:\\dump_analysis\\src\\funshion_build\\'+funshionname+' /s'
    # print runpath
    # subprocess.Popen(runpath)
    runpath='cscript '+'install.vbs ' + funshionname
    print runpath
    os.system(runpath)
    time.sleep(30)
    process='taskkill /f /im '+funshionname
    os.system(process)
    os.system('taskkill /f /im Funshion.exe')
    os.system('taskkill /f /im FunshionService.exe')
    time.sleep(3)
	

def uninstall_main():
    installpath=getFunshionInstallPath()
    version=getFunshionVersion()
    runpath=installpath+'\Uninstall.exe'+' /S'
    if version[0:5]=='2.8.6':
        funshion = subprocess.Popen (runpath)
        time.sleep(5)
        for hwnd in get_hwnds_for_pid(funshion.pid):
            print hwnd, "=>", win32gui.GetWindowText(hwnd)
            time.sleep(1)
            if win32gui.GetWindowText(hwnd) == 'MainWindow':
                funshion_hwnd=hwnd
	
        win32gui.SetForegroundWindow(funshion_hwnd)
        click_at_pos(funshion_hwnd,(247,375))
        time.sleep(10)
        click_at_pos(funshion_hwnd,(353,375))
        
    elif version[0:5]=='2.8.3':
        subprocess.Popen (runpath)
    time.sleep(30)
	
if __name__=='__main__':
#     installpath = "C:\\Program Files (x86)\\Funshion Online\\2.8.6.51"
    build_dir = './funshion_build'
    delete_file_folder(build_dir)
    version = sys.argv[1]
    print version
#     version = '2.8.3.41'
    download_build(build_dir,version)
    build_name=get_build_name(build_dir)
    build_full_name=build_dir + '/' + build_name
    os.chmod(build_full_name, stat.S_IRWXU|stat.S_IRGRP|stat.S_IROTH)
    if(build_name != '0'):
        # uninstall_main()
        install_main(build_dir,build_name)
