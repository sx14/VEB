function cal_finish(path)
% create a file named 'finish' 
fp=fopen([path,'/finish'],'w');
fclose(fp);