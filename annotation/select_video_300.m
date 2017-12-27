close all; close all; clear; clc;
base_path = '/home/sunx/dataset/ImageNet/Annotations';
video_package_list = ['ILSVRC2015_VID_train_0000';'ILSVRC2015_VID_train_0001';'ILSVRC2015_VID_train_0002';'ILSVRC2015_VID_train_0003'];
file_name = 'annotation_info.mat';
if ~exist(file_name,'file')
    annotation_info = get_object_num(base_path, video_package_list, 4000);
    save(file_name, 'annotation_info');
else
    annotation_file = load(file_name);
    annotation_info  = annotation_file.annotation_info;
end

temp_annotations = cell(10,4000);
for i = 1:size(annotation_info,1)
    counter = 1;
    for j = 1:size(annotation_info,2)
        a = annotation_info{i,j};
        if ~isempty(a) && a.length <= 300
            temp_annotations{i,counter} = a;
            counter = counter + 1;
        end
    end
end

distribution = zeros(10,1);
for i = 1:size(temp_annotations,1)
    annotations = temp_annotations(i,:);
    counter = 0;
    for j = 1:size(annotations,2)
        if ~isempty(annotations{1,j})
            counter = counter + 1;
        end
    end
    distribution(i,1) = counter;
end

number = [35;35;35;35;38;39;22;11;23;27];
step = floor(distribution ./ number);
video_list = cell(300,1);
video_name_list = '';
index = 1;
for i = 1:size(annotation_info,1)
    annotations = annotation_info(i,:);
    for j = 0:number(i) - 1
        video = annotations{j*step(i) + 1};
        video.object_number = i;
        video_list{index,1} = video;
        video_name = [video.package_dir '/' video.video_dir];
        if index == 1
            video_name_list = video_name;
        else
            video_name_list = [video_name_list;video_name];
        end
        index = index + 1;
    end
end
video_list_path = '/home/sunx/output/selected';
video_list_file_mat = 'video_list.mat';
video_list_file_txt = 'video_list.txt';
output(video_list_path, video_list_file_txt, video_name_list, 'txt');
save(fullfile(video_list_path,video_list_file_mat), 'video_list');