clear;clc;close all;
video_base_path = '/media/magus/新加卷/ImageNet/train';
output_path = '/home/magus/sunx/output/VEB';
annotation_base_path = '/media/magus/新加卷/ImageNet/Annotations';
video_list = load('video_list.mat');
video_list = video_list.video_list;
% [recall, smT_IoU] = run([video_base_path,'/chosen0/'],'ILSVRC2015_train_00001000',[annotation_base_path,'/ILSVRC2015_VID_train_0000/'], output_path);
run_all(video_base_path,video_list,output_path,annotation_base_path)