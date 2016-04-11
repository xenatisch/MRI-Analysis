%% Examples for |MakeVideo| 
% Summary of example objective
clear;

%% Create Images
% Description of first code block
images = rand(480, 640, 24);
img_size = size(images);

%% Live Stream
% Description of second code block

vid = MakeVideo();
vid.framerate = 4;

for iter=1:img_size(3)
    vid.liveStream(images(:,:,iter));
end

vid.liveStop();

clearvars vid;

%% Live Stream
% Description of second code block

fs = 500; 
timing = 0:1/fs:0.5; f=10; 
x_ax = sin(2*pi*f*timing); 
figure(); 
plot(timing, x_ax); 
axis xy;

path = '';
img_names = cell(img_size(3), 1);

for iter=1:img_size(3)
    img_names{iter} = sprintf('%sMkVd-%d.png',path, iter);
    imwrite(images(:,:,iter), img_names{iter});
end

vid = MakeVideo();
vid.framerate = 2;
vid.compose();

for iter=1:img_size(3)
    delete(sprintf('%sMkVd-%d.png',path, iter));
end

clearvars vid;

%% 

clear

random_array = transpose(randn(400, 1));
array_len = length(random_array);

daspect([6 8 1])

vid = MakeVideo();

fig = figure('Visible', 'off');

for iter=2:array_len
    plt = plot(random_array(1:iter), 'color', 'b');  
    xlim([0 array_len])
    ylim([-5 5])
    axis off
    cdata = print(fig, '-RGBImage', '-r150');
    vid.liveStream(cdata);
end

fig.Visible = 'on';

vid.liveStop();
