# # v1.0 (2012/08/10) ���ļ����а���������Դ��ɵ�bug����������б��������ļ���
# # v0.9 (2012/05/03)�Ȱ�MAC�����ٰ���¼����, �Ա�������λ�ý�������;��ĸ��Сд�ݴ�;���嶨λ����mtcomm.dll����ԭ��,�����dump�ļ�����������Ϊ����������mtcomm
# # v0.8 (2012/03/21) �޸�MAC�����Ͱ����̷����MAC������BUG, ÿ������ɾ���Ѵ��ڵķ�����Ŀ¼
# # v0.7 (2012/03/13) ��MACͳ����ʧ���ʺͷ�ģ���ʧ����,��������src\commonģ��
# # v0.6 ����Ӱ��MAC��, �������ģ����������
# # v0.5 ��¼ͳ����Ӱ��MAC��Ŀ,ֻ������2.6.1 ��2.6.3 �Ժ�ͻ��˰汾
# # v0.4 ͨ�ð汾
# # v0.1 Initial Version

function sort_array(input_array,secondary_array,indices){#dump_mac_sum,dump_line,idxes_2
	delete tmpidx;
	for (i in input_array) #iָ���������±꣬��������ÿ��Ԫ�أ�����dump_mac_sum��ָ�ļ���
		tmpidx[sprintf("%12s", input_array[i]),i] = i;
	num = asorti(tmpidx);#�����±��������
	j = 0;
	# print length(input_array),num;
	for (i=1; i<=num; i++) {
		split(tmpidx[i], tmp, SUBSEP)#SUBSEP����ķָ���
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
	IGNORECASE=1;  #�ַ���ƥ��ʱ���Դ�Сд��IGNORECASE ��ֵ��Ӱ�������±�
}

{ 
	if(NR==1){#����һ���汾��һ�ζ��룬�����ļ���
		# print $0;
		idx=split($4,m,"\\");#�ָ�����m�������������
		filename=m[idx];#crash_2.8.6.46Beta_20130806_001113500_00E04CE49F77_��������-��12��
		# print filename;
		idx=split($4,n,"_");#D:\dump_analysis\2.8.3.66\crash_2.8.6.46Beta_20130806_001113500_00E04CE49F77_��������-��12��
		client_version=n[3];
		directory_base_name=sprintf("crash_%s",client_version);
		cmd_line=sprintf("test -d %s",directory_base_name);	
		a=system(cmd_line); # ���Ŀ¼���Ƿ��Ѵ���,���������˳�״̬����ȷ��0�������0		
		if(a) {		
			cmd_line=sprintf("mkdir crash_%s",client_version); # ���Ŀ¼�����ڣ�������Ŀ¼
			system(cmd_line);	
		}		
		cmd_line=sprintf("rm -fr crash_%s/*/*.log",client_version);#ɾ��ǰһ���log
		system(cmd_line);		
	}
				
	if(FNR==1){#��ǰ�ļ��ĵ�һ��
		# print FILENAME
		idx=split(FILENAME,m,"/");
		file_name=m[idx];#��һ�е����һ���ֶ���Ϊ����
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
				mac_addr=k[5];#�ļ����а���MAC��ַ
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
			dump_img_idx=k[1]; 	# ȥ����׺
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
		getline var;#��һ��
		dump_operation_system[tolower(var)]++;
		dump_mac_operation_system[tolower(var),mac_addr]++;
	}

	# #v0.7 �Ժ��������commonģ��
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
		a=system(cmd_line); # ���Ŀ¼���Ƿ��Ѵ���
		if(a) {		
			cmd_line=sprintf("mkdir %s/%s",directory_base_name,sub_dir_name); # ���Ŀ¼�����ڣ�������Ŀ¼
			system(cmd_line);
		}	
	 	cmd_line=sprintf("cat \"%s\" >>%s/%s/%s.log",FILENAME,directory_base_name,sub_dir_name,tlog_name); # �ӵ�����Ϊ֧�ִ����ŵ��ļ���
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
		# print "mtcomm �ļ���Ϊ",FILENAME," "
		cmd_line=sprintf("test -d %s/%s!%s",directory_base_name,current_proc,cur_module_name);
		a=system(cmd_line); # ���Ŀ¼���Ƿ��Ѵ���
		if(a) {	
			cmd_line=sprintf("mkdir %s/%s!%s",directory_base_name,current_proc,cur_module_name); # ���Ŀ¼�����ڣ�������Ŀ¼
			system(cmd_line);
		}       	
		cmd_line=sprintf("cat \"%s\" >>\"%s/%s!%s/%s.log\"",FILENAME,directory_base_name,current_proc,cur_module_name,cur_module_name); # �ӵ�����Ϊ֧�ִ����ŵ��ļ���
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
	printf("���пͻ��� %s һ������ %d �Σ�Ӱ�� %d ��MAC, ������Dump������: \n\n",client_version,total_dump,length(mac_addr_set));
	for (k_1 in dump_mac_proc) {
		split(k_1,idx_1,SUBSEP); 
		proc_name=idx_1[1];
		mac=idx_1[2];
		#  print proc_name,mac,dump_mac_proc[proc_name,mac];
		dump_mac_set[proc_name]++;   
	}
	printf("|��������|������Ŀ��|��Ŀ����|Ӱ��MAC��|MAC����|\n");
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
	print "\n\n�������ھ���ģ��: һ���漰 ",array_num, " ��ģ��\n\n"	
	printf("|ģ��|������Ŀ��|��Ŀ����|Ӱ��MAC��|MAC����|��������|\n");
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
	# print "\n\n��������ϵͳ: һ�� ",array_num, " �����ϵͳ\n"	
	# printf("|����ϵͳ����|������Ŀ��|��Ŀ����|Ӱ��MAC��|MAC����|\n");
	# for (i=array_num; i>=1; i--) {
	 	# printf("|%-80s:|\t%d|\t%8.2f%%|\t%d|\t%8.2f%%|\n",idxes[i],dump_operation_system[idxes[i]],dump_operation_system[idxes[i]]/total_dump*100,operation_system_mac_set[idxes[i]],operation_system_mac_set[idxes[i]]/length(dump_mac_proc)*100);	
	# }
	array_num=sort_array(dump_mac_sum,dump_line,idxes_2);#idxes_2�������귵�صĽ��
	print "\n\n��������λ��: һ�� ",array_num, " ��\n"	
	j=0;
	for (i=array_num; i>=1; i--) {
		j++;
		split(idxes_2[i],idxes_2_name,"!");#idxes_2[i]ΪFunshionService��CFsUdpHandler_post_send+0x6c
		printf("(%d) %-20s��������:%d(%.2f%%), MAC:%d(%.2f%%)\t%s\t%s\t",j,idxes_2_name[1],dump_line[idxes_2[i]],dump_line[idxes_2[i]]/total_dump*100,dump_mac_sum[idxes_2[i]],dump_mac_sum[idxes_2[i]]/length(mac_addr_set)*100,idxes_2_name[2],dump_error[idxes_2[i]]);
		#	printf("(%d) %s\t%s\t��������:\t\t%d\t(%.2f%%)\n",j,idxes_2[i],dump_error[idxes_2[i]],dump_line[idxes_2[i]],dump_line[idxes_2[i]]/total_dump*100);
		printf("\t%s\t%s",dump_src[idxes_2[i]],dump_error_line_num[idxes_2[i]]);
		printf("\n");
	}
	

	
	#cmd_line=sprintf("tar -zcf %s.tar.gz %s/",directory_base_name,directory_base_name);
	#system(cmd_line);
}