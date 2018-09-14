
function varargout = maininterface(varargin)
% MAININTERFACE MATLAB code for maininterface.fig
%      MAININTERFACE, by itself, creates a new MAININTERFACE or raises the existing
%      singleton*.
%
%      H = MAININTERFACE returns the handle to a new MAININTERFACE or the handle to
%      the existing singleton*.
%
%      MAININTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAININTERFACE.M with the given input arguments.
%
%      MAININTERFACE('Property','Value',...) creates a new MAININTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before maininterface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to maininterface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help maininterface

% Last Modified by GUIDE v2.5 05-Dec-2015 11:21:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @maininterface_OpeningFcn, ...
                   'gui_OutputFcn',  @maininterface_OutputFcn, ...
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


% --- Executes just before maininterface is made visible.
function maininterface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to maininterface (see VARARGIN)

% Choose default command line output for maininterface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes maininterface wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = maininterface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;




function popupmenu1_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit1_Callback(hObject, eventdata, handles)


function edit1_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_Callback(hObject, eventdata, handles)


function edit2_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit3_Callback(hObject, eventdata, handles)


function edit3_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit6_Callback(hObject, eventdata, handles)


function edit6_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit5_Callback(hObject, eventdata, handles)


function edit5_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit4_Callback(hObject, eventdata, handles)


function edit4_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit8_Callback(hObject, eventdata, handles)


function edit8_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit9_Callback(hObject, eventdata, handles)


function edit9_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_FloorNum_Callback(hObject, eventdata, handles)


function edit_FloorNum_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_FloorHgt_Callback(hObject, eventdata, handles)


function edit_FloorHgt_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit12_Callback(hObject, eventdata, handles)


function edit12_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit21_Callback(hObject, eventdata, handles)


function edit21_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit22_Callback(hObject, eventdata, handles)


function edit22_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit15_Callback(hObject, eventdata, handles)


function edit15_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit16_Callback(hObject, eventdata, handles)


function edit16_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit17_Callback(hObject, eventdata, handles)


function edit17_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit18_Callback(hObject, eventdata, handles)


function edit18_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit19_Callback(hObject, eventdata, handles)


function edit19_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit20_Callback(hObject, eventdata, handles)


function edit20_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit13_Callback(hObject, eventdata, handles)


function edit13_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit14_Callback(hObject, eventdata, handles)


function edit14_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_LoadFile1_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton2_Callback(hObject, eventdata, handles)
[filename, pathname] =uigetfile({'*.xls;*.xlsx';'*.m';'*.slx';'*.mat';'*.*'},'请选择文件');
set(handles.edit_LoadFile1,'string',fullfile(pathname,filename));


function edit24_Callback(hObject, eventdata, handles)


function edit24_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit26_Callback(hObject, eventdata, handles)


function edit26_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit27_Callback(hObject, eventdata, handles)


function edit27_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit28_Callback(hObject, eventdata, handles)


function edit28_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit29_Callback(hObject, eventdata, handles)


function edit29_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit30_Callback(hObject, eventdata, handles)


function edit30_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit31_Callback(hObject, eventdata, handles)


