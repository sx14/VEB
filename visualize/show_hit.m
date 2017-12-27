function show_hit(org_imgs,hit,proposals,ground_truth,org_height, org_width)
ground_sum = size(hit,1);
color_v = init_color(ground_sum);
% 要显示ground truth将show_ground_truth设为false;
show_ground_truth = true;
figure;
for f = 1:length(org_imgs)
    I = org_imgs{f};
    I = imresize(I,[org_height,org_width]);
    annotations_on_frame = ground_truth{f};
    for h = 1:size(hit,1)
        annotation = annotations_on_frame(h);
        if ~isempty(annotation.id)   % 第f帧上没有第h个标注物体
            % =========== 画 ground truth =========
            if show_ground_truth
                x_max = annotation.x_max;
                x_min = annotation.x_min;
                y_max = annotation.y_max;
                y_min = annotation.y_min;
                height = y_max - y_min;
                width = x_max - x_min;
                I = draw_rect(I,[x_min y_min],[width height],3,[255,255,255]);
            end
        end
        
        % =========== 画 candidates ============
        proposal_id = hit(h,1);
        max_T_IoU = hit(h,2);
        %         if cand ~= 0 && max_T_IoU > 0.5
        if proposal_id ~= 0
            proposal = proposals{proposal_id};
            boxes = proposal.boxes;
            box = boxes(f,:);
            if sum(box) > 0
                x_max = box(1);
                x_min = box(2);
                y_max = box(3);
                y_min = box(4);
                height = y_max - y_min;
                width = x_max - x_min;
                I = draw_rect(I,[x_min y_min],[width height],3,color_v(h,:)');
            end
        end
    end
    imshow(I),title(['frame: ',num2str(f)]);
    pause(0.2);
end
close;