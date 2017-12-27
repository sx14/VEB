function color_v = init_color(color_sum)
wanted = color_sum;
if color_sum < 256
    color_sum = 256;
end
color_v = zeros(color_sum,3);
color_v(:,1) = randperm(color_sum);
color_v(:,2) = randperm(color_sum);
color_v(:,3) = randperm(color_sum);
color_v = mod(color_v,256);
color_v = color_v(1:wanted,:);