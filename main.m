clear;clc;close all;
video_base_path = '/media/sunx/Data/ImageNet3/train';
output_path = '/home/sunx/output/VEB';
annotation_base_path = '/media/sunx/Data/ImageNet3/Annotations';
mid_result_path = '/media/sunx/Data/ImageNet3/mid_result';
time_table = run_all1(video_base_path,mid_result_path,output_path,annotation_base_path);
frame_time_cost = double(sum(time_table(:,1))) / double(sum(time_table(:,2)));
fprintf('avg time cost : %.2f s.', frame_time_cost);
save('VEB_time_10_video.mat',time_table);