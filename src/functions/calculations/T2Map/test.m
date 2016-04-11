close all;
clear;
clc;


% Reading the NifTi image using the absolute path.
% volume_map__T2 = T2Map(echo_time__TE);


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

%%

echo_time__TE = single([13 16 20 25 30 40 50 85 100 150]);


output = T2Map(echo_time__TE, nifti_map, nifti_bin, true);