function edit31_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when uipanel3 is resized.
function uipanel3_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to uipanel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit32_Callback(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit32 as text
%        str2double(get(hObject,'String')) returns contents of edit32 as a double


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit33_Callback(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit33 as text
%        str2double(get(hObject,'String')) returns contents of edit33 as a double


% --- Executes during object creation, after setting all properties.
function edit33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit34_Callback(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit34 as text
%        str2double(get(hObject,'String')) returns contents of edit34 as a double


% --- Executes during object creation, after setting all properties.
function edit34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] =uigetfile({'*.xls;*.xlsx';'*.m';'*.slx';'*.mat';'*.*'},'请选择文件');
set(handles.edit_LoadFile2,'string',fullfile(pathname,filename));


function edit35_Callback(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit35 as text
%        str2double(get(hObject,'String')) returns contents of edit35 as a double


% --- Executes during object creation, after setting all properties.
function edit35_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] =uigetfile({'*.xls;*.xlsx';'*.m';'*.slx';'*.mat';'*.*'},'请选择文件');
set(handles.edit_LoadFile3,'string',fullfile(pathname,filename));


function edit36_Callback(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit36 as text
%        str2double(get(hObject,'String')) returns contents of edit36 as a double


% --- Executes during object creation, after setting all properties.
function edit36_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit37_Callback(hObject, eventdata, handles)
% hObject    handle to edit37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit37 as text
%        str2double(get(hObject,'String')) returns contents of edit37 as a double


% --- Executes during object creation, after setting all properties.
function edit37_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit40_Callback(hObject, eventdata, handles)
% hObject    handle to edit40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit40 as text
%        str2double(get(hObject,'String')) returns contents of edit40 as a double


% --- Executes during object creation, after setting all properties.
function edit40_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit41_Callback(hObject, eventdata, handles)
% hObject    handle to edit41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit41 as text
%        str2double(get(hObject,'String')) returns contents of edit41 as a double


% --- Executes during object creation, after setting all properties.
function edit41_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit49_Callback(hObject, eventdata, handles)
% hObject    handle to edit49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit49 as text
%        str2double(get(hObject,'String')) returns contents of edit49 as a double


% --- Executes during object creation, after setting all properties.
function edit49_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit49 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_LoadFile2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_LoadFile2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_LoadFile2 as text
%        str2double(get(hObject,'String')) returns contents of edit_LoadFile2 as a double


% --- Executes during object creation, after setting all properties.
function edit_LoadFile2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_LoadFile2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_LoadFile3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_LoadFile3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_LoadFile3 as text
%        str2double(get(hObject,'String')) returns contents of edit_LoadFile3 as a double


% --- Executes during object creation, after setting all properties.
function edit_LoadFile3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_LoadFile3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ChillerWTD_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ChillerWTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ChillerWTD as text
%        str2double(get(hObject,'String')) returns contents of edit_ChillerWTD as a double


% --- Executes during object creation, after setting all properties.
function edit_ChillerWTD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ChillerWTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_OutdoorAR_Callback(hObject, eventdata, handles)
% hObject    handle to edit_OutdoorAR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_OutdoorAR as text
%        str2double(get(hObject,'String')) returns contents of edit_OutdoorAR as a double


% --- Executes during object creation, after setting all properties.
function edit_OutdoorAR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_OutdoorAR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_CondenserWTD_Callback(hObject, eventdata, handles)
% hObject    handle to edit_CondenserWTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_CondenserWTD as text
%        str2double(get(hObject,'String')) returns contents of edit_CondenserWTD as a double


% --- Executes during object creation, after setting all properties.
function edit_CondenserWTD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_CondenserWTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_HeatingWTD_Callback(hObject, eventdata, handles)
% hObject    handle to edit_HeatingWTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_HeatingWTD as text
%        str2double(get(hObject,'String')) returns contents of edit_HeatingWTD as a double


% --- Executes during object creation, after setting all properties.
function edit_HeatingWTD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_HeatingWTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_AHUAirSOT_Callback(hObject, eventdata, handles)
% hObject    handle to edit_AHUAirSOT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_AHUAirSOT as text
%        str2double(get(hObject,'String')) returns contents of edit_AHUAirSOT as a double


% --- Executes during object creation, after setting all properties.
function edit_AHUAirSOT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_AHUAirSOT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ChilledWST_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ChilledWST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ChilledWST as text
%        str2double(get(hObject,'String')) returns contents of edit_ChilledWST as a double


% --- Executes during object creation, after setting all properties.
function edit_ChilledWST_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ChilledWST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_CondenserWRT_Callback(hObject, eventdata, handles)
% hObject    handle to edit_CondenserWRT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_CondenserWRT as text
%        str2double(get(hObject,'String')) returns contents of edit_CondenserWRT as a double


% --- Executes during object creation, after setting all properties.
function edit_CondenserWRT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_CondenserWRT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_HeatingWST_Callback(hObject, eventdata, handles)
% hObject    handle to edit_HeatingWST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_HeatingWST as text
%        str2double(get(hObject,'String')) returns contents of edit_HeatingWST as a double


% --- Executes during object creation, after setting all properties.
function edit_HeatingWST_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_HeatingWST (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_MinVerticalZone.
function popup_MinVerticalZone_Callback(hObject, eventdata, handles)
% hObject    handle to popup_MinVerticalZone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_MinVerticalZone contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_MinVerticalZone


% --- Executes during object creation, after setting all properties.
function popup_MinVerticalZone_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_MinVerticalZone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_EnergySationNum.
function popup_EnergySationNum_Callback(hObject, eventdata, handles)
% hObject    handle to popup_EnergySationNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_EnergySationNum contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_EnergySationNum


% --- Executes during object creation, after setting all properties.
function popup_EnergySationNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_EnergySationNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_FloorRange_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FloorRange as text
%        str2double(get(hObject,'String')) returns contents of edit_FloorRange as a double


% --- Executes during object creation, after setting all properties.
function edit_FloorRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit61_Callback(hObject, eventdata, handles)
% hObject    handle to edit61 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit61 as text
%        str2double(get(hObject,'String')) returns contents of edit61 as a double


% --- Executes during object creation, after setting all properties.
function edit61_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit61 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit62_Callback(hObject, eventdata, handles)
% hObject    handle to edit62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit62 as text
%        str2double(get(hObject,'String')) returns contents of edit62 as a double


% --- Executes during object creation, after setting all properties.
function edit62_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit62 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit63_Callback(hObject, eventdata, handles)
% hObject    handle to edit63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit63 as text
%        str2double(get(hObject,'String')) returns contents of edit63 as a double


% --- Executes during object creation, after setting all properties.
function edit63_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit63 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit_FloorRange2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FloorRange2 as text
%        str2double(get(hObject,'String')) returns contents of edit_FloorRange2 as a double


% --- Executes during object creation, after setting all properties.
function edit_FloorRange2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit65_Callback(hObject, eventdata, handles)
% hObject    handle to edit65 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit65 as text
%        str2double(get(hObject,'String')) returns contents of edit65 as a double


% --- Executes during object creation, after setting all properties.
function edit65_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit65 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit66_Callback(hObject, eventdata, handles)
% hObject    handle to edit66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit66 as text
%        str2double(get(hObject,'String')) returns contents of edit66 as a double


% --- Executes during object creation, after setting all properties.
function edit66_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit66 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_FloorRange3_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FloorRange3 as text
%        str2double(get(hObject,'String')) returns contents of edit_FloorRange3 as a double


% --- Executes during object creation, after setting all properties.
function edit_FloorRange3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit69_Callback(hObject, eventdata, handles)
% hObject    handle to edit69 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit69 as text
%        str2double(get(hObject,'String')) returns contents of edit69 as a double


% --- Executes during object creation, after setting all properties.
function edit69_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit69 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit70_Callback(hObject, eventdata, handles)
% hObject    handle to edit70 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit70 as text
%        str2double(get(hObject,'String')) returns contents of edit70 as a double


% --- Executes during object creation, after setting all properties.
function edit70_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit70 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_FloorRange4_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FloorRange4 as text
%        str2double(get(hObject,'String')) returns contents of edit_FloorRange4 as a double


% --- Executes during object creation, after setting all properties.
function edit_FloorRange4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_LoadFile4_Callback(hObject, eventdata, handles)
% hObject    handle to edit_LoadFile4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_LoadFile4 as text
%        str2double(get(hObject,'String')) returns contents of edit_LoadFile4 as a double


% --- Executes during object creation, after setting all properties.
function edit_LoadFile4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_LoadFile4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] =uigetfile({'*.xls;*.xlsx';'*.m';'*.slx';'*.mat';'*.*'},'请选择文件');
set(handles.edit_LoadFile4,'string',fullfile(pathname,filename));




% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function popupmenu8_Callback(hObject, eventdata, handles)
Zone_Num=get(handles.popupmenu8,'value');
 switch Zone_Num
     case 2
        set(handles.text71,'Visible','on') ;
        set(handles.text131,'Visible','on') ;
        set(handles.edit_FloorRange,'Visible','on') ;
        set(handles.edit_FloorRangej,'Visible','on') ;
        set(handles.text156,'Visible','on') ;
        set(handles.pushbutton2,'Visible','on') ;
        set(handles.edit_LoadFile1,'Visible','on') ;
        set(handles.text132,'Visible','off') ;
        set(handles.text137,'Visible','off') ;
        set(handles.edit_FloorRange2,'Visible','off') ;
        set(handles.edit_FloorRange2j,'Visible','off') ;
        set(handles.text157,'Visible','off') ;
        set(handles.pushbutton3,'Visible','off') ;
        set(handles.edit_LoadFile2,'Visible','off') ;
        set(handles.text138,'Visible','off') ;
        set(handles.text143,'Visible','off') ;
        set(handles.edit_FloorRange3,'Visible','off') ;
        set(handles.edit_FloorRange3j,'Visible','off') ;
        set(handles.text158,'Visible','off') ;
        set(handles.pushbutton4,'Visible','off') ;
        set(handles.edit_LoadFile3,'Visible','off') ;
        set(handles.text144,'Visible','off') ;
        set(handles.text149,'Visible','off') ;
        set(handles.edit_FloorRange4,'Visible','off') ;
        set(handles.edit_FloorRange4j,'Visible','off') ;
        set(handles.text159,'Visible','off') ;
        set(handles.pushbutton7,'Visible','off') ;
        set(handles.edit_LoadFile4,'Visible','off') ;
        
         case 3
        set(handles.text71,'Visible','on') ;
        set(handles.text131,'Visible','on') ;
        set(handles.edit_FloorRange,'Visible','on') ;
        set(handles.edit_FloorRangej,'Visible','on') ;
        set(handles.text156,'Visible','on') ;
        set(handles.pushbutton2,'Visible','on') ;
        set(handles.edit_LoadFile1,'Visible','on') ;
        set(handles.text132,'Visible','on') ;
        set(handles.text137,'Visible','on') ;
        set(handles.edit_FloorRange2,'Visible','on') ;
        set(handles.edit_FloorRange2j,'Visible','on') ;
        set(handles.text157,'Visible','on') ;
        set(handles.pushbutton3,'Visible','on') ;
        set(handles.edit_LoadFile2,'Visible','on') ;
        set(handles.text138,'Visible','off') ;
        set(handles.text143,'Visible','off') ;
        set(handles.edit_FloorRange3,'Visible','off') ;
        set(handles.edit_FloorRange3j,'Visible','off') ;
        set(handles.text158,'Visible','off') ;
        set(handles.pushbutton4,'Visible','off') ;
        set(handles.edit_LoadFile3,'Visible','off') ;
        set(handles.text144,'Visible','off') ;
        set(handles.text149,'Visible','off') ;
        set(handles.edit_FloorRange4,'Visible','off') ;
         set(handles.edit_FloorRange4j,'Visible','off') ;
        set(handles.text159,'Visible','off') ;
        set(handles.pushbutton7,'Visible','off') ;
        set(handles.edit_LoadFile4,'Visible','off') ;
         case 4
        set(handles.text71,'Visible','on') ;
        set(handles.text131,'Visible','on') ;
        set(handles.edit_FloorRange,'Visible','on') ;
        set(handles.edit_FloorRangej,'Visible','on') ;
        set(handles.text156,'Visible','on') ;
        set(handles.pushbutton2,'Visible','on') ;
        set(handles.edit_LoadFile1,'Visible','on') ;
        set(handles.text132,'Visible','on') ;
        set(handles.text137,'Visible','on') ;
        set(handles.edit_FloorRange2,'Visible','on') ;
        set(handles.edit_FloorRange2j,'Visible','on') ;
        set(handles.text157,'Visible','on') ;
        set(handles.pushbutton3,'Visible','on') ;
        set(handles.edit_LoadFile2,'Visible','on') ;
        set(handles.text138,'Visible','on') ;
        set(handles.text143,'Visible','on') ;
        set(handles.edit_FloorRange3,'Visible','on') ;
         set(handles.edit_FloorRange3j,'Visible','on') ;
        set(handles.text158,'Visible','on') ;
        set(handles.pushbutton4,'Visible','on') ;
        set(handles.edit_LoadFile3,'Visible','on') ;
        set(handles.text144,'Visible','off') ;
        set(handles.text149,'Visible','off') ;
        set(handles.edit_FloorRange4,'Visible','off') ;
        set(handles.edit_FloorRange4j,'Visible','off') ;
        set(handles.text159,'Visible','off') ;
        set(handles.pushbutton7,'Visible','off') ;
        set(handles.edit_LoadFile4,'Visible','off') ;
        case 5
        set(handles.text71,'Visible','on') ;
        set(handles.text131,'Visible','on') ;
        set(handles.edit_FloorRange,'Visible','on') ;
        set(handles.edit_FloorRangej,'Visible','on') ;
        set(handles.text156,'Visible','on') ;
        set(handles.pushbutton2,'Visible','on') ;
        set(handles.edit_LoadFile1,'Visible','on') ;
        set(handles.text132,'Visible','on') ;
        set(handles.text137,'Visible','on') ;
        set(handles.edit_FloorRange2,'Visible','on') ;
        set(handles.edit_FloorRange2j,'Visible','on') ;
        set(handles.text157,'Visible','on') ;
        set(handles.pushbutton3,'Visible','on') ;
        set(handles.edit_LoadFile2,'Visible','on') ;
        set(handles.text138,'Visible','on') ;
        set(handles.text143,'Visible','on') ;
        set(handles.edit_FloorRange3,'Visible','on') ;
         set(handles.edit_FloorRange3j,'Visible','on') ;
        set(handles.text158,'Visible','on') ;
        set(handles.pushbutton4,'Visible','on') ;
        set(handles.edit_LoadFile3,'Visible','on') ;
        set(handles.text144,'Visible','on') ;
        set(handles.text149,'Visible','on') ;
        set(handles.edit_FloorRange4,'Visible','on') ;
        set(handles.edit_FloorRange4j,'Visible','on') ;
        set(handles.text159,'Visible','on') ;
        set(handles.pushbutton7,'Visible','on') ;
        set(handles.edit_LoadFile4,'Visible','on') ;
        
        
        
 end       


function pushbutton8_Callback(hObject, eventdata, handles)
if((get(handles.popup_MinVerticalZone,'value')==2)&&(get(handles.popup_EnergySationNum,'value')==2))
    run('figure1x1');
end
if((get(handles.popup_MinVerticalZone,'value')==2)&&(get(handles.popup_EnergySationNum,'value')==3))
    %run('figure1x1');
     msgbox('分区数少于能源站个数！','Error','error');
end
if((get(handles.popup_MinVerticalZone,'value')==3)&&(get(handles.popup_EnergySationNum,'value')==2))
    run('figure2x1');
end
if((get(handles.popup_MinVerticalZone,'value')==3)&&(get(handles.popup_EnergySationNum,'value')==3))
    run('figure2x2');
end
if((get(handles.popup_MinVerticalZone,'value')==4)&&(get(handles.popup_EnergySationNum,'value')==2))
    run('figure3x1');

end  
if((get(handles.popup_MinVerticalZone,'value')==4)&&(get(handles.popup_EnergySationNum,'value')==3))
    %run('figure3x2');
    run('figure3x2M');
end 
if((get(handles.popup_MinVerticalZone,'value')==5)&&(get(handles.popup_EnergySationNum,'value')==2))
    %run('figure4x1');
    msgbox('一个能源站最多控制三个分区！','Error','error');
end 
if((get(handles.popup_MinVerticalZone,'value')==5)&&(get(handles.popup_EnergySationNum,'value')==3))
   % run('figure4x2');
   run('figure4x2M');
end 
if((get(handles.popup_MinVerticalZone,'value')==6)&&(get(handles.popup_EnergySationNum,'value')==2))
    %run('figure5x1');
    msgbox('一个能源站最多控制三个分区！','Error','error');
end 
if((get(handles.popup_MinVerticalZone,'value')==6)&&(get(handles.popup_EnergySationNum,'value')==3))
   % run('figure5x2');
    run('figure5x2M');
end 
if((get(handles.popup_MinVerticalZone,'value')==7)&&(get(handles.popup_EnergySationNum,'value')==2))
    %run('figure6x1');
    msgbox('一个能源站最多控制三个分区！','Error','error');
end
if((get(handles.popup_MinVerticalZone,'value')==7)&&(get(handles.popup_EnergySationNum,'value')==3))
    run('figure6x2');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%{
BuildingInf='!!BuildingInformation';
FloorNum=strcat('      FloorNumber',':',get(handles.edit_FloorNum,'String'));
FloorHgt=strcat('      FloorHeight',':',get(handles.edit_FloorHgt,'String'));
Topology='   !Topology';%}
ZoneNum=strcat('      ZoneNumber',':',num2str(get(handles.popup_MinVerticalZone,'Value'))-1);
EnergySta=strcat('      EnergyStation',':',num2str(get(handles.popup_EnergySationNum,'Value'))-1);
dlmwrite('InputParameters.txt',BuildingInf,'-append','delimiter','');%第2行赋值
dlmwrite('InputParameters.txt',FloorNum,'-append','delimiter','');%第3行赋值
dlmwrite('InputParameters.txt',FloorHgt,'-append','delimiter','');%第4行赋值
dlmwrite('InputParameters.txt',Topology,'-append','delimiter','');%第5行赋值
dlmwrite('InputParameters.txt',ZoneNum,'-append','delimiter','');%第6行赋值
dlmwrite('InputParameters.txt',EnergySta,'-append','delimiter','');%第7行赋值
dlmwrite('InputParameters.txt','   !Representive Floor','-append','delimiter','');%第8行赋值
% --- 典型层参数部分
% 典型层1
RepresentiveFloorNum=strcat('      !Representive Floor Number',':',num2str(get(handles.popupmenu8,'Value'))-1);
FloorRge1=strcat('      Floor Range',':',get(handles.edit_FloorRange,'String'));
LoadFile1=strcat('      Floor Load File1 Path',':',get(handles.edit_LoadFile1,'String'));
dlmwrite('InputParameters.txt',RepresentiveFloorNum,'-append','delimiter','');%第9行赋值
dlmwrite('InputParameters.txt','   !Representive Floor 1','-append','delimiter','');%第10行赋值
dlmwrite('InputParameters.txt',FloorRge1,'-append','delimiter','');%第11行赋值
dlmwrite('InputParameters.txt',LoadFile1,'-append','delimiter','');%第12行赋值
% 典型层2
FloorRge2=strcat('      Floor Range',':',get(handles.edit_FloorRange2,'String'));
LoadFile2=strcat('      Floor Load File1 Path',':',get(handles.edit_LoadFile2,'String'));
dlmwrite('InputParameters.txt','   !Representive Floor 2','-append','delimiter','');%第13行赋值
dlmwrite('InputParameters.txt',FloorRge2,'-append','delimiter','');%第14行赋值
dlmwrite('InputParameters.txt',LoadFile2,'-append','delimiter','');%第15行赋值
% 典型层3
FloorRge3=strcat('      Floor Range',':',get(handles.edit_FloorRange3,'String'));
LoadFile3=strcat('      Floor Load File1 Path',':',get(handles.edit_LoadFile3,'String'));
dlmwrite('InputParameters.txt','   !Representive Floor 3','-append','delimiter','');%第16行赋值
dlmwrite('InputParameters.txt',FloorRge3,'-append','delimiter','');%第17行赋值
dlmwrite('InputParameters.txt',LoadFile3,'-append','delimiter','');%第18行赋值
% 典型层4
FloorRge4=strcat('      Floor Range',':',get(handles.edit_FloorRange4,'String'));
LoadFile4=strcat('      Floor Load File1 Path',':',get(handles.edit_LoadFile4,'String'));
dlmwrite('InputParameters.txt','   !Representive Floor 4','-append','delimiter','');%第16行赋值
dlmwrite('InputParameters.txt',FloorRge4,'-append','delimiter','');%第17行赋值
dlmwrite('InputParameters.txt',LoadFile4,'-append','delimiter','');%第18行赋值
%}
%----用excel导出数据
% building information
edit_FloorNum=get(handles.edit_FloorNum,'String');
edit_FloorHgt=get(handles.edit_FloorHgt,'String');
ZoneNum=num2str(get(handles.popup_MinVerticalZone,'Value')-1);
EnergySta=num2str(get(handles.popup_EnergySationNum,'Value')-1);
RepresentiveFloorNum=num2str(get(handles.popupmenu8,'Value')-1);
FloorEquip=get(handles.edit83,'String');
xlswrite('Input.xlsx',{FloorEquip},1,'C16');
TimeStart_month=get(handles.popupmenu12,'Value')-1;
TimeStart_day=get(handles.popupmenu13,'Value')-1;
TimeEnd_month=get(handles.popupmenu14,'Value')-1;
TimeEnd_day=get(handles.popupmenu15,'Value')-1;
TimeStart_matrix=[{TimeStart_month},{TimeStart_day}];
TimeEnd_matrix=[{TimeEnd_month},{TimeEnd_day}];
xlswrite('Input.xlsx',TimeStart_matrix,1,'D494');
xlswrite('Input.xlsx',TimeEnd_matrix,1,'D495');
% --- 典型层参数部分
% 典型层1
edit_Floor=get(handles.edit_FloorRange,'String');
edit_Floorj=get(handles.edit_FloorRangej,'String');
xlswrite('Input.xlsx',{edit_Floorj},1,'D7');
%editor_FloorRange1=strcat(edit_Floor,',',edit_Floorj);
LoadFile1=get(handles.edit_LoadFile1,'String');
% 典型层2
edit_Floor2=get(handles.edit_FloorRange2,'String');
edit_Floor2j=get(handles.edit_FloorRange2j,'String');
xlswrite('Input.xlsx',{edit_Floor2j},1,'D9');
%editor_FloorRange2=strcat(edit_Floor2,',',edit_Floor2j);
LoadFile2=get(handles.edit_LoadFile2,'String');
% 典型层3
edit_Floor3=get(handles.edit_FloorRange3,'String');
edit_Floor3j=get(handles.edit_FloorRange3j,'String');
xlswrite('Input.xlsx',{edit_Floor3j},1,'D11');
%editor_FloorRange3=strcat(edit_Floor3,',',edit_Floor3j);
LoadFile3=get(handles.edit_LoadFile3,'String');
% 典型层4
edit_Floor4=get(handles.edit_FloorRange4,'String');
edit_Floor4j=get(handles.edit_FloorRange4j,'String');
xlswrite('Input.xlsx',{edit_Floor4j},1,'D13');
%editor_FloorRange4=strcat(edit_Floor4,',',edit_Floor4j);
LoadFile4=get(handles.edit_LoadFile4,'String');
%建立数据存储矩阵1
A=[{edit_FloorNum};{edit_FloorHgt};{ZoneNum};{EnergySta};{RepresentiveFloorNum};...
    {edit_Floor};{LoadFile1};{edit_Floor2};{LoadFile2};...
    {edit_Floor3};{LoadFile3};{edit_Floor4};{LoadFile4}];
xlswrite('Input.xlsx',A,1,'C2');
%---Design Information
%HVAC system parameters
OutdoorAR=get(handles.edit_OutdoorAR,'String');
ChillerWTD=get(handles.edit_ChillerWTD,'String');
CondenserWTD=get(handles.edit_CondenserWTD,'String');
HeatingWTD=get(handles.edit_HeatingWTD,'String');
AHUAirSOT=get(handles.edit_AHUAirSOT,'String');
ChilledWST=get(handles.edit_ChilledWST,'String');
CondenserWRT=get(handles.edit_CondenserWRT,'String');
HeatingWST=get(handles.edit_HeatingWST,'String');
DesignWSWP=get(handles.edit_DesignWSWP,'String');
% Outdoor Parameters
pupup_seletct=get(handles.popup_CitySelecte,'Value');
switch pupup_seletct
    case 1
        CitySelected='Please Selected!';
    case 2
        CitySelected='Shanghai';
    case 3
        CitySelected='Beijing';
    case 4
        CitySelected='Tianjin';
    case 5
        CitySelected='Shenzhen';
    case 6
        CitySelected='Foshan';
    case 7
        CitySelected='Guangzhou';    
end
%Indor Parameters
DryBT=get(handles.edit_DryBT,'String');
RaletiveH=get(handles.edit_RaletiveH,'String');
% Build matrix 2
B=[{OutdoorAR};{ChillerWTD};{CondenserWTD};{HeatingWTD};{AHUAirSOT};{ChilledWST};{CondenserWRT};...
    {HeatingWST};{DesignWSWP};{CitySelected};{DryBT};{RaletiveH}];
xlswrite('Input.xlsx',B,1,'C481');

[ElectricityAll,GBCFPower,GBCFPowerPump,EcoCost,CapCostAll,C]=GUIHVACSimulation('Input.xlsx');
global GBCFPowerAll
if str2num(EnergySta)==1
    GBCFPowerAll=GBCFPower;
    AHUElectricity=(sum(GBCFPowerAll(:,1)))/1000;
    ChillerElectricity=(sum(GBCFPowerAll(:,2)))/1000;
    PumpElectricity=(sum(GBCFPowerAll(:,3))+sum(GBCFPowerAll(:,4))+sum(GBCFPowerAll(:,5)))/1000;
    CoolingTowerElectricity=(sum(GBCFPowerAll(:,6)))/1000;
elseif str2num(EnergySta)==2
    GBCFPowerAll=(GBCFPower{1,1}+GBCFPower{2,1});
    AHUElectricity=(sum(GBCFPowerAll(:,1)))/1000;
    ChillerElectricity=(sum(GBCFPowerAll(:,2)))/1000;
    PumpElectricity=(sum(GBCFPowerAll(:,3))+sum(GBCFPowerAll(:,4))+sum(GBCFPowerAll(:,5)))/1000;
    CoolingTowerElectricity=(sum(GBCFPowerAll(:,6)))/1000;
    
end
%输出参数写入
set(handles.edit24,'string',ElectricityAll/1000);
set(handles.edit27,'string',AHUElectricity);
set(handles.edit26,'string',ChillerElectricity);
set(handles.edit28,'string',PumpElectricity);
set(handles.edit31,'string',CoolingTowerElectricity);
set(handles.edit49,'string',CapCostAll);
xnum = 1:1:size(GBCFPowerAll,1);
ynum= GBCFPowerAll(:,1);
plot(handles.axes1,xnum,ynum);
legend(handles.axes1,'AHU逐时电量耗');
%output Parameters
OutputInformation=[{ElectricityAll/1000};{AHUElectricity};{ChillerElectricity};{PumpElectricity};{CoolingTowerElectricity};{CapCostAll}];
 xlswrite('SimulationOutput.xlsx',OutputInformation,1,'B2');



function edit_FloorRangej_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FloorRangej (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FloorRangej as text
%        str2double(get(hObject,'String')) returns contents of edit_FloorRangej as a double


% --- Executes during object creation, after setting all properties.
function edit_FloorRangej_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FloorRangej (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit74_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FloorRange2 as text
%        str2double(get(hObject,'String')) returns contents of edit_FloorRange2 as a double


% --- Executes during object creation, after setting all properties.
function edit74_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_FloorRange2j_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange2j (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FloorRange2j as text
%        str2double(get(hObject,'String')) returns contents of edit_FloorRange2j as a double


% --- Executes during object creation, after setting all properties.
function edit_FloorRange2j_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange2j (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit76_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FloorRange3 as text
%        str2double(get(hObject,'String')) returns contents of edit_FloorRange3 as a double


% --- Executes during object creation, after setting all properties.
function edit76_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_FloorRange3j_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange3j (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FloorRange3j as text
%        str2double(get(hObject,'String')) returns contents of edit_FloorRange3j as a double


% --- Executes during object creation, after setting all properties.
function edit_FloorRange3j_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange3j (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit78_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FloorRange4 as text
%        str2double(get(hObject,'String')) returns contents of edit_FloorRange4 as a double


% --- Executes during object creation, after setting all properties.
function edit78_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_FloorRange4j_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange4j (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_FloorRange4j as text
%        str2double(get(hObject,'String')) returns contents of edit_FloorRange4j as a double


% --- Executes during object creation, after setting all properties.
function edit_FloorRange4j_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FloorRange4j (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_DesignWSWP_Callback(hObject, eventdata, handles)
% hObject    handle to edit_DesignWSWP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_DesignWSWP as text
%        str2double(get(hObject,'String')) returns contents of edit_DesignWSWP as a double


% --- Executes during object creation, after setting all properties.
function edit_DesignWSWP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_DesignWSWP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_DryBT_Callback(hObject, eventdata, handles)
% hObject    handle to edit_DryBT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_DryBT as text
%        str2double(get(hObject,'String')) returns contents of edit_DryBT as a double


% --- Executes during object creation, after setting all properties.
function edit_DryBT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_DryBT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_RaletiveH_Callback(hObject, eventdata, handles)
% hObject    handle to edit_RaletiveH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_RaletiveH as text
%        str2double(get(hObject,'String')) returns contents of edit_RaletiveH as a double


% --- Executes during object creation, after setting all properties.
function edit_RaletiveH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_RaletiveH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_CitySelecte.
function popup_CitySelecte_Callback(hObject, eventdata, handles)
% hObject    handle to popup_CitySelecte (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_CitySelecte contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_CitySelecte


% --- Executes during object creation, after setting all properties.
function popup_CitySelecte_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_CitySelecte (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu11.
function popupmenu11_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu11 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu11
% Outdoor Parameters
global GBCFPowerAll;
xnum = 1:1:size(GBCFPowerAll,1);
pupup11_seletct=get(handles.popupmenu11,'Value');
switch pupup11_seletct
    case 1
        ynum1= GBCFPowerAll(:,1);
        plot(handles.axes1,xnum,ynum1);
        legend(handles.axes1,'AHU逐时电量耗');
    case 2
        ynum2= GBCFPowerAll(:,2);
        plot(handles.axes1,xnum,ynum2);
        legend(handles.axes1,'冷水机组逐时电耗');
    case 3
        ynum3= GBCFPowerAll(:,3)+GBCFPowerAll(:,4)+GBCFPowerAll(:,5);
        plot(handles.axes1,xnum,ynum3);
        legend(handles.axes1,'水泵逐时电量耗');
    case 4
        ynum4= GBCFPowerAll(:,6);
        plot(handles.axes1,xnum,ynum4);
        legend(handles.axes1,'冷却塔逐时电量耗');
end



% --- Executes during object creation, after setting all properties.
function popupmenu11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit83_Callback(hObject, eventdata, handles)
% hObject    handle to edit83 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit83 as text
%        str2double(get(hObject,'String')) returns contents of edit83 as a double


% --- Executes during object creation, after setting all properties.
function edit83_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit83 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu12.
function popupmenu12_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu12 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu12


% --- Executes during object creation, after setting all properties.
function popupmenu12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu13.
function popupmenu13_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu13 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu13


% --- Executes during object creation, after setting all properties.
function popupmenu13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu14.
function popupmenu14_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu14 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu14


% --- Executes during object creation, after setting all properties.
function popupmenu14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu15.
function popupmenu15_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu15 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu15


% --- Executes during object creation, after setting all properties.
function popupmenu15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
