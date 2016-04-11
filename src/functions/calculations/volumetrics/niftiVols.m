function [ volumetrics ] = niftiVols( nifti_path )
%NIFTIVOLS Summary of this function goes here
%   Detailed explanation goes here

    %% Constants
    persistent MM3_TO_M3;
    persistent TOTAL_VOX;
    persistent VOL_MM3;
    persistent VOL_M3;

    if isempty(MM3_TO_M3)
        % Cubic milimeter to cubic meter. Must be |single| or |double|. 
        MM3_TO_M3 = single(1*10^6); 

        % Table references.
        TOTAL_VOX = uint8(1);      
        VOL_MM3 = uint8(2);
        VOL_M3 = uint8(3);
    end

    WIN_POSITION  = [100, 100, 700, 600];  % Window size and position (600x500).

    %% Reading the file

    % Optional input assertion.

    % |file_path| given?
    if not(exist('nifti_path', 'var'))  %|file_path| not given. 

        % Asking the user to open a NifTi file.
        dialog_title = 'Select a NifTi image...';
        file_type = '*.nii';
        file_description = 'NifTi Image (*.nii)';
        nifti_path = openFile(dialog_title, file_type, file_description);

    end



    % Reading the NifTi image using the absolute path.
    try

        [nii_object, pixdim] = nii_read(nifti_path);

    catch

        error(['I/O Error:\n'
               '   Either an invalid path has been given, '...
               'or the NifTi file is corrupt.\nApplication terminated.\n\n']);

    end


    % Creating a struct containing the data. The struct will facilitate in-code
    % modifications by the user later on. 
    % 
    % TODO: Implement a GUI for these inputs.
    segment_details = struct(...
                                'White_Matter',             uint8(1),...
                                'Gray_Matter',              uint8(2),...
                                'Cerebrospinal_Fluid',      uint8(3),...
                                'Deep_Gray_Matter',         uint8(4),...
                                'Cerebellum_and_Brainstem', uint8(5) ...
                             );



    % Name of each segment extracted from the |struct|.
    segment_names = fieldnames(segment_details);

    TOTAL_OUTPUT_ARGS = 3;
    data = zeros(length(segment_names), TOTAL_OUTPUT_ARGS);

    total_names = uint8(numel(segment_names));
    % Iterating through the names. 
    for index=1:total_names

        % Retrieving the id corresponding to each segment. 
        % Note: Prathesis are necessary after the dot (.) operator to ensure 
        % that the value (string) is passed as opposed to the variable. 
        segment_id = segment_details.(segment_names{index});

        % Logical mask of the id applied to the model.
        brain_segment = nii_object==segment_id;

        % Volume in voxels. 
        volume.total_voxels = single(sum(brain_segment(:)));

        % Volume in mm3
        volume.total_mm3 = single(volume.total_voxels*prod(pixdim));

        % Volume in m3. 
        volume.total_m3 = single(volume.total_mm3 / MM3_TO_M3);

        % Adding the volumetric data into a predefined matrix.
        data(index, :) = single(round([volume.total_voxels; ...
                                      volume.total_mm3; ...
                                      volume.total_m3...
                                     ], 3));


        % Using Regex to replace the hyphens in the titles retrieved from the
        % struct.
        title_raw = segment_names{index};    % Title from the struct.
        expression = '[_]';                       % Character to be substituted.
        replace = ' ';                            % Substituting character. 
        figure_title = regexprep(title_raw,  ...
                                 expression, ...
                                 replace);  

        % Initialising new figure for each segment.
        figure('name',     figure_title,...    % Window title.
               'color',    'w',         ...    % Background colour (w = white). 
               'Position', WIN_POSITION);      % Window size and position.

        % Rendering a smoothed 3D graph of the segment.
        renderSmooth3d(brain_segment, rand(1,3));


        % Adjusting the figure settings.    
        title_volumetrics = sprintf(strcat(...
                                      figure_title,...
                                          '\nVol=$%0.2f~mm^{3}$.'), ...
                                    volume.total_mm3);
                                
                                
        title(title_volumetrics,      ...
              'Interpreter', 'latex', ...
              'FontSize',     16);         % Graph title

        camva('auto');                     % View angle.   

        clearvars volume title_raw title_volumetrics segment_id brain_segment

    end  % for(segment_field_names)


    volumetrics = table(...
                        data(:,TOTAL_VOX), data(:,VOL_MM3), data(:,VOL_M3), ...
                        'RowNames', segment_names,        ...
                        'VariableNames', {'Total_voxels'; ...
                                          'Volume_mm3';   ...
                                          'Volume_m3'}    ...
                       );

    disp(volumetrics);

end

