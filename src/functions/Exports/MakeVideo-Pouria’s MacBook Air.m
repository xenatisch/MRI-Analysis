%% Make Videos
% This is a comprehensive module for creating videos from slides. As a
% class, it can be inherited by other classes. This means that its
% properties may be changes, and additional functionalities may be added to
% it without the need to directly change the code. The aim of this module
% is to facilitate the creationg of video, and simplify the otherwise 
% tedious process imposed by native MATLAB(R) functions.

%% General information
%
%       Author.............Pouria Hadjibagheri
%       Last modified......25 December 2015
%       Matlab version.....MATLAB R2015b
%       Licence............GPLv2.0
%       Copyright..........2015(C) Pouria Hadjibagheri.

%% Licence
% MakeVideo. A comprehensive module for creating videos in MATLAB(R). Copyright 
% (C) 2015  Pouria Hadjibagheri.
% 
% This program is free software; you can redistribute it and/or modify it under 
% the terms of the GNU General Public License as published by the Free Software 
% Foundation; either version 2 of the License, or (at your option) any later 
% version.
% 
% This program is distributed in the hope that it will be useful, but WITHOUT 
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
% FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along with 
% this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
% Street, Fifth Floor, Boston, MA 02110-1301, USA; or visit 
% <https://opensource.org/licenses/gpl-2.0.php>
% 

