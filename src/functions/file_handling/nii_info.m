function [ info, img_didata, data_type ] = nii_info( path )
% NII_INFO(path): Gets the path to a <.nii> NifTi file as a Char object and 
%                 returns [info, img_dats, data_type].
%  
%   REQUIRES: None
%
%   INPUT
%   =======================================================================
%   path         Must be either an absolute path, or a relative path with 
%                respect to the location of the function / executable.
%
%
%   RETURN
%   =======================================================================
%   INFO         Details of the <NifTi> file, including the name, date, 
%                bytes, isdir, and datenum. 
%
%   IMG_DATS     A 8x1 double, specifying image data including the spacial 
%                dimensions of the <NifTi> image in positions 2:4. 
%
%   DATA_TYPE    Char object containing the type corresponding to the
%                <NifTi> file, which can be uint8, int16, int32, float, 
%                double. If none of these class types apply, an error is 
%                raised. 
%
%==========================================================================
% author            Pouria Hadjibagheri
% last modified     26 November 2015
% matlab version    MATLAB R2015b
% Licence           GPLv2.0
% Coding convention PEP8: https://www.python.org/dev/peps/pep-0008/
%==========================================================================

    START_LOC = 'bof';
    
    % Standard location and length for <dimension> data in NifTi.
    DIMENSIONS_LOC = 40;   % bytes
    DIMENSION_INFO = 1;    % bytes
 
    % Space used to store each individual dimension, according to the
    % convention. 
    DIMENSION_SPACE = 2;   % bytes
    
    % Standard location and length for <data type code> in NifTi. 
    DATA_TYPE_LOC = 70;    % bytes
    DATA_TYPE_TOTAL = 1;   % byte
    
    % A <short> type variable is sufficient for dimension / data type info. 
    SHORT_TYPE = 'short';
    
    try 
        % Returns [info].
        info = dir(path);
        file_data = fopen(path);
    catch exception
        fprintf('Unable to access file <%s>.\n', path);
        rethrow(exception);
    end

    fseek(file_data, DIMENSIONS_LOC, START_LOC);
    
    % Returns [img_didata].
    dimension_total = fread(file_data, DIMENSION_INFO, SHORT_TYPE);
    dimension_total_space = dimension_total * DIMENSION_SPACE;
    img_didata = fread(file_data, dimension_total_space, SHORT_TYPE);
    
    fseek(file_data, DATA_TYPE_LOC, START_LOC);
    data_type_code = fread(file_data, DATA_TYPE_TOTAL, SHORT_TYPE);
    
    fclose(file_data); 

    % Defining the corresponding object type.
    % Returns [data_type].
    switch data_type_code
        case 2
            data_type = 'uint8';
        case 4
            data_type = 'int16';
        case 8
            data_type = 'int32';
        case 16
            data_type = 'float';
        case 64
            data_type = 'double';
        otherwise
            error('Type Error: Invalid data type.');
    end

end

