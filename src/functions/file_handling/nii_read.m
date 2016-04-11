function [ image_matrix, pixdim ] = nii_read( path )
%NII_READ(path): Gets the path to a <.nii> NifTi file as a Char object and 
%                returns a ready-to-render matrix of the image. 
%
%   REQUIRES: nii_info
%
%   INPUT
%   =======================================================================
%   path         Must be either an absolute path, or a relative path with 
%                respect to the location of the function / executable.
%
%
%   RETURN
%   =======================================================================
%   IMAGE_MATRIX Matrix of type double of the data retrieved from the NifTi 
%                file ready for additional manipulation or rendering as an 
%                image. 
%
%==========================================================================
% author            Pouria Hadjibagheri
% last modified     26 November 2015
% matlab version    MATLAB R2015b
% licence           GPLv2.0
%==========================================================================
    
    %% Constants
    % Information on NifTi header format, as defined in the convention. 
    % To see the convention, visit the official website of United States 
    % National Institute of Mental Health (NIMH) at 
    % <http://nifti.nimh.nih.gov/pub/dist/src/niftilib/nifti1.h>.
   
    % Standard length of NifTi header.
    HEADER_LEN = uint16(352);    % bytes
      
    % Standard location and length for <dimension> data in NifTi.
    DIMS_LOCATION = uint8(40);   % bytes
    DIMS_TOTAL = uint8(8);       % bytes
    DIMS_INFO_INDEX = uint8(1);  % Index of total number of dimensions.
    FIRST_DIM_INDEX = uint8(2);  % Index of first dimension.
    
    PIXDIM_LOCATION = uint8(76); % Offset location of the pixdim (40 + 36).
    PIXDIM_START = uint8(2);     % Location where the volumetric data exists.
    PIXDIM_TOTAL = uint8(8);     % bytes
    
    % Standard location and length for <data type code> in NifTi. 
    DATA_TYPE_LOC = uint8(70);   % bytes
    DATA_TYPE_TOTAL = uint8(1);  % byte
    
    %% 
    % Other constants:
    
    % Beginning of the file. 
    BEGINNING = 'bof';
    
    % Data type for dimensions. 
    SHORT_TYPE = 'short';
    
    % Data type for voxels' volumetric data. 
    PIXDIM_TYPE = 'single';
    
    %% Handling the binary file
    % Reading header information from the binary file.
    try 
        % Open file.
        % fopen(file_path)
        file_data = fopen(path); 
        
        % Cursor to the location of dimensions information.
        % fseek(file, offset, origin)
        fseek(file_data, DIMS_LOCATION, BEGINNING);
        
        % Read dimension data from binary file. 
        % fread(file, size, precision)
        img_data = fread(file_data, DIMS_TOTAL, SHORT_TYPE);
        
    catch exception
        fprintf('Unable to access file <%s>.\n', path);
        rethrow(exception);
    end
    
    %% Retrive dimensions
    % Data array dimensions are defined in an 8-byte range. 
    % 
    % Byte 1 corresponds to the number of dimensions defined
    % in the current file.
    % NifTi reserves bytes 2, 3, 4 for space (x, y, z), 5 for time (t), 
    % and 6, 7, 8 for anything else needed. 
    
    % Total number of dimensions.
    dim_total = img_data(DIMS_INFO_INDEX);
    
    % 8 bytes 
    last_dim_index = dim_total + DIMS_INFO_INDEX;
    
    % Storing dimensions based on |dim_total| and discarding the unused ones.
    img_dims = img_data(FIRST_DIM_INDEX:last_dim_index);

    
    fseek(file_data, DATA_TYPE_LOC, BEGINNING);
    data_type_code = fread(file_data, DATA_TYPE_TOTAL, SHORT_TYPE);
    
    % Get the dimensions. 
    fseek(file_data, PIXDIM_LOCATION, BEGINNING);
    pixdim_data = fread(file_data, PIXDIM_TOTAL, PIXDIM_TYPE);
    % +1 is to substitute for the first bit ignored (the unit).
    pixdim = pixdim_data(PIXDIM_START:dim_total+1);
    
    % Defining the corresponding object type in MATLAB.
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
    
    try
        fseek(file_data, HEADER_LEN, BEGINNING);
        voxels = fread(file_data, prod(img_dims), data_type); 
        fclose(file_data);  % Close file
    catch exception
        fprintf('Unable to access file <%s>.\n', path);
        rethrow(exception);
    end
  
    % Reshape to the correct dimensions.
    % Returns [image_matrix].
    image_matrix = reshape(voxels, transpose(img_dims));
    
end

