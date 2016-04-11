function [ adjusted_view ] = getSlice( nd_matrix, slice, orientation, timeframe )
%GET_SLICE Gets NifTi image as a 3D or 4D array and returns a single slice 
%          corresponding to the specifications given, ready to be rendered
%          as a 2D image. 
%
%   REQUIRES: None.
%
%   INPUT
%   =======================================================================
%   nd_matrix       > double: 3D or 4D array.
%                   Matrix containing the NifTi image.
%
%   slice           > double: between 0 and 1.
%
%   orientation     > integer: between 1 and 4.
%
%   timeframe       > double: between 0 and 1.
%
%
%   RETURN
%   =======================================================================
%   adjusted_view   > double: 2D array
%
%
%==========================================================================
% author            Pouria Hadjibagheri
% last modified     23 December 2015
% matlab version    MATLAB R2015b
% licence           GPLv2.0
%==========================================================================
    
    % Defining constants
    % |persistent| constants are used so that once a place is allocated to
    % these constants on the memory, it is held for as long as the 
    % application is open. It differs to |global| in that these constants
    % are not available outside this function. However, it optimises the 
    % application in that it eliminates the need for the reintroduction of 
    % these constants every time the function in invoked. It also makes the
    % use of RAM more efficient by ensuring consecutive allocations where 
    % possible. These variables are additionally useful if the code is
    % converted into C. 
    persistent SAGITTAL
    persistent CORONAL
    persistent AXIAL
    
    if isempty(SAGITTAL)
        SAGITTAL = uint8(1);
        CORONAL = uint8(2);
        AXIAL = uint8(3);
    end
    
    if slice < 1
        slice = 1;
    end 
    
    switch orientation  
        
        case SAGITTAL
            if ~isnan(timeframe)
                img_slice = squeeze(nd_matrix(slice, :, :, timeframe));
            else
                img_slice = squeeze(nd_matrix(slice, :, :));
            end
            
        case CORONAL
            if ~isnan(timeframe)
                img_slice = squeeze(nd_matrix(:, slice, :, timeframe));
            else
                img_slice = squeeze(nd_matrix(:, slice, :));
            end
        
        case AXIAL
            if ~isnan(timeframe)
                img_slice = squeeze(nd_matrix(:, :, slice, timeframe));
            else
                img_slice = squeeze(nd_matrix(:, :, slice));
            end
            
    end 

    transposed_slice = transpose(img_slice);
    adjusted_view = flipud(transposed_slice);
    
end

