# # v1.0 (2012/08/10) 解文件名中包含崩溃来源造成的bug，伴随进程列表加入分类文件夹
# # v0.9 (2012/05/03)先按MAC比例再按纪录比例, 对崩溃具体位置进行排序;字母大小写容错;具体定位导致mtcomm.dll崩溃原因,分类的dump文件夹命名规则为：进程名！mtcomm
# # v0.8 (2012/03/21) 修复MAC总数和按进程分类的MAC数不等BUG, 每次启动删除已存在的分类结果目录
# # v0.7 (2012/03/13) 按MAC统计总失败率和分模块的失败率,解析跳过src\common模块
# # v0.6 加入影响MAC数, 分类加入模块所属进程
# # v0.5 记录统计受影响MAC数目,只适用于2.6.1 和2.6.3 以后客户端版本
# # v0.4 通用版本
# # v0.1 Initial Version

function sort_array(input_array,secondary_array,indices){#dump_mac_sum,dump_line,idxes_2
	delete tmpidx;
	for (i in input_array) #i指的是数组下标，即数组中每个元素，对于dump_mac_sum是指文件名
		tmpidx[sprintf("%12s", input_array[i]),i] = i;
	num = asorti(tmpidx);#数组下标进行排序
	j = 0;
	# print length(input_array),num;
	for (i=1; i<=num; i++) {
		split(tmpidx[i], tmp, SUBSEP)#SUBSEP数组的分隔符
		indices[++j] = tmp[2]  # tmp[2] is the name
		# print "i = ",i,"tmp[2] = ",tmp[2],"tmp[1] = ",tmp[1]
		x = i;
		for(y=i ;y>1; y--){
			x = y;
			if(input_array[tmp[2]] == input_array[indices[y-1]])
				continue;
			else
				break;
		}
		for(y=x; y<i; y++)
		{
			#	print "secondary_array[tmp[2]] = ",secondary_array[tmp[2]],"secondary_array[indices[y]] =",secondary_array[indices[y]]
			if(secondary_array[tmp[2]]<secondary_array[indices[y]])
			{
				tmpname = indices[y];
				indices[y] = tmp[2];
				for(y = y+1; y<=i; y++)
				{
					tmpmane2 = 	indices[y];	
					indices[y] = tmpname;
					tmpname = tmpmane2;
				}
			}
		}
		#   print  "j = ",j,"indices[j] = ",indices[j]
	}
	return num;		
}

BEGIN{
	system("rm -f *.tlog");	
	client_version="0.0.0.0";
	IGNORECASE=1;  #字符串匹配时忽略大小写，IGNORECASE 的值不影响数组下标
}

