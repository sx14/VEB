annotation_info = load('annotation_info.mat');
annotation_info = annotation_info.annotation_info;
[r,c] = size(annotation_info);
base_path = '/home/sunx/dataset/ImageNet/Annotations';
for i = 1:r
    for j = 1:c
        a = annotation_info{i,j};
        if isempty(a)
            continue;
        end
        a_path = fullfile(base_path, a.package_dir, a.video_dir,'*.xml');
        xmls = dir(a_path);
        a.length = length(xmls);
        annotation_info{i,j} = a;
    end
end
save('annotation_info.mat','annotation_info');