function [ spacial_img ] = get3d( nd_matrix, timeframe )
%GET3D     Gets NifTi image as a 3D or 4D array and returns a 3D matrix 
%          corresponding to the specifications given, ready to be rendered
%          or manipulated as a 3D image. 
%
%% Dependencies 
% None.
%
%% Inputs
%
% |nd_matrix|......double: 3D or 4D array.
% Matrix containing the NifTi image.
%
% |timeframe|......double: between 0 and 1.
%
% |ex_frame|.......integer: between 1 and n.
% Not a mandatory input. If not given, defaults to 0. Used for optimisation of GUI. 
% Not useful if the function is used stand-alone. 
%
%% Returns
%
%   spacial_img   > double: 3D array
%
%   current_frame > integer: between 1 and n.
%
%
%% Information
%
%       Author          Pouria Hadjibagheri
%       Last modified   24 December 2015
%       Matlab version  MATLAB R2015b
%       Licence         GPLv2.0
%

%%    

    %% Defining constants.
    % |persistent| constants are used so that once a place is allocated to
    % these constants on the memory, it is held for as long as the 
    % application is open. It differs to |global| in that these constants
    % are not available outside this function. However, it optimises the 
    % application in that it eliminates the need for the reintroduction of 
    % these constants every time the function in invoked. It also makes the
    % use of RAM more efficient by ensuring consecutive allocations where 
    % possible. These variables are additionally useful if the code is
    % converted into C. 
    persistent TIMELINE;
    
    if isempty('TIMELINE')
        TIMELINE = uint8(4);
    end
    
    img_size = size(nd_matrix);
    frame_total = img_size(TIMELINE);
    
    if timeframe <= 0
        warning(['Invalid input: Requested frame is smaller than one. ' ...
                 'First frame is returned.'])
        timeframe = uint8(1);
        
    elseif timeframe > frame_total
        error(['Value Error:\n Requested frame number exceeds the maximum ' ...
               'number of frames <max = %d> in the image.'], frame_total);
    end
    
    spacial_img = nd_matrix(:, :, :, timeframe);
    
end

