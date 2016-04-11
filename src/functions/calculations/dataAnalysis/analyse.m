function [ response ] = analyse( echo_time__TE )
%ANALYSE Summary of this function goes here
%   Detailed explanation goes here

    OPEN_TITLE = 'NifTi files';
    OPEN_TYPE  = '*.nii';
    OPEN_DESCRIPTION = 'NifTi files (*.nii)';

    WHITE_MATTER = uint8(1);  % Value for white matter. 


    [file_names, file_path] = uigetfile({OPEN_TYPE, OPEN_DESCRIPTION}, ...
                                         OPEN_TITLE,                   ...
                                         'MultiSelect', 'on');

    if not(isa(file_names, 'cell'))
        
        error('Terminated by the user.');
        
    end



    % Processing the inputs. 
    if exist('echo_time__TE', 'var')
        
        properties = processFiles(file_names, file_path, ...
                                  WHITE_MATTER, echo_time__TE);
                              
    else
        
        properties = processFiles(file_names, file_path, WHITE_MATTER);
        
    end



    gab_vector = cell2mat(properties.gab);


    % Event loop.

    question = 'How would you like the results to be calculated?';

    while true

        clearvars -except properties question gab_vector;

        % Construct a questdlg with three options
        choice = questdlg(question,  ...
                          'Results', ...
                          'Gender Segregated','Collective','Exit','Exit');

        % Question for the next round.
        question = sprintf(['All done. Results can be seen through the GUI '...
                            'and in the prompt.\nHave another go...\n%s',   ...  
                            question]);

        % Handle response.
        switch choice

            case 'Gender Segregated'
                display(['Option: ', choice]);

                % Males (segregation comparison).
                gender_mask    = strcmpi(properties.sex,'M');
                males_matrix   = gab_vector(gender_mask);

                identifier = 'Analysis of male subjects';
                display(identifier);
                [properties.males.corr_coeff, properties.males.t_tests] = ...
                    getStats(males_matrix, properties, gender_mask, identifier);
                
                properties.total_males = sum(gender_mask);
                
                
                % Females (segregated comparison).
                gender_mask    = strcmpi(properties.sex,'F');
                females_matrix = gab_vector(gender_mask);

                identifier = 'Analysis of female subjects';
                display(identifier);
                [properties.females.corr_coeff, properties.females.t_tests] = ...
                    getStats(females_matrix, properties, gender_mask, identifier);
                
                properties.total_females = sum(gender_mask);

                
                continue;

                
            case 'Collective'
                
                identifier = 'Collective analysis';
                display(identifier); 
                
                % All subjects (collective comparison). 
                [properties.collective.corr_coeff, properties.collective.t_tests] = ...
                    getStats(gab_vector, properties, identifier);

                
                continue;
                

            case 'Exit'
                
                % Make sure they want to exit.
                exit_message = ...
                    questdlg(sprintf(                                        ...
                                     ['Are you sure you want to exit?\n',    ...
                                      'Displays must be closed manually.']), ...
                                      'Confirm',                             ...
                                      'Yes','No','Cancel','Cancel');

                % Handle response
                switch exit_message

                    case 'Yes'
                        fprintf(['\nThe programme was terminated by ',...
                                 'the user.\n\n']);
                             
                        response = properties;
                        
                        return;
                        
                    case 'No'
                        continue;

                    case 'Cancel'
                        continue;

                end  % exit_message

        end  % choice

    end  % event loop.

end

