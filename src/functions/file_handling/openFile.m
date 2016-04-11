function [ file_path ] = openFile( title, type, type_discr )
%openFile(path): Presents user with an Open dialogue box for selecting a 
%                single file. 
%
%   REQUIRES: None
%
%   INPUT
%   =======================================================================
%   title       To be shown as title of the window. > Char
%
%   type        Allowed format(s) of the file. > Char
%               e.g.: '*.jpg' or '*.jpg; *.png'
%
%   type_discr  Description to be shown along with the format(s). > Char
%               e.g.: 'JPEG files (*.jpg)'
%               
%
%   RETURN
%   =======================================================================
%   file_path   Absolute path to the selected file. 
%
%==========================================================================
% author            Pouria Hadjibagheri
% last modified     9 Decemer 2015
% matlab version    MATLAB R2015b
% licence           GPLv2.0
%==========================================================================

    while true
        % Asking user to select a .nii file via GUI. 
        [file_name, file_path] = uigetfile({type, type_discr}, ...
                                            title, ...
                                            'MultiSelect', 'off');
        
        % Check if a selection has been made.
        if isequal(file_name,0) % if not
            % Dialogue box asking for instructions. 
            dialogue_question = ['No files were selected.', ...
                                 'Are you sure you want to terminate the programme?'];
            dialogue_title = 'Operation cancelled.';
            dialogue_options = {'Yes', 'No', 'No'}; % Yes:retry; No/Cancel(repr:No):terminate
            dialogue = questdlg(dialogue_question, ...
                                dialogue_title, ...
                                dialogue_options);

            % Handling instructions
            switch dialogue
                case 'Yes',  % wants to exit/cancel.
                    warning('Cancelled by the user. Operation terminated. Good-Bye!')
                    close
                    break; 

                case 'No',  % wants to try again.
                    quit cancel;
                    break
            end % switch

        else
           % Returned
           file_path = strcat(file_path, file_name);
           break;
           
        end % if
    end % while


end

