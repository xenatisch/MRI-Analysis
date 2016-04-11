% Test: Calculate T2 Relaxometry

close all;
clear;
clc;



% Echo time, $ TE $:
echo_time__te = single([13 16 20 25 30 40 50 85 100 150]);

% MR Signal, $ S $:
mr_signal__s =  single([1418 1300 1223 1137 1033 907 775 461 357 173]);



% Passing test vectors to the function.
output_lin  = calcT2(echo_time__te, mr_signal__s, 'lin', true);


output_lsq  = calcT2(echo_time__te, mr_signal__s, 'lsq', true);


output_calc = calcT2(echo_time__te, mr_signal__s, 'calc', false);






