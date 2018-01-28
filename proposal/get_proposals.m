% param:video full path
function proposals = get_proposals(base_path, video_dir, output_path)
proposal_dir = 'proposals';
if exist(fullfile(output_path, proposal_dir, [video_dir '.mat']),'file')
    proposals = load(fullfile(output_path, proposal_dir, [video_dir '.mat']));
    proposals = proposals.proposals;
    return;
end
video_path = fullfile(base_path, video_dir, 'resized');
resized_imgs = dir(fullfile(video_path, '*.JPEG'));
org_img = imread(fullfile(base_path, video_dir,'000000.JPEG'));
org_height = size(org_img,1);
org_width = size(org_img,2);
model=load('EB/models/forest/modelBsds'); model=model.model;
model.opts.multiscale=0; model.opts.sharpen=2; model.opts.nThreads=4;
%% set up opts for edgeBoxes (see edgeBoxes.m)
opts = edgeBoxes;
opts.alpha = .65;     % step size of sliding window search
opts.beta  = .75;     % nms threshold for object proposals
opts.minScore = .01;  % min score of boxes to detect
opts.maxBoxes = 1e4;  % max number of boxes to detect

%% detect Edge Box bounding box proposals (see edgeBoxes.m)
mid_frame = floor(length(resized_imgs) / 2);
mid_frame_str=num2str(mid_frame,'%06d');
mid_frame_file = [mid_frame_str,'.JPEG'];
I = imread(fullfile(video_path, mid_frame_file));
resized_height = size(I,1);
resized_width = size(I,2);
resize_ratio = max(org_height,org_width) / max(resized_height,resized_width);
bbs=edgeBoxes(I,model,opts);
if size(bbs, 1) > 1000  % 取前1000
    bbs = bbs(1:1000,:);
end

start_frame = 0;
end_frame = length(resized_imgs) - 1;
forward_frames = cell(mid_frame - start_frame + 1, 1);
backward_frames = cell(end_frame - mid_frame + 1, 1);

for i = mid_frame :-1: start_frame     % 反向
    frame_id=num2str(i,'%06d'); 
    frame = [frame_id,'.JPEG'];
    forward_frames{mid_frame - i + 1} = frame;
end

for i = mid_frame : end_frame       % 正向
    frame_id=num2str(i,'%06d'); 
    frame = [frame_id,'.JPEG'];
    backward_frames{i - mid_frame + 1} = frame;
end

proposals = cell(size(bbs,1),1);
% each bbox : track forward , track backword
for i = 1:size(bbs,1)
    x = bbs(i,1);
    y = bbs(i,2);
    w = bbs(i,3);
    h = bbs(i,4);
    if w < 5 || h < 5   % 框太小，tracker失败
        boxes = zeros(length(resized_imgs),4);
%         boxes(mid_frame+1,:) = [xmax, xmin, ymax, ymin];
    else
        [forward_positions] = run_tracker([video_path '/'], forward_frames, [y,x], [h,w]);
        [backword_positions] = run_tracker([video_path '/'], backward_frames, [y,x], [h,w]);
        forward_positions = flipud(forward_positions(2:end,:));  % 去掉mid frame, 顺序翻转
        positions = cat(1,forward_positions,backword_positions);
        boxes = [positions(:,2) + w, positions(:,2), positions(:,1) + h, positions(:,1)];
        boxes = round(boxes * resize_ratio);
        boxes(boxes <= 0) = 1;
    end
    boxes(boxes(1,:) > resized_width) = resized_width;
    boxes(boxes(3,:) > resized_height) = resized_height;
    boxes(boxes([2,4],:) < 1) = 1;
    proposal.start_frame = start_frame + 1;
    proposal.end_frame = end_frame + 1;
    proposal.boxes = boxes;
    proposal.video = video_dir;
    proposals{i} = proposal;
end
output = fullfile(output_path,proposal_dir, [video_dir '.mat']);
save(output, 'proposals');

