#-*- coding:utf-8 -*-

import os
import sys
from _winreg import * 

def getFunshionInstallPath():        
    path = 'SOFTWARE\\Wow6432Node\\Funshion\\Funshion'
    funshion=OpenKey(HKEY_LOCAL_MACHINE, path)
    path,type=QueryValueEx(funshion,"Install Path")
    return path

if __name__ == "__main__":
    installpath=getFunshionInstallPath()
    installpath=installpath.replace("\\","\\\\")
    file_dir = open('install_path.ini', 'w')
    # file_dir.write('"'+installpath+'\"'+'\n')
    file_dir.write(installpath+'\n')
    file_dir.close()