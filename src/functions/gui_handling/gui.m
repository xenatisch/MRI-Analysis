%% Graphical User Interface.
% This script contains a number of functions which handle the events of the
% graphical user interface, and respond according. This is not a stand-alone
% function. It requires all other functions and scripts to be in place before 
% it can perform correctly. Should you feel adventurous and mad keen enough 
% to modify this script, do so at your own risk. It might make you cry, pull 
% out your hair, or break your CPU. You have been warned! 
%
% Improper modification of the functions in this script can easily break it, 
% or amount to the production of unexpected, chiefly incorrect, and 
% sometimes rather bizzare results.
% 
% Finally; don't do GUI in MATLAB(R)... Go learn a real programming language,
% like Python. 
%
%%

%%
% *General information*
%
%       Author          Pouria Hadjibagheri
%       Last modified   24 December 2015
%       Matlab version  MATLAB R2015b
%       Licence         GPLv2.0
%

%%
function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,~,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @gui_OpeningFcn, ...
                       'gui_OutputFcn',  @gui_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT

    

%%    
% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)
%
% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
    
    TEXT_PROPERTY = 'String';
    ORIENT_INIT = 'SAGITTAL';  % Initial orientation
    VALUE = 'Value';
    IDENTIFIER = 'Tag';
    SLIDER_MIN = 'Min';
    SLIDER_MAX = 'Max';
    STEPS = 'SliderStep';
    MIN_VAL = uint8(1);     

    % Asking the user to open a NifTi file.
    dialog_title = 'Select a NifTi image: NifTi 4D image...';
    file_type = '*.nii';
    file_description = 'NifTi Image (*.nii)';

    nifti_file = openFile(dialog_title, file_type, file_description);
    
    % GUI-wide variable, accissible to other functions in GUI.
    handles.nifti_img = nii_read(nifti_file);
    
    image_size = size(handles.nifti_img);
        
    
    % Retrieving NifTi image info
    [info, img_dims, data_type] = nii_info(nifti_file);

    % Displaying NifTi image info on the GUI. 
    set(findobj(IDENTIFIER,'file_name'),TEXT_PROPERTY, info.name);
    set(findobj(IDENTIFIER,'file_date'),TEXT_PROPERTY, info.date);
    set(findobj(IDENTIFIER,'file_bytes'),TEXT_PROPERTY, info.bytes);
    set(findobj(IDENTIFIER,'file_datenum'),TEXT_PROPERTY, info.datenum);
    set(findobj(IDENTIFIER,'data_dims'),TEXT_PROPERTY, img_dims);
    set(findobj(IDENTIFIER,'data_type'),TEXT_PROPERTY, data_type);
    
    
    %%
    % Creating a |structure|, whose map is as follows:
    %
    % Structure
    % 
    %   > -- dimension name; e.g. |'SAGITTAL'|
    %
    %          > -- dimension index; e.g. |uint(1)| 
    %
    %          > -- corresponding slider tag (GUI); e.g. |'slice2dSlider'|
    %
    % The purpose of creating this structure is (1) to prevent repeating
    % the definitions in for individual functions across the GUI, (2) to
    % make the code more versatille and prone to improvements in the
    % future, and (3) to simplify and standardise the use of iteration
    % loops for modifying the corresponding elements in the GUI. 
    %
    % Note: Order of storage in the structure is irrelevant. 
    
    % Defining the fields and values of the structure
    field1 = 'SAGITTAL';   
    value1 = {uint8(1), 'slice2dSlider'};
    
    field2 = 'CORONAL';    
    value2 = {uint8(2), 'slice2dSlider'};
    
    field3 = 'AXIAL';      
    value3 = {uint8(3), 'slice2dSlider'};
    
    field4 = 'TIMELINE2D'; 
    value4 = {uint8(4), 'time2dSlider'};
    
    field5 = 'TIMELINE3D'; 
    value5 = {uint8(4), 'time3dSlider'};
    
    % Creating the structure.
    sliders = struct(field1, value1, ...
                     field2, value2, ...
                     field3, value3, ...
                     field4, value4, ...
                     field5, value5);
    
    % Making the structure available to other functions in the GUI. 
    handles.sliders = sliders; 
    
  
    %%
    % Getting the field names from the structure.
    %
    % *Note*: for calculating major and minor steps for a slider, take
    % these points into account:
    %
    % $$ step_{minor} \leq step_{major} $$
    %
    % A rule of thumb for getting it right is, for major steps: 
    %
    % $$ step_{major} = \frac{100}{value_{max}} $$
    %
    % and for minor steps:
    %
    % $$ step_{minor} = \frac{step_{major}}{value_{max} \times step_{major}} $$
    %
    sliders_field_names = fieldnames(sliders);
    
    % Iterating through the names. 
    for fn_cell=transpose(sliders_field_names)
        
        fn_char = char(fn_cell{1});  % Struct to string <char>. 
        
        if strcmp(fn_char, ORIENT_INIT) || ...          % Initial orientation (constant).
                  strcmp(fn_char, 'TIMELINE2D') || ...  % Initial display in 2D.
                  strcmp(fn_char, 'TIMELINE3D')
                  
            % Retriving dimension index and the slider object's tag. 
            [dim_index, slider_tag] = sliders.(fn_char); 

            if ~(dim_index <= length(image_size))
                handles.sliders= NaN; 
                break;
            end
            % Slider maximum value.
            max_val = uint16(image_size(dim_index));

            % Slider middle value. The default (starting) position.
            mid_val = max_val/2;

            % Sliders's step function |SliderStep| takes 2 values for minor and major steps.  
            % NOTE: Step values must be <double>; but final values
            %       must be integer as they're used for indexing. 
            major_step = 100/double(max_val);
            minor_step = major_step/(double(max_val)*major_step);

            % Finding GUI object based on its tag.
            slider_obj = findobj(IDENTIFIER, (slider_tag));

            % Modifying the parameters of the GUI object stored in |slider_obj|. 
            set(slider_obj, SLIDER_MIN, MIN_VAL);             % Minimum value
            set(slider_obj, SLIDER_MAX, max_val);             % Maxumum value
            set(slider_obj, STEPS, [minor_step major_step]);  % Step values
            set(slider_obj, VALUE, mid_val);                  % Default value
            
        end
        
    end
    
    % Default command line output for gui.
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);


    
    
