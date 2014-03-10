#!/usr/bin/env python
# -*- coding: UTF-8 -*-
 
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email.MIMEImage import MIMEImage
 
from email.utils import COMMASPACE,formatdate
from email import encoders
 
import os,sys
import smtplib 
 

def send_mail(subject, html_name, files): 

    server={}
    server['name'] = 'mail.funshion.com'
    server['user'] = 'zhangchen'
    server['passwd'] = 'CheN882288+'
    fro = 'zhangchen@funshion.com' 
    to = ['zhangchen@funshion.com']
    # to = ['P2P-Kernel@funshion.com']
        
    msg = MIMEMultipart() 
    msg['From'] = fro 
    msg['Subject'] = subject 
    msg['To'] = COMMASPACE.join(to) #COMMASPACE==', ' 
    msg['Date'] = formatdate(localtime=True) 

    text2 = ''
    fh = open(html_name)
        
    for line in fh.readlines(): text2 += r'%s' % line
    fh.close()
    # print line
    
    msg.attach(MIMEText(text2,'plain','gbk')) 

    for file in files: 
        att = MIMEText(open(file, 'rb').read(), 'base64', 'gbk')  
        att["Content-Type"] = 'application/octet-stream'  
        att["Content-Disposition"] = 'attachment; filename="%s"' % os.path.basename(file)
        msg.attach(att)  

    smtp = smtplib.SMTP(server['name']) 
    smtp.login(server['user'], server['passwd']) 
    smtp.sendmail(fro, to, msg.as_string()) 
    smtp.close()

if __name__ == '__main__':
    version = sys.argv[1]
    rar_list=[]
    crash_file_rar_name='crash_'+version+'.rar'
    if os.path.isfile(crash_file_rar_name) and os.path.getsize(crash_file_rar_name)<20*1024*1024:
        rar_list.append(crash_file_rar_name)
    crash_file_rar_name='crash_'+version+'Beta.rar'
    if os.path.isfile(crash_file_rar_name) and os.path.getsize(crash_file_rar_name)<20*1024*1024:
        rar_list.append(crash_file_rar_name)

    subject="客户端内核 - 客户端崩溃分类统计: "+version
    content_name="crash_report_"+version+".txt"

	
    send_mail(subject,content_name,rar_list)
