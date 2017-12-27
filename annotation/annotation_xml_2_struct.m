% 读取一个视频每一帧的标注xml
% annotations:cell数组，每一个装一帧，每一帧包含多个annotation(bbox)
function [ground_truth_info, annotations] = annotation_xml_2_struct(annotation_path)
xml_files = dir(fullfile(annotation_path, '*.xml'));
frame = cell(length(xml_files),1);
ground_truth_info = zeros(20,4);    % ground-truth id , start_frame, end_frame, length
for i = 0:length(xml_files)-1
    num=num2str(i,'%06d');
    xml_name = [num,'.xml'];
    xml = xmlread(fullfile(annotation_path,xml_name));
    object_xmls = xml.getElementsByTagName('object');
    annotations(20)=struct('id',[],'x_max',[],'x_min',[],'y_max',[],'y_min',[],'occluded',[],'generated',[]);
    for j = 0:object_xmls.getLength-1
        object = object_xmls.item(j);
        track_id = object.getElementsByTagName('trackid').item(0);
        annotation.id = str2double(track_id.getTextContent()) + 1;
        if ground_truth_info(annotation.id,1) == 0
            ground_truth_info(annotation.id,1) = annotation.id;
            ground_truth_info(annotation.id,2) = i + 1;
            ground_truth_info(annotation.id,3) = i + 1;
        else
            ground_truth_info(annotation.id,3) = i + 1;
        end
        bbox = object.getElementsByTagName('bndbox').item(0);
        annotation.x_max = str2double(bbox.getElementsByTagName('xmax').item(0).getTextContent()) + 1;
        annotation.x_min = str2double(bbox.getElementsByTagName('xmin').item(0).getTextContent()) + 1;
        annotation.y_max = str2double(bbox.getElementsByTagName('ymax').item(0).getTextContent()) + 1;
        annotation.y_min = str2double(bbox.getElementsByTagName('ymin').item(0).getTextContent()) + 1;
        annotation.occluded = str2double(object.getElementsByTagName('occluded').item(0).getTextContent());
        annotation.generated = str2double(object.getElementsByTagName('generated').item(0).getTextContent());
        annotations(1,annotation.id) = annotation;
    end
    frame{i+1} = annotations;
    clear annotations;
end
[i,~,~] = find(ground_truth_info(:,1) > 0);
ground_truth_info = ground_truth_info(i,:);
ground_truth_info(:,4) = ground_truth_info(:,3) - ground_truth_info(:,2) + 1; 
annotations = frame;