function [ patches ] = render3d( spacial_img )
%RENDER3D Summary of this function goes here
%   Detailed explanation goes here

    PLOT_BK = [0.75 0.75 0.75];    % Plot background colour
    AXES_COL = [0.9 0.9 0.9];      % Plot grids colour
    OBJECT_COL = 'cyan';           % Colour of the plotted object
        
    
    surfs = isosurface(spacial_img);
    
    patches = patch(surfs, ...
            'EdgeColor', 'none', ...
            'FaceColor',  OBJECT_COL);
        
    patches.EdgeColor = 'none';
    
    patches.FaceColor =  OBJECT_COL;

    

    % Visual adjustments for the plot
    axis vis3d;                        % Spacial axes
    view(3);                           % Spacial view
    daspect([1,1,1]);                  % Aspect ratio
    camlight;                          % Spacial Lighting
    lightangle(45,-30)                 % Lighting angle
    lighting gouraud;                  % Lighting algorithm
    material shiny;                    % Object material
    grid on;                           % Show the grids
    set(gca, 'XColor', AXES_COL, ...   % Setting X-grid colour
             'YColor', AXES_COL, ...   % Setting X-grid colour
             'ZColor', AXES_COL, ...   % Setting X-grid colour
             'Color',  PLOT_BK)        % Setting plot background 
    axis tight; 

end

