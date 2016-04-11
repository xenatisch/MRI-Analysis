function [ final_data ] = getTE( time_length, te_values )
%GETTE Summary of this function goes here
%   Detailed explanation goes here

    min_args = uint8(0);            % Min args in.
    max_args = uint8(2);            % Max args in.
    narginchk(min_args, max_args);  % Check number of args in. 
    
    if ~exist('te_values', 'var')
        
        te_values  = zeros(1, time_length);  

    else
        te_values = cast(te_values, 'double');
    end
    
    condition = false; 
    
    % Figure for entering TE (echo time) values. 
    te_input_fig = figure('Name', 'TE', 'Position', [300 100 160 300]); 
    

    % Even loop.
    while ~condition
        
        t = uitable(te_input_fig,...
            'Data', te_values',...                    % Default values.
            'Position', [10 50 140 220],...           % Dimensions.
            'ColumnWidth',{100}, ...                  % Column width (pixels).
            'ColumnEditable', true, ...               % Editable cells.
            'ColumnName', {'TE values'});             % Column name.

        set(gcf, ...
            'ToolBar', 'none', ...                    % Toolbar not shown.
            'MenuBar', 'none');                       % Menubar not shown.      

        % Button
        uicontrol('Style', 'pushbutton', ...
                      'String', 'Submit',...          % Text.
                      'Position', [5 12 150 30],...   % Dimensions.
                      'Callback', ...                 % Action.
                      'uiresume(gcbf)');
        % Label.
        uicontrol('Style', 'text', ...
                  'Position', [-20 280 200 10],...    % Dimensions.
                  'String', ...                       % Text.
                  'Enter the echo time (TE) values'); 
                
        uiwait(te_input_fig);
        [condition, values] = verifyData(t.Data);
              
    end
    
    function [cnd, verified_data] = verifyData(te_data)
        if isa(te_data, 'double') && ~all(te_data == 0)
            verified_data = te_data;
            cnd = true;
        else
            error_msg = sprintf(['Invalid input.\n', ...
                                 'The input must be nummeric and integer.\n',...
                                 'Floating points will be rounded.']);
            errordlg(error_msg, 'Input Error');
            cnd = false;
        end
    end
    
    close(te_input_fig);
    final_data = uint32(transpose(values));
    
end

