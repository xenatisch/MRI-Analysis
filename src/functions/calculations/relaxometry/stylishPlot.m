function stylishPlot(mr__te, mr__s, fit__te, fit__s, mr_estimated__t2, fit_type)
%CREATEFIGURE(X1, Y1, X2, Y2)
%  X1:  vector of x data
%  Y1:  vector of y data
%  X2:  vector of x data
%  Y2:  vector of y data


    %% Constants
    % Colors:
    MATT_BLUE =  [0.4 0.5 0.6];
    MATT_RED =   [1 0.4 0.4];
    DARK_GRAY =  [0.3 0.3 0.3];
    LIGHT_GRAY = [0.9 0.9 0.9];
    WHITE =      [1 1 1];
    %%
    % Font sizes:
    LEGEND_SIZE = 12;
    LABEL_SIZE  = 14;
    TITLE_SIZE  = 16;
    %%
    % Thickness of lines and markers:
    LINE_WIDTH  = 2;
    MARKER_SIZE = 8;
    %%
    % Axes limits:
    X_AXIS_LIMIT = [0 150];
    Y_AXIS_LIMIT = [0 1500];


    %% The figure
    % Initialising the figure.
    plot_figure = figure('Name','Plot of MR signal against echo time',...
                         'Color',WHITE);                % Background.

    %%
    % Defining manual axes control.
    plot_axes = axes('Parent', plot_figure);


    %% Plots

    %%
    % Plotting the line of best fit:
    plot_title = sprintf('Fitted function using T2 = %0.2f ', mr_estimated__t2);
    plot(fit__te, fit__s,          ...
        'DisplayName', plot_title ,...                   % Legend.
        'LineWidth',   LINE_WIDTH, ...
        'Color',       MATT_RED);    

    hold on

    % Plotting the markers:
    plot(mr__te, mr__s,               ...
        'DisplayName','Measured data',...                % Legend.
        'MarkerSize',  MARKER_SIZE,   ...
        'Marker',      'diamond',     ...
        'LineWidth',   LINE_WIDTH,    ...
        'LineStyle',   'none',        ...
        'Color',       MATT_BLUE);          

    hold off

    %%
    % Setting label for the x-axis:
    xlabel('Echo time, \textit{TE}', ...
           'FontSize',    LABEL_SIZE,...
           'Interpreter', 'latex');

    %%
    % Setting label for the y-axis:
    ylabel('MR signal, \textit{S}',  ...
           'FontSize',    LABEL_SIZE,...
          'Interpreter', 'latex');

    %%
    % Plot title:
    plot_title = {'\textbf{Plot of MR signal \textit{vs} echo time}';...
                  fit_type};
              
    title(plot_title,...  % Title in LaTeX.
          'LineWidth',     1,          ...
          'FontSize',      TITLE_SIZE, ...
          'Interpreter',   'latex',    ...
          'Color',         DARK_GRAY);       

    %%
    % Defining manual limits for the axes:
    xlim(plot_axes, X_AXIS_LIMIT);
    ylim(plot_axes, Y_AXIS_LIMIT);

    %%
    % Drawing a box around the plot area.
    box(plot_axes,'on');

    %%
    % Setting minor (generally visual) properties collectively for the plot: 
    set(plot_axes, ...
        'Color',        LIGHT_GRAY,...
        'GridColor',    WHITE,     ...
        'GridAlpha',    0.75,      ...
        'GridLineStyle','-',       ...
        'XColor',       DARK_GRAY, ...      
        'XGrid',        'on',      ...
        'YColor',       DARK_GRAY, ...
        'YGrid',        'on');

    %%
    % Setting minor (generally visual) properties collectively for the legend: 
    plot_legend = legend(plot_axes,'show');
    set(plot_legend,...
        'FontSize', LEGEND_SIZE,...
        'FontName', 'Courier',  ...
        'Color',    WHITE);

end  % function.