%%
% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;

    
    
%%
% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, ~, handles)
% hObject    handle to pushbutton1 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%     for iter=1
        disp(get(findobj(IDENTIFIER, 'slice2dSlider'), 'Value'));
        % Class made in Export. Implement here. 


%%
% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, ~, handles)
% hObject    handle to popupmenu1 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from popupmenu1

    
    
    
%%
% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, ~, handles)
% hObject    handle to popupmenu1 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
             get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


    
%%    
% --- Executes on slider movement.
function slider2_Callback(hObject, ~, handles)
% hObject    handle to slider2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    IDENTIFIER = 'Tag';
    CURRENT_VALUE = 'Value';
    TEXT = 'String';
    
    if ~isa(handles.sliders, 'struct')
        time_slider_position = uint8(get(findobj(IDENTIFIER, 'time2dSlider'), CURRENT_VALUE));
    else
        time_slider_position = NaN;
    end  
    
    slice_slider_position = uint16(get(findobj(IDENTIFIER, 'slice2dSlider'), CURRENT_VALUE));
    orientation = uint8(get(findobj(IDENTIFIER, 'orientationCombo'), CURRENT_VALUE));

    sliced_img = getSlice(handles.nifti_img, slice_slider_position, orientation, time_slider_position);

    imagesc(sliced_img);
    axis ij;
    colormap(bone);
    
    set(findobj(IDENTIFIER, 'text_slice'), TEXT, slice_slider_position);
    set(findobj(IDENTIFIER, 'text_time'), TEXT, time_slider_position);
    
    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


    
%%    
% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, ~, handles)
% hObject    handle to slider2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
    
   
    
    
%%    
function edit1_Callback(hObject, ~, handles)
% hObject    handle to edit1 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of edit1 as text
    %        str2double(get(hObject,'String')) returns contents of edit1 as a double


    
%%    
% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, ~, handles)
% hObject    handle to edit1 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
             get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


    
%%    
% --- Executes on key press with focus on edit1 and none of its controls.
function edit1_KeyPressFcn(hObject, ~, handles)
% hObject    handle to edit1 (see GCBO)
% ~  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)



