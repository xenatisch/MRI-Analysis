function [ smoothed ] = renderSmooth3d( spacial_img, object_col)
%GET_SMOOTH3D Summary of this function goes here
%   Detailed explanation goes here

    PLOT_BK = [0.75 0.75 0.75];    % Plot background colour
    AXES_COL = [0.9 0.9 0.9];      % Plot grids colour

    % Optional args for colour given?
    if not(exist('object_col', 'var'))
        object_col = 'cyan';  % Default colour of the plotted object.
    end
    
    nifti_smooth = smooth3(spacial_img);
    surfs = isosurface(nifti_smooth); 

    patches = patch(surfs, ...
                    'EdgeColor', 'none', ...
                    'FaceColor', object_col);

    patches.AmbientStrength = 1;
    patches.DiffuseStrength = 0.5;
    patches.FaceLighting = 'gouraud';
    patches.BackFaceLighting = 'unlit';
    set(patches, 'facealpha', 0.7);

        
    smoothed = isonormals(nifti_smooth, patches);


    % Visual adjustments for the plot
    axis equal;                          % Equal axes
    axis vis3d;                          % Spacial axes
    view(3);                             % Spacial view
    daspect([1,1,1]);                    % Aspect ratio
    camlight;                            % Spacial Lighting
    lightangle(45,-30)                   % Lighting angle
    lighting gouraud;                    % Lighting algorithm
    material shiny;                      % Object material
    grid on;                             % Show the grids
    set(gca, 'XColor', AXES_COL, ...     % Setting X-grid colour
             'YColor', AXES_COL, ...     % Setting X-grid colour
             'ZColor', AXES_COL, ...     % Setting X-grid colour
             'Color',  PLOT_BK)          % Setting plot background 
    % Hint: get(hObject,'Value') returns toggle state of radiobutton2
    axis tight; 

end

