% 根据底层超像素的bbox，计算所有超像素的bbox
% sp_boxes 超像素bbox:x_max x_min y_max y_min
function sp_boxes = get_sp_boxes(basic_sp_boxes, sp_conbine_mat)
basic_sp_sum = size(basic_sp_boxes,1);
conbined_sp_sum = size(sp_conbine_mat,1) - basic_sp_sum;
conbined_sp_boxes = zeros(conbined_sp_sum, 4);
for i = 1:conbined_sp_sum
    conbined_sp_index = i + basic_sp_sum;
    sps = find(sp_conbine_mat(conbined_sp_index,:) > 0);
    x_maxs = basic_sp_boxes(sps,1);
    x_mins = basic_sp_boxes(sps,2);
    y_maxs = basic_sp_boxes(sps,3);
    y_mins = basic_sp_boxes(sps,4);
    conbined_sp_boxes(i,1) = max(x_maxs);
    conbined_sp_boxes(i,2) = min(x_mins);
    conbined_sp_boxes(i,3) = max(y_maxs);
    conbined_sp_boxes(i,4) = min(y_mins);
end
sp_boxes = cat(1,basic_sp_boxes, conbined_sp_boxes);