%%
% --- Executes on slider movement.
function slider3_Callback(hObject, ~, handles)
% hObject    handle to slider3 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    CURRENT_VALUE = 'Value';
    IDENTIFIER = 'Tag';
    TEXT = 'String';
    INVISIBLE = 'off';
    VISIBLE = 'on';
    VISIBILITY = 'Visible';
    
    if ~isa(handles.sliders, 'struct')
        set(hObject, VISIBILITY, INVISIBLE);
        set(findobj(IDENTIFIER, 'text4'), VISIBILITY, INVISIBLE);
        return
    else
        set(hObject, VISIBILITY, VISIBLE);
        set(findobj(IDENTIFIER, 'text4'), VISIBILITY, VISIBLE);
    end
    
    time_slider_position = uint8(get(findobj(IDENTIFIER, 'time2dSlider'), CURRENT_VALUE));
    slice_slider_position = uint16(get(findobj(IDENTIFIER, 'slice2dSlider'), CURRENT_VALUE));
    orientation = uint8(get(findobj(IDENTIFIER, 'orientationCombo'), CURRENT_VALUE));

    sliced_img = getSlice(handles.nifti_img, slice_slider_position, orientation, time_slider_position);
    imagesc(sliced_img);
    axis ij; 
    colormap(bone);
    set(findobj(IDENTIFIER, 'text_slice'), TEXT, slice_slider_position);
    set(findobj(IDENTIFIER, 'text_time'), TEXT, time_slider_position);
        
    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


    
%%    
% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, ~, handles)
% hObject    handle to slider3 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end
    
    
%%
% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, ~, handles)
% hObject    handle to popupmenu2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    CURRENT_VALUE = 'Value';
    IDENTIFIER = 'Tag';
    TEXT = 'String';
    SAGITTAL = 1;
    CORONAL = 2;
    AXIAL = 3;
    
    time_slider_position = uint16(get(findobj(IDENTIFIER, 'time2dSlider'), CURRENT_VALUE));
    slice_slider_position = uint16(get(findobj(IDENTIFIER, 'slice2dSlider'), CURRENT_VALUE));
    orientation = uint8(get(findobj(IDENTIFIER, 'orientationCombo'), CURRENT_VALUE));

    sliced_img = getSlice(handles.nifti_img, slice_slider_position, orientation, time_slider_position);

    imagesc(sliced_img);
    axis ij; 
    colormap(bone);
    
    switch orientation
        case SAGITTAL
            orient_name = 'Sagittal';
        case CORONAL
            orient_name = 'Coronal';
        case AXIAL
            orient_name = 'Axial';
    end
    
    set(findobj(IDENTIFIER, 'text_slice'), TEXT, slice_slider_position);
    set(findobj(IDENTIFIER, 'text_time'), TEXT, time_slider_position);
    
    % Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from popupmenu2

    
    
%%
% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, ~, handles)
% hObject    handle to popupmenu2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
             get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



%%    
function edit3_Callback(hObject, ~, handles)
% hObject    handle to edit3 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of edit3 as text
    %        str2double(get(hObject,'String')) returns contents of edit3 as a double

    
    
%%
% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, ~, handles)
% hObject    handle to edit3 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
             get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


    
%%    
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, ~, handles)
% hObject    handle to pushbutton2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



%%
% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, ~, handles)
% hObject    handle to pushbutton3 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



%%
% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, ~, handles)
% hObject    handle to popupmenu5 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from popupmenu5

    
    
%%
% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, ~, handles)
% hObject    handle to popupmenu5 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
             get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


    
    
%%
function edit5_Callback(hObject, ~, handles)
% hObject    handle to edit5 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of edit5 as text
    %        str2double(get(hObject,'String')) returns contents of edit5 as a double

    
    
%%
% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, ~, handles)
% hObject    handle to edit5 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
             get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
    

%%
% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over radiobutton2.
function radiobutton2_ButtonDownFcn(hObject, ~, handles)
% hObject    handle to radiobutton2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



%%
% --- Executes on button press in radiobutton2.
% Render in 3D.
function radiobutton2_Callback(hObject, ~, handles)
% hObject    handle to radiobutton2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of radiobutton2

    CURRENT_VALUE = 'Value';
    IDENTIFIER = 'Tag';
    VISIBILITY = 'Visible';
    VISIBLE = 'on';
    INVISIBLE = 'off';
    
    delete(get(gca,'Children'))    % Removing any existing plots.

    time_slider_position = uint16(get(findobj(IDENTIFIER, 'time3dSlider'), CURRENT_VALUE));

    spacial_img = get3d(handles.nifti_img, time_slider_position);
        
    set(findobj(IDENTIFIER, 'frame2dTools'), VISIBILITY, INVISIBLE);
    
    render3d(spacial_img);
        
    set(findobj(IDENTIFIER, 'frame3dTools'), VISIBILITY, VISIBLE);
            
 
         
         
