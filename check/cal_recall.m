function [recall,smT_IoU,hit_all] = cal_recall(ground_truth_info, frame_annotations,proposals)
ground_truth_object_sum = size(ground_truth_info,1);
record_interval = 50;
max_proposal_num = 1000;
record_times = max_proposal_num/record_interval;
hit_all = zeros(ground_truth_object_sum,record_times,3); % 击中每个ground truth 在增加50个proposals后的candidate id , T_IoU , avg_IoU
hit = zeros(ground_truth_object_sum,3);
for j = 1:max_proposal_num             % 每一个候选轨迹
    if j <= size(proposals,1)
        proposal = proposals{j,1};
        proposal_end = proposal.end_frame;
        proposal_start = proposal.start_frame;
        boxes = proposal.boxes;
        for i = 1:ground_truth_object_sum   % 每一个标注出来的物体
            ground_start = ground_truth_info(i,2);
            ground_end = ground_truth_info(i,3);
            % 并长 = 同时出现ground_truth 和 proposal 的帧数
            proposal_length = proposal_end - proposal_start + 1;
            u_start  = min(ground_start,proposal_start);
            u_end = max(ground_end, proposal_end);
            u_length = u_end - u_start + 1;
            if proposal_length / u_length < 0.5
                continue;
            end
            hit_frame_sum = 0;
            hit_IoU_sum = 0;
            for f = u_start:u_end % 每一帧，看是否击中
                if f < proposal_start || f > proposal_end   % 当前帧上没有proposal
                    continue;
                end
                objects = frame_annotations{f};
                if i > length(objects)                      % 当前帧上没有object
                    continue;
                end
                % 当前帧上既有object 又有 candidate，计算两个框的IoU看是否达标
                object_annotation = objects(i);
                if isempty(object_annotation.id)            % 该帧没有该物体
                    continue;
                end
                box = boxes(f,:);
                cand_max_x = box(1);
                cand_min_x = box(2);
                cand_max_y = box(3);
                cand_min_y = box(4);
                ground_max_x = object_annotation.x_max;
                ground_min_x = object_annotation.x_min;
                ground_max_y = object_annotation.y_max;
                ground_min_y = object_annotation.y_min;
                cand_region = (cand_max_x - cand_min_x) * (cand_max_y - cand_min_y);
                ground_region = (ground_max_x - ground_min_x) * (ground_max_y - ground_min_y);
                intersection_r = min(cand_max_x,ground_max_x);
                intersection_l = max(cand_min_x,ground_min_x);
                intersection_t = max(cand_min_y,ground_min_y);
                intersection_b = min(cand_max_y,ground_max_y);
                intersection_width = intersection_r - intersection_l;
                intersection_height = intersection_b - intersection_t;
                if intersection_width > 0 && intersection_height > 0    % 两个框相交
                    intersection_region = intersection_height * intersection_width;
                    IoU = intersection_region / (cand_region + ground_region - intersection_region);
                    if IoU >= 0.5   % 命中单帧
                        hit_frame_sum = hit_frame_sum + 1;
                        hit_IoU_sum = hit_IoU_sum + IoU;
                    end
                end
            end
            T_IoU = hit_frame_sum / u_length;
            avg_IoU = hit_IoU_sum / hit_frame_sum;
            if hit(i,2) < T_IoU     % 更新最匹配的cand
                hit(i,1) = j;
                hit(i,2) = T_IoU;
                hit(i,3) = avg_IoU;
            elseif hit(i,2) == T_IoU && avg_IoU > hit(i,3)
                hit(i,1) = j;
                hit(i,2) = T_IoU;
                hit(i,3) = avg_IoU;
            end
        end
    end
    if mod(j,record_interval) == 0
        hit_index = floor(j / record_interval);
        hit_all(:,hit_index,:) = hit;
    end
end
smT_IoU = sum(hit_all(:,record_times,2)) / ground_truth_object_sum;
recall = length(find(hit_all(:,record_times,2) > 0.5)) / ground_truth_object_sum;


function mask = get_binary_mask(sps, mask, hier, small_sp_sum)
for i = 1:length(sps)
    sp = sps(i);
    if sp > small_sp_sum    % 组合过的sp
        % 递归将sp包含的像素位置置1
        conbine = hier.ms_struct(sp-small_sp_sum);
        for j = 1:size(conbine.children,2)
            mask = get_binary_mask(conbine.children(1,j),mask,hier, small_sp_sum);
        end
    else    % 未组合过的sp
        % 直接置1
        sp_mask = hier.leaves_part == sp;
        mask(sp_mask) = 1;
    end
end
