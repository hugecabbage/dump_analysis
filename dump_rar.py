#!/usr/local/bin/python
#-*- coding: utf-8 -*-

import os, datetime,sys



if __name__ == "__main__":
    version = sys.argv[1]
    crash_file_dir='crash_'+version+'Beta'
    if os.path.isdir(crash_file_dir):
        os.system(r'rar a -r %s.rar %s' % (crash_file_dir, crash_file_dir))
    crash_file_dir='crash_'+version
    if os.path.isdir(crash_file_dir):
        os.system(r'rar a -r %s.rar %s' % (crash_file_dir, crash_file_dir))
