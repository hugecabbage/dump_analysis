#!/usr/local/bin/python
#-*- coding: utf-8 -*-

import os,sys



if __name__ == "__main__":
    hostspath='C:\\Windows\\System32\\drivers\\etc\\hosts'
    hostspath2='C:\\Windows\\System32\\drivers\\etc\\hosts.txt'
    hostsconfigpath='D:\\dump_analysis\\src\\hosts.txt'
    f=open(hostsconfigpath,'r')
    f2=open(hostspath2,'w')
    while True:
        line=f.readline()
        if line=='':
            break
        f2.write(line)
    f.close()
    f2.close()
    os.remove(hostspath)
    os.rename(hostspath2,hostspath)
