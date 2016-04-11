clc;
clear;
close all;

echo_time__TE = single([13 16 20 25 30 40 50 85 100 150]);

properties = analyse(echo_time__TE);

display(properties);


%% 
clc;
clear;
close all;

properties = analyse();

display(properties);
