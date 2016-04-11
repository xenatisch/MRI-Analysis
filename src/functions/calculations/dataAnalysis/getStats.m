function [ corr_coeff, ttests ] = getStats( gab_vector, properties, varargin )
%GETSTATS Summary of this function goes here
%   Detailed explanation goes here

    %% Constants
    MIN_ARGS = uint8(2);                        % Minimum input args needed.
    MAX_ARGS = uint8(5);                        % Maximum input args allowed.
    
    CONTROL        = uint8(40);                 % weeks.
    THRESHOLD      = uint8(28);                 % weeks.

    WIN_POSITION   =       ...
        struct('Position', ...
                uint16([100, 100, 1100, 800])); % Win size & position (600x500).

    WHITE_COLOUR   = ...
        struct('Color', single([1 1 1]));       % White - Figure properties.
    
    GRAY_COLOUR    =    ...
        struct('Color', ...
                single([0.94 0.94 0.94]));      % Gray - Figure properties.
            
    GRID_SETTINGS  =             ...
        struct('gridcolor', 'w', ...
               'gridalpha', single(0.8));       % Grid settings - white colour.
           
    LIGHT_PURPLE   = [.9 .4 1];                 % Purple.
    LIGHT_PINK     = [.8 .5 1];                 % Pink.
    
    SEPARATOR = ...                             % Separator for prompt displays.
        sprintf(['\n------------------------------------------------------'...
                   '------------------------------------------------------\n']);
    
    %% Confirm input arguments
    narginchk(MIN_ARGS, MAX_ARGS);

    varargs_total = length(varargin);
    
    if varargs_total == 1 && isa(varargin{1}, 'logical')
        
        custom_mask = varargin{1};
        identifier  = 'Graph';
    
    elseif varargs_total == 1 && isa(varargin{1}, 'char')
        
        identifier = varargin{1};
        custom_mask = true(size(gab_vector));
    
    elseif varargs_total == 2
        
        for var=varargin
            
            if isa(var{:}, 'char')
                
                identifier = var{:};
                
            elseif isa(var{:}, 'logical')
                
                custom_mask = var{:};
                
            else
                
                error('Invalid input to function |getStats|.')
                
            end  % if (under for)
            
        end  % for (var in varargin)
   
    elseif varargs_total == 0
        
        custom_mask = true(size(gab_vector));
        
    else
        
    	error('Invalid input to function |getStats|.')
        
    end  % varargin tests. 
    
    
    %%
    % Ensuring that |gab_vector| is an object of the class |single|. Class
    % |double| is also allowed, but it will occupy additional memory
    % unnecessarily. 
    gab_vector     = single(gab_vector);
    

    
    %% Segment volume and averages T2 values
    % Calculating the _total volume_ and _average T2_ values based on the 
    % requested portion of the data.
    converted      = single(cell2mat(properties.segment_vol));   % Masked data.
    seg_vol_matrix = converted(custom_mask);                     % Volume
    
    converted      = single(cell2mat(properties.t2_average));    % Masked data.
    seg_t2_mat     = converted(custom_mask);                     % TE
    
    clearvars converted varargs_total           % Clearing temporary variables.

    
    %% Means and Standard Deviations
    % 40 completed gestational weeks.
    gab_40wks_mask   = gab_vector == CONTROL;            % Mask
    vol_40wks        = seg_vol_matrix(gab_40wks_mask);   % Volume
    t2_40wks         = seg_t2_mat(gab_40wks_mask);       % T2
    vol_40wks_mean   = mean(vol_40wks);                  % Mean of volume.
    vol_40wks_stdev  = std(vol_40wks);                   % Standard deviation of volume.
    t2_40wks_mean    = mean(t2_40wks);                   % Mean of T2.
    t2_40wks_stdev   = std(t2_40wks);                    % Standard deviation of T2.

    %%
    % 28 completed gestational weeks.
    gab_u28wks_mask  = gab_vector < THRESHOLD;           % Mask.
    vol_u28wks       = seg_vol_matrix(gab_u28wks_mask);  % Volume.
    t2_u28wks        = seg_t2_mat(gab_u28wks_mask);      % T2.
    vol_u28wks_mean  = mean(vol_u28wks);                 % Mean of volume.
    vol_u28wks_stdev = std(vol_u28wks);                  % Standard deviation of volume.
    t2_u28wks_mean   = mean(t2_u28wks);                  % Mean of T2.
    t2_u28wks_stdev  = std(t2_u28wks);                   % Standard deviation of T2.



    % Correlation matrices.
    vol_gab_corr = corr([gab_vector(gab_u28wks_mask); ...
                         vol_u28wks]);                   % Gab vs Vol.
                     
    t2_gab_corr  = corr([gab_vector(gab_u28wks_mask); ...
                         t2_u28wks]);                    % Gab vs T2.

    % Correlation coefficients.
    vol_gab_corrcoef = corrcoef(gab_vector(gab_u28wks_mask), vol_u28wks);
    t2_gab_corrcoef  = corrcoef(gab_vector(gab_u28wks_mask), t2_u28wks);
 
    corr_coeff = table(vol_gab_corrcoef, ...
                        t2_gab_corrcoef, ...
                        'VariableNames', {'T2_GAB', 'Volume_GAB'});
    
    display_items = {SEPARATOR,                   ...
                     'Correlation Coefficients:', ...
                     corr_coeff, SEPARATOR};
    for item=display_items
        display(item{:})
    end



    % Display the correlation matrices. 

    % GAB-Volume correlation.
    figure('name', identifier, WHITE_COLOUR, WIN_POSITION);
    subplot(2,3,2)
    imagesc(vol_gab_corr);
    xlabel 'GAB';
    ylabel 'Average Segment Volume';
    title ({'Matrix of correlation';                ...
            '\textbf{Completed gestational weeks}'; ...
            '\textit{vs}';                          ...
            '\textbf{Average Segment volume}'},     ...
           'Interpreter', 'latex',                  ...  % Text interpreter (LaTeX).
           'HorizontalAlignment', 'center',         ...  % Text alignment.
           'FontSize', 12);                              % Font size.
    axis square;
    colorbar('southoutside', 'ticks', [0 .5 1])

    % GAB-T2 correlation.
    subplot(2,3,5)
    imagesc(t2_gab_corr);
    xlabel 'GAB';
    ylabel 'Average Segment T2';
    title (...
        {'Matrix of correlation';               ...
        '\textbf{Completed gestational weeks}'; ...
        '\textit{vs}';                          ...
        '\textbf{Average segment T2 value}'},   ...
       'Interpreter', 'latex',                  ...  % Text interpreter (LaTeX).
       'HorizontalAlignment', 'center',         ...  % Text alignment.
       'FontSize', 12);                             % Font size.

    axis square;
    colorbar('southoutside', 'ticks', [0 .5 1]);
    colormap 'copper';



    % Display the scatter plots of volume and T2 vs GAB.

    % GAB vs Volume.
    axis_max_x = max(gab_vector) + 10;
    axis_min_x = min(gab_vector) - 10;
    subplot(2, 3, 1)
    
    scatter(gab_vector, seg_vol_matrix, '*');
    title(...
        {'\textbf{Completed gestational weeks} ',...
         '\textit{vs} ',                         ...
         '\textbf{Average Segment volume}'},     ...
        'Interpreter', 'latex',                  ... % Text interpreter (LaTeX).
        'HorizontalAlignment', 'center',         ... % Text alignment.
        'FontSize', 12);                             % Font size.
    xlabel 'GAB';
    ylabel 'Average Segment Volume';
    set(gca,                             ...
        'xgrid', 'on',                   ...
        'ygrid', 'on',                   ...
        'xlim', [axis_min_x axis_max_x], ...
        GRAY_COLOUR,                     ...
        GRID_SETTINGS);
    axis square;

    % GAB vs T2.
    subplot(2, 3, 4)
    scatter(gab_vector, seg_t2_mat, '*');
    title({'\textbf{Completed gestational weeks} ', ...
           '\textit{vs} ',                          ...
           '\textbf{Average segment MR T2}'},       ...
          'Interpreter', 'latex',                   ...  % Text interpreter (LaTeX).
          'HorizontalAlignment', 'center',          ...  % Text alignment.
          'FontSize', 12);                               % Font size.
    xlabel 'GAB';
    ylabel 'Average Segment T2';
    set(gca,                             ...
        'xgrid', 'on',                   ...
        'ygrid', 'on',                   ...
        'xlim', [axis_min_x axis_max_x], ...
        GRAY_COLOUR,                     ...
        GRID_SETTINGS);
    axis square;



    % Box plots of correlation/covariance of volume and T2 at 28 and 40 weeks. 

    % Volume box plot values.
    box_vol = [vol_u28wks_stdev, vol_u28wks_mean,  ...
               vol_40wks_stdev ,  vol_40wks_mean];

    % T2 box plot values.   
    box_t2   = [t2_u28wks_stdev , t2_u28wks_mean,  ...
                t2_40wks_stdev  , t2_40wks_mean];

    % Max/Min of the axes for the volume plot.
    max_axis_tmp = max(box_vol);
    max_axis_vol = (max_axis_tmp * 0.1) + max_axis_tmp;
    min_axis_vol = min(box_vol) - (max_axis_tmp * 0.1);

    % Max/Min of the axes for the T2 plot.
    max_axis_tmp = max(box_t2);
    max_axis_t2  = (max_axis_tmp * 0.1) + max_axis_tmp;
    min_axis_t2  = min(box_t2) - (max_axis_tmp * 0.1);

    % Creating boxplots. 

    % Volume (mean and covariance).
    subplot(2, 3, 3)
    boxplot(box_vol, {'Volume'});
    set(gca,           ...
        GRAY_COLOUR,   ...
        'ygrid', 'on', ...
        GRID_SETTINGS, ...
        'ylim', [min_axis_vol max_axis_vol]);
    title({'Mean and Standard Deviation of',      ...
           '\textbf{Average segment volume}',     ...
           'at 40 and 28 weeks.'},                ...
          'Interpreter', 'latex',                 ...  % Text interpreter (LaTeX).
          'HorizontalAlignment', 'center',        ...  % Text alignment.
          'FontSize', 12);                             % Font size.
    axis square;

    % T2 (mean and covariance).
    subplot(2, 3, 6)
    boxplot(box_t2, {'T2'});
    set(gca,           ...
        GRAY_COLOUR,   ...
        'ygrid', 'on', ...
        GRID_SETTINGS, ...
        'ylim', [min_axis_t2 max_axis_t2]);
    title({'Mean and Standard Deviation of',      ...
           '\textbf{Average segment MR T2}',      ...
           'at 28 and 40 weeks.'},                ...
          'Interpreter', 'latex',                 ...  % Text interpreter (LaTeX).
          'HorizontalAlignment', 'center',        ...  % Text alignment.
          'FontSize', 12);                             % Font size. 
    axis square;




    % 2 sample T-test statistics
    % Volume values
    [vol_ttest.h_0, vol_ttest.p_val, vol_ttest.conf_int, vol_ttest.stats] = ...
                            ttest2(vol_40wks, vol_u28wks);

    % T2 values
    [t2_ttest.h_0 , t2_ttest.p_val , t2_ttest.conf_int , t2_ttest.stats ] = ...
                            ttest2(t2_40wks ,  t2_u28wks);




    % Prompt output + function return. This will be displayed as a |table| object, 
    % and can be accessed by column names. Very similar to |struct| but visually 
    % more organised.
    ttests = table([vol_ttest.h_0; t2_ttest.h_0],                 ...
                   [vol_ttest.p_val; t2_ttest.p_val],             ...
                   [vol_ttest.conf_int; t2_ttest.conf_int],       ...
                   [vol_ttest.stats.tstat; t2_ttest.stats.tstat], ...
                   [vol_ttest.stats.df; t2_ttest.stats.df],       ...
                   [vol_ttest.stats.sd; t2_ttest.stats.sd],       ...
                 'RowNames', {'Volume';'T2'},                     ...
                 'VariableNames', {'Hypothesis',                  ...
                                   'p_value',                     ...
                                   'Confidence',                  ...
                                   'T_test',                      ...
                                   'Deg_Freedom',                 ...
                                   'Stan_Dev'});

    display_items = {'T-test statistics:', ttests, SEPARATOR};
    for item=display_items
        display(item{:})
    end




    % GUI output, displayed in a graphical window, and can be saved, exported or 
    % printed for further manupulations or publications.
    vals = single([[vol_ttest.h_0; t2_ttest.h_0],                 ...
                   [vol_ttest.p_val; t2_ttest.p_val],             ...
                   [vol_ttest.conf_int; t2_ttest.conf_int],       ...
                   [vol_ttest.stats.tstat; t2_ttest.stats.tstat], ...
                   [vol_ttest.stats.df; t2_ttest.stats.df],       ...
                   [vol_ttest.stats.sd; t2_ttest.stats.sd]]       ...
                 );                                          % Cell values.


    output_figure = figure('name', identifier, ...
                           'Position', [150 150 800 100]);   % Figure initiation.
    set(gcf, 'ToolBar', 'none');                             % Toolbar not shown.
    gui_table = uitable('Parent',   output_figure,     ...
                        'Position', [10 20 780 60],   ...
                        'Data',     vals);                   % GUI table initiation.
    gui_table.ColumnName = {'Hypothesis',              ...
                            'p-value',                 ...
                            '  Confidence: Min  ',     ...
                            '  Confidence: Max  ',     ...
                            '  T_test Statistics  ',   ...
                            '  Degree of Freedom  ',   ...
                            '  Standard Deviation  '};       % Column names.
    gui_table.RowName =  {'Volume'; 'T2'};                   % Row names.
    gui_table.ColumnEditable = false;                        % Cell not editable.
    gui_table.BackgroundColor = [LIGHT_PINK; LIGHT_PURPLE];  % Row backgrounds.
    gui_table.FontName = 'Calibri';                          % Font family.
    gui_table.FontSize = 13;                                 % Font size.


end  % function

