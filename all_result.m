clear;clc;close all;
output_path = '/home/magus/sunx/output/VEB/result';
all_results = dir(fullfile(output_path,'*.mat'));
avg_result = zeros(10,3);
for i = 1:length(all_results)
    r_mat_file = all_results(i);
    r_mat = load(fullfile(output_path,r_mat_file.name));
    r_mat = r_mat.result;
    obj_num = size(r_mat.hit,1);
    obj_num = min(obj_num,10);
    avg_result(obj_num,1) = avg_result(obj_num,1) + 1;
    avg_result(obj_num,2) = avg_result(obj_num,2) + r_mat.recall;
    avg_result(obj_num,3) = avg_result(obj_num,3) + r_mat.smT_IoU;
end
avg_result(:,2) = avg_result(:,2) ./ avg_result(:,1);
avg_result(:,3) = avg_result(:,3) ./ avg_result(:,1);
avg_result