{ 
	if(NR==1){#对于一个版本第一次读入，创建文件夹
		# print $0;
		idx=split($4,m,"\\");#分割后存入m，返回数组个数
		filename=m[idx];#crash_2.8.6.46Beta_20130806_001113500_00E04CE49F77_海派甜心-第12集
		# print filename;
		idx=split($4,n,"_");#D:\dump_analysis\2.8.3.66\crash_2.8.6.46Beta_20130806_001113500_00E04CE49F77_海派甜心-第12集
		client_version=n[3];
		directory_base_name=sprintf("crash_%s",client_version);
		cmd_line=sprintf("test -d %s",directory_base_name);	
		a=system(cmd_line); # 检查目录名是否已存在,返回命令退出状态，正确是0，错误非0		
		if(a) {		
			cmd_line=sprintf("mkdir crash_%s",client_version); # 如果目录不存在，创建该目录
			system(cmd_line);	
		}		
		cmd_line=sprintf("rm -fr crash_%s/*/*.log",client_version);#删除前一天的log
		system(cmd_line);		
	}
				
	if(FNR==1){#当前文件的第一行
		# print FILENAME
		idx=split(FILENAME,m,"/");
		file_name=m[idx];#第一行的最后一个字段作为名字
		# print file_name;
		idx=split(file_name,k,"_");
		if(idx==7)
		{
			split(k[7],suffix,".");
			if(suffix[1]=="k")
				mac_addr=k[5];
			else
				mac_addr="NULL";
		}
		else
			if(idx==6) 
				mac_addr=k[5];#文件名中包含MAC地址
			else
				mac_addr="NULL";
	
		# print file_name,mac_addr,current_proc;
		
		current_proc="";
		is_innerweb=0;				
	}
				
	if($1=="PROCESS_NAME:"){
		dump_process[tolower($2)]++;
		total_dump++;
		current_proc=tolower($2);
		dump_mac_proc[tolower($2),mac_addr]++;
		mac_addr_set[mac_addr]++;
		# print $2,mac_addr,dump_mac_proc[$2,mac_addr];
		if($2=="InnerWeb.exe")
			is_innerweb=1;
	}
		
	if($1=="IMAGE_NAME:"&&is_innerweb==0){
		
		if(dump_image_recorded[FILENAME]==0){
			idx=split($2,k,".");
			dump_img_idx=k[1]; 	# 去除后缀
			dump_image[dump_img_idx]++;	
			dump_image_belong_proc[dump_img_idx]=current_proc;
			dump_image_mac_set[dump_img_idx,mac_addr]++;
			#  print dump_img_idx,dump_image_belong_proc[dump_img_idx]=current_proc;
		}	
	}
	
	if($1=="ExceptionCode:"){
		error_code[FILENAME]=$2;
	}
	
	if($0=="Executable search path is: "){
		getline var;#下一行
		dump_operation_system[tolower(var)]++;
		dump_mac_operation_system[tolower(var),mac_addr]++;
	}

	# #v0.7 以后解析跳过common模块
	if(hitted[FILENAME]==0 && (index($7,":\\build")>0) && (index($7,"\\funshion\\rel\\src\\common\\socketinterface\\")>0 || index($7,"\\funshion\\rel\\src\\common\\")==0) && (( index($7,".cpp")>0 )||( index($7,".cxx")>0 ) || ( index($8,".cpp")>0 )||( index($8,".cxx")>0 )) && is_innerweb==0){
 		# print idx,mac_addr;
		# print k[0],k[1],k[2],k[3],k[4],k[5],k[6];
		dump_line[$6]++;#FunshionService!CFsTcpData::align+0xf
		if( (index($8,".cpp")>0)||( index($8,".cxx")>0 ) )
			dump_src[$6]=$7""$8;
		else
			dump_src[$6]=$7;
		#print dump_src[$6];
		dump_file[$6]=FILENAME;			
		dump_mac[$6,mac_addr]++;
		if(dump_mac[$6,mac_addr]==1)
			dump_mac_sum[$6]++;
		hitted[FILENAME]=1;		
		dump_error[$6]=error_code[FILENAME];
		if( (index($8,".cpp")>0)||( index($8,".cxx")>0 ) )
			dump_error_line_num[$6]=$10;
		else
			dump_error_line_num[$6]=$9;
		idx=split( $6, k , "!");
		dump_idx=k[1];
		dump_image[dump_idx]++;		
		dump_image_belong_proc[dump_idx]=current_proc;	  
		dump_image_mac_set[dump_idx,mac_addr]++; 	  
		dump_image_recorded[FILENAME]=1;	
		tlog_name=$6;	
		gsub(/\(\)/, "__", tlog_name);
		gsub(/::/, "_", tlog_name);
		sub_dir_name=tlog_name;
		cmd_line=sprintf("test -d %s/%s",directory_base_name,sub_dir_name);	
		a=system(cmd_line); # 检查目录名是否已存在
		if(a) {		
			cmd_line=sprintf("mkdir %s/%s",directory_base_name,sub_dir_name); # 如果目录不存在，创建该目录
			system(cmd_line);
		}	
	 	cmd_line=sprintf("cat \"%s\" >>%s/%s/%s.log",FILENAME,directory_base_name,sub_dir_name,tlog_name); # 加单引号为支持带括号的文件名
	 	system(cmd_line);
		split(FILENAME,dump_set,".txt");
		dump_name=dump_set[1];
		cmd_line=sprintf("unzip -o -q \"%s\"",dump_name); 
		system(cmd_line);
		idx_sum=split(dump_name,dump_set,"/");       	
		dump_file_name=dump_set[idx_sum];
		gsub(/\(/, "_", dump_file_name);
		gsub(/\)/, "_", dump_file_name);  	
		# print dump_file_name;
		cmd_line=sprintf("cat crash_dump.dmp >\"%s/%s/%s.dmp\"",directory_base_name,sub_dir_name,dump_file_name);
		# print cmd_line;
		system(cmd_line);   	
		cmd_line=sprintf("cat fsps.txt >\"%s/%s/%s.txt\"",directory_base_name,sub_dir_name,dump_file_name);
		# print cmd_line;
		system(cmd_line);
		
		cmd_line="test -e FunshionService.log";
		a=system(cmd_line);
		if(!a){
			cmd_line=sprintf("cat FunshionService.log >\"%s/%s/%s_FunshionService.log\"",directory_base_name,sub_dir_name,dump_file_name);
			system(cmd_line);  
		}
		
		cmd_line="test -e FunshionService.log";
		a=system(cmd_line);
		if(!a){
			cmd_line=sprintf("cat PreviousFunshionService.log >\"%s/%s/%s_PreviousFunshionService.log\"",directory_base_name,sub_dir_name,dump_file_name);
			system(cmd_line);  
		}
		
	}
	
	if($1=="MODULE_NAME:"&&is_innerweb==0){
		cur_module_name = $2;
		mtcomm_is_cpy = 0;
	}
	
	if(cur_module_name == "mtcomm" && mtcomm_is_cpy == 0 && is_innerweb==0){
		mtcomm_is_cpy = 1;
		# print "mtcomm 文件名为",FILENAME," "
		cmd_line=sprintf("test -d %s/%s!%s",directory_base_name,current_proc,cur_module_name);
		a=system(cmd_line); # 检查目录名是否已存在
		if(a) {	
			cmd_line=sprintf("mkdir %s/%s!%s",directory_base_name,current_proc,cur_module_name); # 如果目录不存在，创建该目录
			system(cmd_line);
		}       	
		cmd_line=sprintf("cat \"%s\" >>\"%s/%s!%s/%s.log\"",FILENAME,directory_base_name,current_proc,cur_module_name,cur_module_name); # 加单引号为支持带括号的文件名
		system(cmd_line);	  	
	    split(FILENAME,mtcomm_dump_set,".txt");
	    mtcomm_dump_name=mtcomm_dump_set[1];
	    cmd_line=sprintf("unzip -o -q \"%s\"",mtcomm_dump_name); 
	   	system(cmd_line);
	    idx_sum=split(mtcomm_dump_name,mtcomm_dump_set,"/");       	
	   	mtcomm_dump_file_name=mtcomm_dump_set[idx_sum];
	   	gsub(/\(/, "_", mtcomm_dump_file_name);
	    gsub(/\)/, "_", mtcomm_dump_file_name);  	
	   	# print dump_file_name;
	    cmd_line=sprintf("cat crash_dump.dmp >\"%s/%s!%s/%s.dmp\"",directory_base_name,current_proc,cur_module_name,mtcomm_dump_file_name);
	   	# print cmd_line;
	   	system(cmd_line);
	}
	#	print $4;	
}

