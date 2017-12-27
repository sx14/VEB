function [org_height, org_width, resized_imgs] = resize_img(video_path, re_cal)
resize_dir_name = 'resized';
suffix = 'JPEG';
if ~exist(fullfile(video_path, resize_dir_name),'dir')
    mkdir(fullfile(video_path), resize_dir_name);
end
imgs = dir(fullfile(video_path, ['*.',suffix]));
resized_imgs = cell(length(imgs),1);
if ~exist(fullfile(video_path, resize_dir_name,'finish'),'file') || re_cal == 1  % cal
    default_length = 500;
    for i = 0:length(imgs)-1
        num1=num2str(i,'%06d');
        img_name = [num1,'.',suffix];
        I1 = imread(fullfile(video_path, img_name));
        if i == 0
            org_height = size(I1, 1);
            org_width = size(I1, 2);
        end
        [max_length,~] = max([org_width,org_height]);
        if max_length > default_length
            scale =  default_length / max_length;
            I1 = imresize(I1, scale);
        end
        resized_imgs{i+1} = I1;
        resized_img_name = fullfile(video_path, resize_dir_name, img_name);
        imwrite(I1, resized_img_name);
    end
    cal_finish(fullfile(video_path, resize_dir_name));
    disp('resize_img finished.');
else
    for i = 0:length(imgs)-1
        num1=num2str(i,'%06d');
        img_name = [num1,'.',suffix];
        I1 = imread(fullfile(video_path,resize_dir_name, img_name));
        resized_imgs{i+1} = I1;
    end
    num1=num2str(0,'%06d');
    img_name = [num1,'.',suffix];
    I = imread(fullfile(video_path, img_name)); % orginal image
    org_height = size(I, 1);
    org_width = size(I, 2);
    disp('resize_img finished before.');
end