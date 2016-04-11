function [ final__T2 ] = T2Map( echo_time, nifti_map, nifti_bin, plotit )
%T2MAP    3D map of the T2 values at every voxel in the white matter region of 
%         the brain. 
%
% Inputs: 
% echo_time    vector, same length of the time (4th dimension of Nifti).
% nifti_map    4D data of a Nifti.
% nifti_bin    binary data separating the segments.
% plotit       optional arg. |logical|. If true(default), graphs are displayed. 
%
% Retuns:
% final__T2    3D volume of T2 at each individual voxel within the image.
%

    if not(exist('echo_time', 'var'))  || ...
        not(exist('nifti_map', 'var')) || ...
        not(exist('nifti_bin', 'var'))
        
        error(['Runtime Error:\n'...
               '   Necessary argument missing. Please pass the correct '...
               'number of inputs. See documentations for more information.']);
           
    elseif exist('plotit', 'var')

        assert(isa(plotit, 'logical'), ...
            ['Type Error:\n', ...
             '   Invalid value. Value of |plotit| must be an object of '...
             'class |logical|.'])
         
    else
        
        plotit = true;

    end
    
    TIME_IND   =  uint8(4);
    INDEX__T2  =  uint8(2);
        
    segment_id =  uint8(1);
        
    echo_total =  uint8(size(nifti_map, TIME_IND));
    echo_time_size = uint8(size(echo_time));

    if length(echo_time) ~= echo_total

        error(['Input Error:\n'...
               '   Dimensions do not agree. Length of the vector must be '...
               'the same as the length of the 4th dimenssion of the MR '  ...
               'image.'])

    end

    % Logical mask of the threshold applied to the model.
    brain_segment_logical = nifti_bin==segment_id;

    masked_set = NaN(size(nifti_map));

    % Applying the mask to every timeframe. 
    for iteration=1:echo_total

        frame = nifti_map(:, :, :, iteration);
        masked_frame = single(frame .* brain_segment_logical);
        
        % Outside of the mask = NaN. 
        masked_frame(frame~=masked_frame) = NaN;
        
        masked_set(:,:,:,iteration) = masked_frame;

    end

    % Reshaping the matrix to match the time length. 
    masked_2d = reshape(single(masked_set), ...
                        [numel(masked_set(:,:,:,1)), ...
                        size(masked_set, TIME_IND)]);

    % Log of TE.
    logged_2d = single(log(masked_2d));

    matrix__TE = single([...
                            ones(echo_time_size); ...
                            echo_time ...
                        ]);


    
    % Going through voxels to calculate T2. 
    matrix__S0__T2 = single(logged_2d/matrix__TE);
    t2_rev_tmp = matrix__S0__T2(:, INDEX__T2);
    estimated__T2 = single(-1./t2_rev_tmp);
    
     

    % Final map of T2, reshaped to 3D. 
    final__T2 = single(reshape(estimated__T2, ...
                               [size(nifti_map, 1), ...
                                size(nifti_map, 2), ...
                                size(nifti_map, 3)]));


    if plotit
        
        % Plotting 3 slices of the map. 
        figure('name', 'T2 Map')

        render3d(NaN(3,3,3)); % Initialising a nice 3D platform.

        hold on;

        title 'T2 Map';

        % Display slices.
        % TODO: Give the option to enter the desired slices. 
        slice_disp = slice(double(final__T2), 40 ,60 ,25);

        set(slice_disp, ...
            'edgecolor','none', ...
            'facealpha', 0.5);

        axis tight;
        view(-38.5, 16);
        camzoom(1.4);
        material dull;  
        camproj perspective;

        hold off;


        % Scatter plot.
        plotDistrib(final__T2);
        
    end  % plotit.

end