END{		
	printf("风行客户端 %s 一共崩溃 %d 次，影响 %d 个MAC, 分类后的Dump见附件: \n\n",client_version,total_dump,length(mac_addr_set));
	for (k_1 in dump_mac_proc) {
		split(k_1,idx_1,SUBSEP); 
		proc_name=idx_1[1];
		mac=idx_1[2];
		#  print proc_name,mac,dump_mac_proc[proc_name,mac];
		dump_mac_set[proc_name]++;   
	}
	printf("|所属进程|崩溃条目数|条目比例|影响MAC数|MAC比例|\n");
	for( i in dump_process){
		printf("|%-20s:|\t%d|\t%8.2f%%|\t%d|\t%8.2f%%|\n",i,dump_process[i],dump_process[i]/total_dump*100,dump_mac_set[i],dump_mac_set[i]/length(dump_mac_proc)*100);
	}
	
	for (k_2 in dump_image_mac_set) {
		split(k_2,idx_2,SUBSEP); 
		img_name=idx_2[1];
		mac=idx_2[2];
		# print img_name,mac,dump_mac_proc[proc_name,mac];
		img_mac_set[img_name]++;   
	}
	array_num=sort_array(dump_image,img_mac_set,idxes);
	print "\n\n崩溃所在具体模块: 一共涉及 ",array_num, " 个模块\n\n"	
	printf("|模块|崩溃条目数|条目比例|影响MAC数|MAC比例|所属进程|\n");
	for (i=array_num; i>=1; i--) {
	 	printf("|%-20s:|\t%d|\t%8.2f%%|\t%d|\t%8.2f%%|%-20s|\n",idxes[i],dump_image[idxes[i]],dump_image[idxes[i]]/total_dump*100,img_mac_set[idxes[i]],img_mac_set[idxes[i]]/length(dump_mac_proc)*100,dump_image_belong_proc[idxes[i]]);	
	}
	
	# for (k_3 in dump_mac_operation_system) {
		# split(k_3,idx_3,SUBSEP); 
		# operation_system_name=idx_3[1];
		# mac=idx_3[2];
		# #  print proc_name,mac,dump_mac_proc[proc_name,mac];
		# operation_system_mac_set[operation_system_name]++;   
	# }
	# array_num=sort_array(dump_operation_system,operation_system_mac_set,idxes);
	# print "\n\n崩溃操作系统: 一共 ",array_num, " 类操作系统\n"	
	# printf("|操作系统名称|崩溃条目数|条目比例|影响MAC数|MAC比例|\n");
	# for (i=array_num; i>=1; i--) {
	 	# printf("|%-80s:|\t%d|\t%8.2f%%|\t%d|\t%8.2f%%|\n",idxes[i],dump_operation_system[idxes[i]],dump_operation_system[idxes[i]]/total_dump*100,operation_system_mac_set[idxes[i]],operation_system_mac_set[idxes[i]]/length(dump_mac_proc)*100);	
	# }
	array_num=sort_array(dump_mac_sum,dump_line,idxes_2);#idxes_2是排序完返回的结果
	print "\n\n崩溃具体位置: 一共 ",array_num, " 处\n"	
	j=0;
	for (i=array_num; i>=1; i--) {
		j++;
		split(idxes_2[i],idxes_2_name,"!");#idxes_2[i]为FunshionService！CFsUdpHandler_post_send+0x6c
		printf("(%d) %-20s崩溃次数:%d(%.2f%%), MAC:%d(%.2f%%)\t%s\t%s\t",j,idxes_2_name[1],dump_line[idxes_2[i]],dump_line[idxes_2[i]]/total_dump*100,dump_mac_sum[idxes_2[i]],dump_mac_sum[idxes_2[i]]/length(mac_addr_set)*100,idxes_2_name[2],dump_error[idxes_2[i]]);
		#	printf("(%d) %s\t%s\t崩溃次数:\t\t%d\t(%.2f%%)\n",j,idxes_2[i],dump_error[idxes_2[i]],dump_line[idxes_2[i]],dump_line[idxes_2[i]]/total_dump*100);
		printf("\t%s\t%s",dump_src[idxes_2[i]],dump_error_line_num[idxes_2[i]]);
		printf("\n");
	}
	

	
	#cmd_line=sprintf("tar -zcf %s.tar.gz %s/",directory_base_name,directory_base_name);
	#system(cmd_line);
}