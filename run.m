% process one video
% recall : hit object percentage
% smT-IoU : mT-IoU for one video
function [recall, smT_IoU] = run(video_package_path, video_dir,annotation_package_path, output_path)
video_path = fullfile(video_package_path, video_dir);
annotation_path = fullfile(annotation_package_path, video_dir);
show = false;
if exist(fullfile(video_path),'dir')    % validate video path
    t0=clock;
    [org_height, org_width, resized_imgs] = resize_img(video_path, 0);
    % entrance
    proposals = get_proposals(video_package_path, video_dir, output_path);
    timeCost=etime(clock,t0);
    % calculate result
    [result,annotations] = get_result(video_dir,annotation_path,output_path,proposals,timeCost);
    recall = result.recall;
    smT_IoU = result.smT_IoU;
    disp(['Finish:',video_path]);
    if show     % show result?
        input('show ?');
        show_hit(resized_imgs, result.hit ,proposals, annotations, org_height, org_width);
    end
else
    error(['Orginal video not found:',video_path]);
end