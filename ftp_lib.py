# coding=UTF-8
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

from ftplib import FTP  
import os,sys,string,datetime,time  
import socket  

class MYFTP:  
    def __init__(self, hostaddr, username, password, remotedir, port=21):  
        self.hostaddr = hostaddr  
        self.username = username  
        self.password = password  
        self.remotedir  = remotedir  
        self.port     = port  
        self.ftp      = FTP()  
        self.file_list = []  
        self.dir_list = []  
        # self.ftp.set_debuglevel(2)  
    def __del__(self):  
        self.ftp.close()  
        # self.ftp.set_debuglevel(0)  
    def login(self):  
        ftp = self.ftp  
        try:   
            timeout = 60  
            socket.setdefaulttimeout(timeout)  
            ftp.set_pasv(True)  
            print 'start to connect %s' %(self.hostaddr)  
            ftp.connect(self.hostaddr, self.port)  
            print 'connect to %s succeed' %(self.hostaddr)  
            print 'start to login to %s' %(self.hostaddr)  
            ftp.login(self.username, self.password)  
            print 'login to %s succeed' %(self.hostaddr)  
            debug_print(ftp.getwelcome())  
        except Exception:  
            deal_error("connect or login fail")  
        try:  
            ftp.cwd(self.remotedir)  
        except(Exception):  
            deal_error('cwd fail')  
  
    def is_same_size(self, localfile, remotefile):  
        try:  
            remotefile_size = self.ftp.size(remotefile)  
        except:  
            remotefile_size = -1  
        try:  
            localfile_size = os.path.getsize(localfile)  
        except:  
            localfile_size = -1  
        debug_print('localfile_size:%d  remotefile_size:%d' %(localfile_size, remotefile_size),)  
        if remotefile_size == localfile_size:  
            return 1  
        else:  
            return 0  
    def download_file(self, localfile, remotefile):  
        if self.is_same_size(localfile, remotefile):  
            debug_print('%s   the same file ,no need to download' %localfile)  
            return  
        else:  
            debug_print('>>>>>>>>>>>>download file %s ... ...' %localfile)  
        #return  
        file_handler = open(localfile, 'wb')  
        self.ftp.retrbinary('RETR %s'%(remotefile), file_handler.write)  
        file_handler.close()  
  
    def download_files(self, localdir='./', remotedir='./'):  
        try:  
            self.ftp.cwd(remotedir)  
        except:  
            debug_print('dir %s does not exist go on...' %remotedir)  
            return  
        if not os.path.isdir(localdir):  
            os.makedirs(localdir)  
        debug_print('cwd to %s' %self.ftp.pwd())  
        self.file_list = []  
        self.ftp.dir(self.get_file_list)  
        remotenames = self.file_list  
        # print(remotenames)  
 
        for item in remotenames:  
            filetype = item[0]  
            filename = item[1]  
            local = os.path.join(localdir, filename)  
            if filetype == 'd':  
                self.download_files(local, filename)  
            elif filetype == '-':  
                self.download_file(local, filename)  
        self.ftp.cwd('..')  
        debug_print('return last level dir %s' %self.ftp.pwd())  
    def upload_file(self, localfile, remotefile):  
        if not os.path.isfile(localfile):  
            return  
        if self.is_same_size(localfile, remotefile):  
            debug_print('skip the same: %s' %localfile)  
            return  
        file_handler = open(localfile, 'rb')  
        self.ftp.storbinary('STOR %s' %remotefile, file_handler)  
        file_handler.close()  
        debug_print('sended: %s' %localfile)  
    def upload_files(self, localdir='./', remotedir = './'):  
        if not os.path.isdir(localdir):  
            return  
        localnames = os.listdir(localdir)  
        self.ftp.cwd(remotedir)  
        for item in localnames:  
            src = os.path.join(localdir, item)  
            if os.path.isdir(src):  
                try:  
                    self.ftp.mkd(item)  
                except:  
                    debug_print('dir exist %s' %item)  
                self.upload_files(src, item)  
            else:  
                self.upload_file(src, item)  
        self.ftp.cwd('..')  
  
    def get_file_list(self, line):  
        ret_arr = []  
        file_arr = self.get_filename(line)  
        # print file_arr
        if file_arr[1] not in ['.', '..']:  
            self.file_list.append(file_arr)  
              
    def get_filename(self, line):  
        pos = line.rfind(':')  
        while(line[pos] != ' '):  
            pos += 1  
        while(line[pos] == ' '):  
            pos += 1  
        file_arr = [line[0], line[pos:]]  
        return file_arr  

    def get_dir_list(self):
        self.ftp.dir(self.get_file_list)  
        remotenames = self.file_list  
        # print(remotenames)  
 
        for item in remotenames:  
            filetype = item[0]  
            filename = item[1]  
            if filetype == 'd' and "." in filename and "2.8.6.34" not in filename:  
                self.dir_list.append(filename)  
        # print self.dir_list
        return self.dir_list

def debug_print(s):  
    print (s)  
def deal_error(e):  
    timenow  = time.localtime()  
    datenow  = time.strftime('%Y-%m-%d', timenow)  
    logstr = '%s get error: %s' %(datenow, e)  
    debug_print(logstr)  
    file.write(logstr)  
    sys.exit()  
  
