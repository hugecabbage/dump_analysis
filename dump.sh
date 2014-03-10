dump_dir=/cygdrive/d/dump_analysis
source_dir=${dump_dir}/src
cd ${source_dir}

# cmd /c file_list.bat
while read version
do
	#cmd /c install_funshion.bat ${version}
	cmd /c dump_symchk.bat
	cmd /c ftp_dump.bat ${version}
    cmd /c dump_cdb.bat ${version}
	source_file=${dump_dir}/${version}/*.zip.txt
	dest_file=crash_report_${version}.txt
	awk -f dump_classified_stats_redmine.awk ${source_file} >${dest_file}
	unix2dos ${dest_file}
	cmd /c dump_rar.bat ${version}
	cmd /c dump_send_mail.bat ${version}
done < dir_list_tmp.ini

# while read version
# do
    # echo $line
	# echo "2"
# done < dir_list_tmp.ini
# versions=("2.8.3.38" "2.8.6.42" "2.8.6.34")
# for((i=0;i<${#versions[@]};i++))
# {
	# python install_funshion.py ${version}
	# cmd /c dump_symchk.bat
	# cmd /c dump_cdb.bat ${versions[i]}
	# source_file=/cygdrive/E/document/dump_files/${versions[i]}/*.zip.txt
	# dest_file=crash_report_${versions[i]}.txt
	# awk -f dump_classified_stats_redmine_test.awk ${source_file} >${dest_file}
	# unix2dos ${dest_file}
# }