%%
%
classdef MakeVideo
%MAKEVIDEO Summary of this class goes here
%   Detailed explanation goes here

    
    %% Independent public properties
    % These are the properties that can be changed by the user of this class
    % in MATLAB(R). 
    %
    %% Define a "Save as" path
    % The path (including the file name and type) to the location where the 
    % motion picture is to be saved. This property must be passed as |char| 
    %
    % Example:
    %
    %   MakeVideo = '/user/nini/MyVideos/MyTimelapse.avi'
    %
    % If not passed, the UI save window will be automatically instantiated,
    % asking the user to define a path. 
    %
    % Neither use nor instantiate this property unless you are intending
    % to "hardcode" the location. 
    %
    %% Video from existing images (timelapse)
    %
    % Neither use nor instantiate these properties unless you are intending
    % to create a timelapse video from existing images. 
    %
    % File name of the images in as |struct|.
    %
    % Example: 
    %
    %   MakeVideo.image_names = { ['image01.jpg'], ['image02.jpg'] }; % and etc.
    %
    % Directory in which the images are stored are passed separately as |char|.
    %
    % Example: 
    %
    %   MakeVideo.image_path = '/user/nini/MyPictures/';
    %
    %% Dependent public properties.
    % |framerate| in frames per second, i.e. the number of slides shown
    % in each second of the video. The default is 24 frames per second.
    %
    % |quality| in pixels, and refers to the height. The width is then
    % automatically calculated based on HD standard aspect ratio, which is
    % 16x9. All renderings are progressive, as opposed to interlaced.
    % Default |quality| is 720, which is the normal HD quality. For your
    % reference; Best HD is 1080, and ultra HD (4k) is 4000. Needless to
    % say that (1) if you are doing a timelapse, your images should
    % correspond to the quality you are requesting, or the definition
    % won't be achieved, and (2) the higher the resolution, the longer it
    % will take to render the video. In other words, if you are using
    % an old PC that still runs on Windows XP, you probably don't want to
    % go 4K. 
    %
    % 
    % All defaults are set on the basis of international standard for HD 
    % motion pictures.
    properties (Access = public)
       
        image_names;            % Struct of existing file names.
        image_path;             % String of location directory. 
        savingPath;             % Where to save the video.
        framerate = 24;         % 24 fps; HD standard.
        quality = uint16(720);  % HD 720p.
        
    end  % Public properties.
    

    %% Protected properties
    % These are the properties that can be changed if and only if this class
    % is inherited as a superclass into another class in MATLAB(R). This
    % implementation is enforced to ensure that only experienced users can make
    % alterations, as inappropriate  modifications might amount to errors, or 
    % incorrect and often bizzare outputs. 
    %
    % Do not change the default values unless (1) you have read the 
    % documentations, and (2) you know what yu are doing.
    %
    % *Video attributes*
    %
    % These properties handle the attributes of the video, and include:
    %
    % |vid_profile| is the encoding profile standard based on which the 
    % video file is written, so that it can be readable by specific systems
    % /devices.
    %
    % AVI encoding profiles (as described in MATLAB(R) documentations:
    % 
    % <html>
    % <style type="text/css">
    % .tg  {border-collapse:collapse;border-spacing:0;
    % border-color:#999;margin:0px auto;}
    % .tg td{font-family:Arial, sans-serif;font-size:11px;padding:10px 5px;
    % border-style:solid;border-width:1px;overflow:hidden;word-break:normal;
    % border-color:#999;color:#444;background-color:#F7FDFA;}
    % .tg th{font-family:Arial, sans-serif;font-size:11px;font-weight:normal;
    % padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;
    % word-break:normal;border-color:#999;color:#fff;background-color:#26ADE4;}
    % .tg .tg-yw4l{vertical-align:top}
    % </style>
    % <table class="tg">
    %   <tr><th class="tg-yw4l">Profile</th><th class="tg-yw4l">Description</th>
    %   </tr><tr><td class="tg-yw4l">Archival</td><td class="tg-yw4l">Motion 
    %   JPEG 2000 file with lossless compression.</td></tr>
    %   <tr><td class="tg-yw4l">Motion JPEG AVI</td><td class="tg-yw4l">AVI 
    %   file using Motion JPEG encoding.</td></tr>
    %   <tr><td class="tg-yw4l">Motion JPEG 2000</td><td class="tg-yw4l">Motion 
    %   JPEG 2000 file.</td></tr> <tr><td class="tg-yw4l">MPEG4</td><td 
    %   class="tg-yw4l">MPEG-4 file with H.264 encoding (systems with Windows 7 
    %   or later, or Mac OS X 10.7 and later) - .mp4 or .m4v </td></tr>
    %   <tr><td class="tg-yw4l">Uncompressed AVI</td><td class="tg-yw4l">
    %   Uncompressed AVI file with RGB24 video.</td></tr><tr><td class="tg-yw4l"
    %   >Indexed AVI</td><td class="tg-yw4l">Uncompressed AVI file with indexed 
    %   video.</td></tr><tr><td class="tg-yw4l">Grayscale AVI</td><td 
    %   class="tg-yw4l">Uncompressed AVI file with grayscale video.</td></tr>
    % </table>
    % </html>
    % 
    % All defaults are set on the basis of international standard for HD 
    % motion pictures.
    properties (Access = protected)

        aspect_ratio = [16 9];  % Standard HD video aspect.

        % AVI encoding profiles (as described in MATLAB(R) documentations:  
        % For more info on encoding types, see the documentations. 
        vid_profile = 'Uncompressed AVI';  % Standard for RGB24 video.
        
    end  % Protected properties
    

    %% Private properties
    %
    properties (Access = private)        
        
        PICTURE_QUALITY = uint8(100);  % Percentage of images quality.
        
    end  % Private properties.
    
    
    %% Constants
    % Be warned that changing the scale factor would slow the programme
    % down considerable. It's best to define the appropriate size when
    % creating the slides / images in the first place. 
    properties (Constant)
        
        RESIZE_ALGORITHM = 'bilinear'; % Bilinear interpolation.
        SCALE_FACTOR = single(1);      % Default scaling factor (0:1 ratio).
        DISPLAY_INTERVALS = uint8(10); % Display rendered image intervals.
        
    end
    

    %% Property |set| and |get| methods
    %
    methods

        function obj = MakeVideo
            obj.framerate;
        end
        
        
        %% Validation of |savingPath|
        function obj = set.savingPath(obj, value)

            if ~exist('value', 'var')
                
                status = false;
                
            % A |value| is given?
            elseif ~isempty(value)

                % Is the path viable? Let's test.
                status = testPath(obj, value);

            % No |value| is given.
            else

                status = false;

            end

            %% Verification of parameters.
            % Checking the existence and validity of parameters.

            % Is the path to save the file given? if not, ask the user for it.
            if ~status

                % Ask the user for a file name. 
                [avi_name, avi_path] = uiputfile('*.avi', ...
                                                 'Save video file as');
                % Cancelled? 
                if ~avi_name

                    % Killed --> What it says! 
                    error(sprintf(['\n>>> Operation terminated '...
                                   'by the user.\n']));  %#ok<SPERR>

                end  % if

                % If no error is thrown and we have got so far:

                % Create a single string of the absolute path for saving the
                % final output file. 
                value = strcat(avi_path, avi_name);

                % Is the path viable? Let's test.
                % If not, an error is returned in the relevant function. 
                testPath(obj, value);
                
                % Property value is set.
                obj.savingPath = value;
                fprintf('\n     Saving path successfully set.\n');

                return; % Nothing else to do here. 


            % The path is valid. 
            else

                % Property value is set.
                obj.savingPath = value;
                fprintf('\n     Saving path successfully set.\n');

                return; % Nothing else to do here. 

            end

        end  % function (savingPath)


        %% Validation of |framerate|
        % *Note*: |str2double| is considerably faster than |str2num|. The former
        % throws an error if the variable passed is a mix of numbers and 
        % characters. The latter on the other hand, checks (through iteration) 
        % for the existence of non-numeric characters, and if any exists, it 
        % returns an empty array.
        function obj = set.framerate(obj, value)

            try

                % Check if the |framerate| given is a |char|.
                if isa(value, 'char')
                    % |framerate| is given as a |char|. It is converted into
                    % |double|. For more see section intro.
                    tmp = str2double(value);

                    % If |framerate| is not greater than zero.
                    if tmp < 1 

                        % Nothing else to do here until the user learns how to 
                        % use the programme.
                        error(sprintf(['Value Error:\n   '
                                       'Expected an integer greater than '...
                                       'zero for <framerate>, got %d '...
                                       'instead.'], tmp)); %#ok<SPERR>
                                   
                    else

                        obj.framerate = tmp;

                    end % if (tmp)
                    
                    
                % |framerate| is not |char|, and is greater than zero.
                elseif and(isnumeric(value), value > 0)

                    obj.framerate = value;

                    return;  % Function terminated. 

                % |framerate| is not |char|, but is not greater than zero.
                else

                    % Nothing else to do here until the user learns how to 
                    % use the programme.
                    error(sprintf(['Value Error:\n   '
                                   'Expected an integer greater than '...
                                   'zero for <framerate>, got %d instead.']...
                                  , value)); %#ok<SPERR>


                end  % if (framrate)

            catch exception  
                % Most likely induced by passing a mixture of strings and 
                % numbers to |str2double| - but you never know! So the actual 
                % message generated by MATLAB(R) is displayed.
                error(sprintf(['Input Error:\n' ...
                               '   %s \n' ...
                               '   The process is terminated prematurely.'], ...
                              exception.message), ...
                              exception.identifier);


            end  % try

        end  % function (framerate)
        
        
        %%
        %
        function obj = set.image_path(obj, value)
            obj.image_path = value;
        end
        
        %%
        %
        function obj = set.image_names(obj, value)
            obj.image_names = value;
        end

    end
    
    methods (Access = public)
        
        %%
        function liveStream(obj, img)
        %LIVESTREAM
        
        	createLive(obj, img);
                
        end
        
        %%
        function liveStop(obj)
        %LIVESTOP
            createLive(obj, [])
            
        end

        %%
        function compose(obj)
        %COMPOSE   
        
            if ~exist('obj.saving_path', 'var') 
                tmp_obj = obj;
                tmp_obj.savingPath = [];
                obj = tmp_obj; 
            end
        
            %%
            %True if one is true. False if both are true, or both are false.
            lapse_test_1 = xor(~isempty(obj.image_names), ...
                               isempty(obj.image_path));

            lapse_test_2 = xor(isempty(obj.image_names), ...
                               ~isempty(obj.image_path));

            %%
            % Is this a timelapse from existing image files? 
            if or(~isempty(obj.image_names), ~isempty(obj.image_path))
                
                timeLapse(obj);

            %%
            % Both |image_names| or |image_path| are empty, but the function
            % |compose| is implemented directly. Here we will give the user
            % a chance to select images using GUI. 
            elseif and(lapse_test_1, lapse_test_2)
                
                % Types of images allowed.
                allowed_image_formats = {...
                              '*.jpeg;*.jpg;*.bmp;*.tif;*.tiff;*.png;*.gif', ...
                              'Image Files (JPEG, BMP, TIFF, PNG and GIF)'};
                  
                % Header of the GUI opener.
                gui_header = 'Select Images';
                
                try 
                    
                    % GUI opener.
                    [file_names, file_path] = uigetfile(...
                                               allowed_image_formats, ...
                                               gui_header, 'multiselect', 'on');
                    
                    total_files = length(file_names);
                    % Telling the user what they've done!
                    fprintf(sprintf(['\nTotal of <%d> files were ', ...
                                     'selected from "%s".\n'], ...
                                    total_files, file_path));
                                
                    tmp_obj = obj;
                    tmp_obj.image_names = file_names;
                    tmp_obj.image_path = file_path;
                    obj = tmp_obj;
                    timeLapse(obj);
                    
                    return; 
                    
                catch exception
                    
                    % A Runtime error that I couldn't think of to handle (i.e. 
                    % beyond imagination error!) has occurred.
                    error(sprintf(['Runtime Error:\n' ...
                               '   %s \n' ...
                               '   The process is terminated prematurely.'],...
                               exception.message), exception.identifier);
                    
                end  % try (GUI opener)

                
            %%
            % If either |image_names| or |image_path| is empty.
            elseif or(lapse_test_1, lapse_test_2)
                
                % Show an error dialogue and explain why! 
                error(sprintf( ...
                    ['Value Error:\n' ...
                     '   Timelapse values "image_names" or "image_path" '...
                     'are set but do not meet the criteria. \n' ...
                     'Please read the documentations for additional ' ... 
                     'information.\n\n' ...
                     '   The process is terminated prematurely.'])); %#ok<SPERR>   
                
            end  % if (timeLapse)

        end  % function (compose)


    end  % methods (public)


    %% Protected Methods
    %
    methods (Access=protected)

        %%
        %
        function createLive(obj, live_image)
        %CREATELIVE

        
            %% 
            % For creating a video whilst generating images, the |video_object|
            % must be defined as a *singleton* object. This means that one and 
            % only one instance of this object can be created, unless it is 
            % explicitly deleted. In MATLAB(R), this is achieved implicitly
            % by defining a |persistent| variable.
            persistent video_object

            %%
            % If there is no |video_object|, then it is the first time that this
            % function is called.
            %
            % If, however, there is is a |video_object|, but there is no 
            % |live_image|, this it is the last time that this function is 
            % called, so the termination process is initiated, and the existing 
            % |video_object|is removed.
            
            % There is no |video_object|.
            if isempty(video_object)
                
                if isempty(obj.savingPath)
                    obj.savingPath = [];
                end

                video_object = videoObject(obj);

                fprintf('\nCompiling frames to video...\n');

                           
            %%
            % There is a |video_object|, but no |live_image|.
            elseif and(~isempty(video_object), isempty(live_image))

                % Done with the video object: file closed. 
                close(video_object); 

                % Singleton object removed.
                delete(video_object);
                clear video_object;
                
                fprintf('\n.......... compilation finished.\n');

                % If we've got so far with no error, then all's gone well! 
                % The user is hereby informed through a message box!
                fprintf(['\n>> Operation Completed. \n\n'...
                         'Video was successfully created and saved into the'...
                         ' designated path.\n']);
                   
                % No need for anything else to run. 
                fclose(obj);
                return;  % Process is terminated.  
                
            end  % if
            
            
            %%
            % If there is a scale factor 
            % (someone was adventurous and changed my constant!)
            if obj.SCALE_FACTOR ~= 1

                % Scale as specified. 
                current_image = imresize(live_image, ...
                                         obj.SCALE_FACTOR, ...
                                         obj.RESIZE_ALGORITHM);

            else

                current_image = live_image; 

            end  % if


            try 

                % Create and open the file.
                open(video_object);

                % Writing the video object into the file.
                writeVideo(video_object, current_image);

                return;  % Function terminated.

            catch exception

                % A Runtime error that I couldn't think of to handle (i.e. 
                % beyond imagination error!) has occurred.
                error(sprintf('Runtime Error:\n   %s', ...
                              exception.message), exception.identifier);

            end  % try 

        end  % function (createLive)


        %%
        %
        function timeLapse(obj)
        %TIMELAPSE
            
                
            image_names_local = obj.image_names;
            image_path_local = obj.image_path;
                
            
            file_count = length(image_names_local);


            video_object = videoObject(obj);

            %%
            %  
            try 

                % Create and open the file.
                open(video_object);

                % Initiate progress bar.
                progress_bar = waitbar(0, 'Please wait...');
                
                figure('Name', 'View...')
                hold on
                
                % Bring the progress bar window to front. It might 
                % go to the back when the image is displayed. 
                uistack(progress_bar, 'top');
                
                for iter=1:file_count

                    img_path = strcat(image_path_local, ...
                                      image_names_local{iter});
                                 
                    % Read the image from the file. 
                    current_image = imread(img_path);

                    
                    % If there is a scale factor 
                    % (someone was adventurous and changed my constant!)

                    if obj.SCALE_FACTOR ~= 1

                        % Scale as specified. 
                        current_image = imresize(current_image, ...
                                                 obj.SCALE_FACTOR, ...
                                                 obj.RESIZE_ALGORITHM);

                    end

                    % Writing the video object into the file.
                    writeVideo(video_object, current_image);

                    % Preview image (once every 10 frames.)
                    if mod(iter, ...
                           round(file_count/obj.DISPLAY_INTERVALS)) == 1

                        imshow(current_image) % Display where we are. 

                        % Set title. 
                        title(sprintf('Preview image %d/%d', ...
                                      iter, ...
                                      file_count))

                    end % if (preview)

                    % Update progress bar... We're making progress ;)
                    waitbar(iter/file_count, progress_bar);

                end  % for (image iterator)
                hold off;
                % Done with the progress bar. This does what it says!
                delete(progress_bar); 

                % Ditto ;) Done with the video object: file closed. 
                close(video_object); 

                % If we've got so far with no error, then all's gone well! 
                % The user is hereby informed through a message box!
                msgbox(sprintf(...
                        ['Operation Completed. \n\n'...
                         'Video was successfully created and saved into the'...
                         ' designated path.\n']));
                     
                return;  % Function terminated.

            catch exception

                % A Runtime error that I couldn't think of to handle (i.e. 
                % beyond imagination error!) has occurred.
                error(sprintf('Runtime Error:\n   %s', ...
                              exception.message), exception.identifier);

            end  % try 

        end  % function(timeLapse)
    
    end  % methods (protected)


    %% Private and Sealed Methods
    %
    methods (Sealed=true, Access=private)
        
        %%
        %
        function video_object = videoObject(obj)
        %INSTANTIATEVIDEO
            
            %%
            % Instantiating a video object and setting the properties. 
            try
                fprintf('\nInitiating the video object...');

                % VideoWrite instantiated. 
                video_object = VideoWriter(obj.savingPath, obj.vid_profile);    

                % Framerate set.           
                video_object.FrameRate = obj.framerate;

                % Quality set. 
%                 video_object.Quality = obj.PICTURE_QUALITY;
                
                fprintf('.......... Initiated.\n');
                return;  % All done. 

            catch exception

                % A Runtime error that I couldn't think of to handle (i.e. beyond
                % imagination error!) has occurred.
                error(sprintf('Runtime Error:\n   %s', ...
                              exception.message), exception.identifier);

            end  % try

        end  % function (instantiateVideo)
        

        %% Verify the 'save as' path
        %
        function viability = testPath(~, path)
        %TESTPATH


            % Testing the viability of the path.
            %
            % For instance, does the user have sufficient permission to write
            % in this directory? or is the disk healthy? 
            try
                fprintf('\nTesting the path...');

                % Create and open a file in the given path. 
                test_file = fopen(path, 'w'); 

                % Write into the file. 
                fprintf(test_file,'testing the file.'); 

                % Close the file object.
                fclose(test_file);

                % Does what it says! Deletes the test file.
                delete(path)
                
                % I/O test passed. 
                viability = true;
                
                fprintf('.......... Passed.\n');
                return;

            catch exception

                % There has been a problem with writing files in the given
                % path; most likely something to do with ownership or
                % permissions - but you never know! So the actual message
                % generated by MATLAB(R) is displayed.
                error(sprintf(['I/O Error:\n' ...
                               '   %s \n' ...
                               '   The process is terminated prematurely.'],...
                              exception.message), exception.identifier);
                
            end  % try (saving path test)
            
        end  % function (testPath)
    

    end  % methods (sealed and private)
    

end  % class

%% VIM (a unix editor) specific settings. 
% *Do not modify.*
%
% Indentation level = 4 spaces. 
% Tab = 4 spaces (Tabs disabled).
% Width standard: 80 column.
% 

% vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
