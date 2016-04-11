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
classdef MakeVideo
%UNTITLED2 Summary of this class goes here
%   Detailed explanation goes here

    
    %%% Public properties
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
    properties (SetAccess = public)
       
        saving_path = [];           % Where to save the video.
        image_names = [];           % Struct of existing file names.
        image_path = [];            % String of location directory. 

        
    end  % Public properties.
    

    %%% Protected properties
    % These are the properties that can be changed if and only if this class
    % is inherited as a superclass into another class in MATLAB(R). This
    % implementation is enforced to ensure that only experienced users can make
    % alterations, as inappropriate  modifications might amount to errors, or 
    % incorrect and often bizzare outputs. 
    %
    % Do not change the default values unless (1) you have read the 
    % documentations, and (2) you know what yu are doing.
    %
    %% Video attributes
    % *These properties handle the attributes of the video, and include:*
    %
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
    %
    properties (SetAccess = protected)

        framerate = uint8(24);      % 24 fps; HD standard.
        quality = uint16(720);      % HD 720p.
        aspect_ratio = [16 9];      % Standard HD video aspect.

        % AVI encoding profiles (as described in MATLAB(R) documentations:  
        % For more info on encoding types, see the documentations. 
        vid_profile = 'Uncompressed AVI';  % Standard for RGB24 video.

        image;
        
    end  % Protected properties
    

    %% Private properties
    properties (SetAccess = private)        
        
        PICTURE_QUALITY = uint8(100);  % Percentage of images quality.
        
    end  % Private properties.
    

    %% Methods
    methods
        
        %% Create a video
        function create(image, saving_path, framerate, quality, ...
                        vid_profile, PICTURE_QUALITY, image_names, ...
                        image_path, aspect_ratio)

            %% 
            % *Constants*
            %
            % Be warned that changing the scale factor would slow the programme
            % down considerable. It's best to define the appropriate size when
            % creating the slides / images in the first place. 
            SCALE_FACTOR = single(1);      % Default scaling factor (0:1 ratio).
            DISPLAY_INTERVALS = uint8(10); % Display rendered image intervals.
            RESIZE_ALGORITHM = 'bilinear'; % Bilinear interpolation.

            %% 
            % *Validation*
            %
            % Do the properties passed onto the function meet the criteria? 
            %
            % If any property doesn't meet the criteria, appropriate error 
            % messages will be generated and displayed in the relevant section. 
            validation = verifyProperties();

            if ~validation 
                
                % Criteria not met.
                % Nothing else to do here until the user learns how to use the
                % application or solves the I/O issues. 
                return;  % Function terminated.

            end  % validation

            %%
            % Is this a timelapse from existing image files? 
            if ~isempty(image_names) || ~isempty(image_path)
                timelapse(image_names, image_path, saving_path, ...
                           vid_profile, frame_rate, AVI_QUALITY, ...
                           SCALE_FACTOR, DISPLAY_INTERVALS, RESIZE_ALGORITHM);

            % If either |image_names| or |image_path| is empty.
            elseif xor(~isempty(image_names), isempty(image_path)) || ...
                   xor(isempty(image_names), ~isempty(image_path))
                
                % Show an error dialogue and explain why! 
                errordlg(sprintf( ...
                    ['Value Error:\n' ...
                     '   Timelapse values "image_names" and/or "image_path" '...
                     'are set but do not meet the criteria. \n'
                     'Please read the documentations for additional'... 
                     'information.\n'...
                     '   The process is terminated prematurely.']));

                % Go learn how to use the function, or use the GUI. 
                % Nothing else to do here until the user learns how to use the
                % application. So function is closed. 
                return;  % Function terminated.

            end  % if (timelapse)

        end  % function (create)


        %%
        function timelapse(image_names, image_path, saving_path, ...
                           vid_profile, frame_rate, AVI_QUALITY, ...
                           SCALE_FACTOR, DISPLAY_INTERVALS, RESIZE_ALGORITHM)
            
            file_count = length(image_names);

            video_object(saving_path, vid_profile, frame_rate, AVI_QUALITY);

            %%
            try 

                % Create and open the file.
                open(video_object)

                % Initiate progress bar.
                progress_bar = waitbar(0, 'Please wait...');

                for iterator=1:file_count

                    % Read the image from the file. 
                    current_image = imread(saving_path, ...
                                           image_names{iterator});

                    % If there is a scale factor 
                    % (someone was adventurous and changed my constant!)
                    if SCALE_FACTOR ~= 1
                        % Scale as specified. 
                        current_image = imresize(current_image, ...
                                                 SCALE_FACTOR, ...
                                                 RESIZE_ALGORITHM);
                    end

                    writeVideo(video_object, current_image);

                    % Preview image (once every 10 frames.)
                    if mod(iterator, ...
                           round(file_count/DISPLAY_INTERVALS)) == 1

                        imshow(SCALE_FACTOR) % Display where we are. 

                        % Set title. 
                        title(sprintf('Preview image %d/%d', ...
                                      iterator, ...
                                      file_count))

                        % Bring the progress bar window to front. It might 
                        % go to the back when the image is displayed. 
                        uistack(progress_bar, 'top')

                    end % if (preview)

                    % Update progress bar... We're making progress ;)
                    waitbar(iterator/file_count, progress_bar);

                end  % for (image iterator)

                % Done with the progress bar. This does what it says!
                delete(progress_bar); 

                % Ditto ;) Done with the video object: file closed. 
                close(video_object); 

                % If we've got so far with no error, then all's gone well! 
                % The user is hereby informed through a message box!
                success_msg = msgbox(sprintf(...
                        ['Operation Completed. \n\n'...
                         'Video was successfully created and saved into the'...
                         ' designated path.\n']));

            catch exception

                % A Runtime error that couldn't think of to handle (i.e. 
                % beyond imagination error) has occured.
                errordlg(sprintf( ...
                    'Runtime Error:\n   %s', ...
                    exception.message), exception.identifier);

                return;  % Function terminated.

            end  % try 

        end  % function(timelapse)


        %%
        function video_object = instantiateVideo(saving_path, vid_profile, ...
                                                 frame_rate, AVI_QUALITY)

            %%
            % Instantiating a video object and setting the properties. 
            try

                % VideoWrite instantiated. 
                video_object = VideoWriter(saving_path, vid_profile);    

                % Framerate set.           
                video_object.FrameRate = framerate;

                % Quality set. 
                video_object.Quality = AVI_QUALITY;

                return;  % All done. 

            catch exception

                % A Runtime error that couldn't think of to handle (i.e. beyond
                % imagination error) has occured.
                errordlg(sprintf( ...
                    'Runtime Error:\n   %s', ...
                    exception.message), exception.identifier);

                return;  % Function terminated.

            end 

        end  % function (instantiateVideo)

                
        %% Vertify the properties
        function status = verifyProperties(saving_path, ...
                                           framerate, quality, ...
                                           vid_profile)
            %% Verification of parameters.
            % Checking the existence and validity of parameters.

            % A graphical object given?
            if ~exist('object', 'var')

                % Apprently not! Generate an error message.
                errordlg(sprintf( ...
                    ['Implementation Error:\n' ...
                     '   No graphical object was given.\n'...
                     '   The process is terminated prematurely.']));

                % Graphical object not given.
                status = false;  % Function terminated. 
                return;


            % Is the path to save the file given? if not, ask the user for it.
            elseif ~exist('saving_path', 'var')

                % Ask the user for a file name. 
                [avi_name, avi_path] = uiputfile('*.avi', ...
                                                 'Save video file as');


                % Cancelled? 
                if avi_name == 0 || avi_path == 0   
                    status = false;
                    return; % Cancelled by user.            
                end


                % Create a single string of the absolute path for saving the
                % final output file. 
                saving_path = strcat(avi_path, avi_name);

                % Is the path viable? Let's test.
                status = testPath();

                if ~status
                    % There is an I/O problem. 
                    % Error message displayed in the test. 
                    return;

                end  % if (status)

            end  % if (Essential parameters)


            %%
            % *Note*: |str2double| is faster than |str2num|. The former
            % throws an error if the variable passed is a mix of numbers 
            % and characters. The latter on the other hand, checks
            % (through iteration) for the existence of non-numeric 
            % characters, and if any exists, it returns an empty array.
            try

                % Check if the |framerate| given is a string object.
                if isa(framerate, 'char')
                    % Framerate is given as a string object. It is converted 
                    % into double. For more see section intro.
                    tmp = str2double(framerate);
                    framerate = uint8(tmp);


                % Otherwise: The user has done everything right. 
                else

                    % Convert |framerate| into an unsigned 8-bit integer.  
                    framerate = uint8(framerate);

                end  % if (framerate)


                % Check if |quality| is given as a string object.
                if isa(quality, 'char')

                    % Framerate is given as a string object. It is converted 
                    % into double. For more see section intro.
                    tmp = str2double(quality);
                    quality = uint16(tmp);
       

                % Otherwise: The user has done everything right.  
                else

                    % Convert |quality| into an unsigned 16-bit integer.
                    quality = uint16(quality);

                end  % if (quality)

                % If it gets so far, it's all good.
                status = true; 
                return; 

            catch exception  
                % Most likely induced by passing a mixture of strings and 
                % numbers to |str2double| - but you never know! So the actual 
                % message generated by MATLAB(R) is displayed.
                errordlg(sprintf(['Input Error:\n' ...
                                  '   %s \n' ...
                                  '   The process is terminated ' ...
                                  'prematurely.'], ...
                                  exception.message), exception.identifier);

                % Nothing else to do here until the user learns how to use the
                % application. So function is closed. 
                status = false;  % Function terminated.
                return;

            end  % try (non-essential vars)

        end  % function (vertifyProperties)


        %% Verify the 'save as' path
        function viability = testPath(saving_path)
            % Testing the viability of the path.
            %
            % For instance, does the user have sufficient permission to write
            % in this directory? or is the disk healthy? 
            try
                % Create and open a file in the given path. 
                test_file = fopen(saving_path, 'w'); 

                % Write into the file. 
                fprintf(test_file,'testing the file.'); 

                % Close the file object.
                fclose(test_file);

                % Does what it says! Deletes the test file.
                delete(saving_path)
                
                % I/O test passed. 
                viability = true;
                return;

            catch exception
                % There has been a problem with writing files in the given
                % path; most likely something to do with ownership or
                % permissions - but you never know! So the actual message
                % generated by MATLAB(R) is displayed.
                errordlg(sprintf(['I/O Error:\n' ...
                      '   %s \n' ...
                      '   The process is terminated prematurely.'],...
                      exception.message), exception.identifier);

                % I/O problem. 
                viability = false; 
                return;
                
            end % try (saving path test)
            
        end % function (testPath)
    

    end % methods
    
end % class

% Indentation level = 4 spaces. 
% Tab = 4 spaces (Tabs disabled.)
% Width standard: 80 column.

% vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