%%       
% --- Executes on button press in radiobutton2.
function radiobutton1_Callback(hObject, ~, handles)
% hObject    handle to radiobutton2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton2

    CURRENT_VALUE = 'Value';
    IDENTIFIER = 'Tag';
    VISIBILITY = 'Visible';
    VISIBLE = 'on';
    INVISIBLE = 'off';
    
    if ~isa(handles.sliders, 'struct')
        time_slider_position = uint16(get(findobj(IDENTIFIER, 'time2dSlider'), CURRENT_VALUE));
        set(findobj(IDENTIFIER, 'time2dSlider'), VISIBILITY, VISIBLE);
        set(findobj(IDENTIFIER, 'text4'), VISIBILITY, VISIBLE);
    else
        time_slider_position = NaN;
        set(findobj(IDENTIFIER, 'time2dSlider'), VISIBILITY, INVISIBLE);
        set(findobj(IDENTIFIER, 'text4'), VISIBILITY, INVISIBLE);
    end
    
    
    slice_slider_position = uint16(get(findobj(IDENTIFIER, 'slice2dSlider'), CURRENT_VALUE));
    orientation = uint8(get(findobj(IDENTIFIER, 'orientationCombo'), CURRENT_VALUE));
    
    sliced_img = getSlice(handles.nifti_img, ...
                          slice_slider_position, ...
                          orientation, ...
                          time_slider_position);

    set(findobj(IDENTIFIER, 'frame3dTools'), VISIBILITY, INVISIBLE);

    imagesc(sliced_img);
    axis ij; 
    colormap(bone);
    
    set(findobj(IDENTIFIER, 'frame2dTools'), VISIBILITY, VISIBLE);

    

%%    
% --- Executes on button press in radiobutton2.
% Hide axes
function radiobutton12_Callback(hObject, ~, handles)
% hObject    handle to radiobutton2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    axis off;
    
    
    
%%    
% --- Executes on button press in radiobutton2.
% Show axes
function radiobutton11_Callback(hObject, ~, handles)
% hObject    handle to radiobutton2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    axis on;
    
    
    
%%    
% --- Executes on button press in radiobutton2.
% Rough edges (Original)
function radiobutton13_Callback(hObject, ~, handles)
% hObject    handle to radiobutton2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    CURRENT_VALUE = 'Value';
    IDENTIFIER = 'Tag';
    
    delete(get(gca,'Children'));    % Removing any existing plots.
    axis tight; 

    time_slider_position = int8(get(findobj(IDENTIFIER, 'time3dSlider'), CURRENT_VALUE));

    spacial_img = get3d(handles.nifti_img, time_slider_position); 

    render3d(spacial_img);
             
    % Hint: get(hObject,'Value') returns toggle state of radiobutton2
        
    
    
%%    
% --- Executes on button press in radiobutton2.
% Smooth
function radiobutton14_Callback(hObject, ~, handles)
% hObject    handle to radiobutton2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    CURRENT_VALUE = 'Value';
    IDENTIFIER = 'Tag';
    
    delete(get(gca,'Children'));    % Removing any existing plots.
    axis tight; 

    time_slider_position = uint8(get(findobj(IDENTIFIER, 'time3dSlider'), CURRENT_VALUE));
    
    spacial_img = get3d(handles.nifti_img, time_slider_position);
        
    renderSmooth3d(spacial_img);
    
        
    
    
%%    
% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, ~, handles)
% hObject    handle to slider3 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: slider controls usually have a light gray background.
    if isequal(get(hObject,'BackgroundColor'), ...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end


    
%%    
function slider4_Callback(hObject, ~, handles)
% hObject    handle to radiobutton2 (see GCBO)
% ~  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    TEXT = 'String';
    CURRENT_VALUE = 'Value';
    IDENTIFIER = 'Tag';

    time_slider_position = uint8(get(hObject, CURRENT_VALUE));
    render_smooth = uint8(get(findobj(IDENTIFIER, 'radio3dSmooth'), CURRENT_VALUE));
        
    delete(get(gca,'Children'));    % Removing any existing plots.

    spacial_img = get3d(handles.nifti_img, time_slider_position);
    
    if render_smooth     
        
        renderSmooth3d(spacial_img);
        
    else 
        
        render3d(spacial_img);
    
    end
    
    axis tight; 
    
    set(findobj(IDENTIFIER, 'time3dtext'), TEXT, time_slider_position);

