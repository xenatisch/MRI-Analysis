%% Initiation.
% This must be done at least once. 
% Separate documentations (in HTML) and test files are available in within the 
% directories containing the functions. 

% Clearing the workspace before starting the application.
%
% See <clear> , <clc>
close all;
clc;
clear('-all');

% Changing the directory.
editor_settings = matlab.desktop.editor.getActive;
cd(fileparts(editor_settings.Filename));

 
% Defining essential libraries. 
FUNCTIONS = {...
    'functions/'                            ...
    'functions/file_handling/',             ...
    'functions/rendering/',                 ...
    'functions/gui_handling/',              ...
    'functions/exports/',                   ...
    'functions/calculations/',              ...
    'functions/calculations/relaxometry/',  ...
    'functions/calculations/volumetrics/',  ...
    'functions/calculations/T2Map/',        ...
    'functions/calculations/dataAnalysis/'  ...
    };




% Adding library paths.

for path=FUNCTIONS
    addpath(path{:});
end




%% Task 1
clear;
clc;
close all;
gui();


%% Task 2
clear;
clc;
close all;


% Echo time, $ TE $:
echo_time__te = single([13 16 20 25 30 40 50 85 100 150]);

% MR Signal, $ S $:
mr_signal__s =  single([1418 1300 1223 1137 1033 907 775 461 357 173]);



% Passing test vectors to the function.
output_lin  = calcT2(echo_time__te, mr_signal__s, 'lin', true);
display(output_lin, 'Linear fit')

output_lsq  = calcT2(echo_time__te, mr_signal__s, 'lsq', true);
display(output_lsq, 'Least Square Curve fit')


output_calc = calcT2(echo_time__te, mr_signal__s, 'calc', false);
display(output_lin, 'Calculation via exponential decay')


%% Task 3
clear;
clc;
close all;

% Asking the user to open a NifTi ----> LABEL <---- file. 
dialog_title = 'Select a NifTi image: NifTi 4D image...';
file_type = '*.nii';
file_description = 'NifTi Image (*.nii)';

nifti_file = openFile(dialog_title, file_type, file_description);
    
niftiVols(nifti_file)

%% Task 4

close all;
clear;
clc;

% Mac doesn't display fileOpen headings. Make sure open a 4D file first, then a
% file containing the corresponding labels.


% Reading the NifTi image using the absolute path.
echo_time__TE = single([13 16 20 25 30 40 50 85 100 150]);


% |nifti_map| given?
if not(exist('nifti_map', 'var'))  % not given. 

    % Asking the user to open a NifTi file.
    dialog_title = 'Select a NifTi image: NifTi 4D image...';
    file_type = '*.nii';
    file_description = 'NifTi Image (*.nii)';

    abs_path = openFile(dialog_title, file_type, file_description);

    nifti_map = nii_read(abs_path);

    clearvars abs_path dialog_title file_type file_description;

end


% |nifti_bin| given?
if not(exist('nifti_bin', 'var'))  % not given. 

    % Asking the user to open a NifTi file.
    dialog_title = 'Select a NifTi image: NifTi Binary Mask...';
    file_type = '*.nii';
    file_description = 'NifTi Image (*.nii)';

    abs_path = openFile(dialog_title, file_type, file_description);

    nifti_bin = nii_read(abs_path);

    clearvars abs_path dialog_title file_type file_description;

end


output = T2Map(echo_time__TE, nifti_map, nifti_bin, true);


%% Task 5

clc;
clear;
close all;

echo_time__TE = single([13 16 20 25 30 40 50 85 100 150]);

properties = analyse(echo_time__TE);

display(properties);


%% Task 6

% Embedded in task 2. 