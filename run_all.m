function run_all(video_base_path,package_video,output_path,annotation_base_path)
matlabpool 4;
parfor i = 1:size(package_video,1)
    video = package_video{i};
    run(video_base_path,video.video_dir,annotation_base_path,output_path);
end
matlabpool close;