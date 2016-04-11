function plotDistrib(volume__T2)
%PLOTDISTRIB Private function.
%            Internally used for creating scatter of T2 in volumes. 
% Requires: None
% Input: 3D matrix where each voxel contains the value for T2.
% Returns: None. Plots a scatter graph. 

    MARKER_ICON   = '.';                       % Marker for scatters. 
    WHITE_COLOUR  = [1 1 1];                   % White: Figure background/grids.
    GRAY_COLOUR   = [0.86 0.86 0.86];          % Gray: Plot background.
    MARKER_COLOUR = single([0.49 0.18 0.57]);  % Purple.
    WIN_POSITION  = [100, 100, 700, 600];      % Win size & position (600x500).
    
    
    % Linearise the matrix for scatters. 
    x_data = reshape(volume__T2, 1, []);
    
    % |y_axis| data. 
    y_data = 1:length(x_data);
    


    % Create figure
    fig_dist = figure('Name','Distribution of Magnetic Resonance T2 values',...
                      'Color',    WHITE_COLOUR, ...
                      'Position', WIN_POSITION);

    % Create axes
    fig_axes = axes('Parent',fig_dist);
    
    
    % Plotting the graph.
    scatter(x_data, y_data,    ...
            'MarkerEdgeColor', MARKER_COLOUR, ...
            'Marker',          MARKER_ICON);


    % Drawing a box around the plot area.
    box(fig_axes,'on');

    % Create title
    title('Distribution of Magnetic Resonance T2 values');

    % Set the remaining axes properties
    set(fig_axes,    ...
        'Color',     GRAY_COLOUR,  ...
        'FontSize',  11,           ...
        'GridAlpha', 0.7,          ...
        'GridColor', WHITE_COLOUR, ...
        'XGrid',     'on');

    
end