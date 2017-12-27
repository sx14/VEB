function show_line(net, hiers, min_length, end_frame, org_imgs, color)
all_length = net(:,end_frame,3);
all_lines = net(:,end_frame,1);
all_lines(all_length < min_length) = [];
long_lines = unique(all_lines);
X = sprintf('Long line sum: %d.',size(long_lines,1));
disp(X)
for i = 1:size(long_lines,1)
    for j =  1:end_frame
        hier = hiers{j};
        lines = net(:,j,1);
        [sp,~,v] = find(lines == long_lines(i));
%         ratio = zeros(size(lines));
%         ratio(sp') = net.lines(sp',j,2)';
%         [~, max_sp] = max(ratio);
        if size(v,1) == 0
            continue;
        else
            mask_b = zeros(size(hier.leaves_part,1),size(hier.leaves_part,2));
%             mask_b = get_binary_mask(max_sp, mask_b, hier, max(max(hier.leaves_part)));
            for k = 1:size(sp,1)
                mask_b = get_binary_mask(sp(k), mask_b, hier, max(max(hier.leaves_part)));
            end
            mask_b = ~mask_b;
            org_img = org_imgs{j,1};
            org_r = org_img(:,:,1);
            org_g = org_img(:,:,2);
            org_b = org_img(:,:,3);
            org_r(mask_b) = color(1);
            org_g(mask_b) = color(2);
            org_b(mask_b) = color(3);
            org_img(:,:,1) = org_r;
            org_img(:,:,2) = org_g;
            org_img(:,:,3) = org_b;
            figure;
            X = sprintf('Frame %d',j);
            imshow(org_imgs{j,1}),title(X); hold on;
            h = imshow(org_img);
            set(h,'alphaData',0.3)
        end
    end
    X = sprintf('Line: %d, continue?', long_lines(i));
    input(X);
%     disp(X);
    pause(0.7);
    close all;
end

function mask = get_binary_mask(sp, mask, hier, small_sp_sum)
if sp > small_sp_sum    % 组合过的sp
    % 递归将sp包含的像素位置置1
    conbine = hier.ms_struct(sp-small_sp_sum);
    for i = 1:size(conbine.children,2)
        mask = get_binary_mask(conbine.children(1,i),mask,hier, small_sp_sum);
    end
else    % 未组合过的sp
    % 直接置1
    sp_mask = hier.leaves_part == sp;
    mask(sp_mask) = 1;
end
