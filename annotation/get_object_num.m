function annotation_info = get_object_num(base_path, video_package_list, video_sum)
annotation_info = cell(10,video_sum); %1,2,3,4,5,6,7,8,9,9+
next_index = ones(10,1);
for i = 1:size(video_package_list,1)    % each video package
    video_package_name = video_package_list(i,:);
    videos = dir(fullfile(base_path, video_package_name,'*'));
    for j = 1:length(videos)    % each video
        video = videos(j);
        if (video.isdir && ~strcmp(video.name,'.') && ~strcmp(video.name,'..') )
            object_num = 0;
            xmls = dir(fullfile(base_path, video_package_name,video.name,'*.xml'));
            for f = 1:length(xmls)  % each xml
                xml_file_path = fullfile(base_path, video_package_name, video.name, xmls(f).name);
                xml = xmlread(xml_file_path);
                object_xmls = xml.getElementsByTagName('object');
                for o = 0:object_xmls.getLength-1   % each object
                    object = object_xmls.item(o);
                    track_id = object.getElementsByTagName('trackid').item(0);  % start from 0
                    track_id = str2double(track_id.getTextContent());
                    object_num = max(object_num, track_id + 1);
                end
            end
            if object_num >= 1
                if object_num > 9
                    object_num = 10;
                end
                video_id.package_dir = video_package_name;
                video_id.video_dir = video.name;
                annotation_info{object_num,next_index(object_num)} = video_id;
                next_index(object_num) = next_index(object_num) + 1;
            end
        end
    end
end