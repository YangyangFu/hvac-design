function varargout = optimizitiongui(varargin)
% OPTIMIZITIONGUI MATLAB code for optimizitiongui.fig
%      OPTIMIZITIONGUI, by itself, creates a new OPTIMIZITIONGUI or raises the existing
%      singleton*.
%
%      H = OPTIMIZITIONGUI returns the handle to a new OPTIMIZITIONGUI or the handle to
%      the existing singleton*.
%
%      OPTIMIZITIONGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTIMIZITIONGUI.M with the given input arguments.
%
%      OPTIMIZITIONGUI('Property','Value',...) creates a new OPTIMIZITIONGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before optimizitiongui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to optimizitiongui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help optimizitiongui

% Last Modified by GUIDE v2.5 05-Dec-2015 14:56:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @optimizitiongui_OpeningFcn, ...
                   'gui_OutputFcn',  @optimizitiongui_OutputFcn, ...
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


% --- Executes just before optimizitiongui is made visible.
function optimizitiongui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to optimizitiongui (see VARARGIN)
% Choose default command line output for optimizitiongui
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes optimizitiongui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = optimizitiongui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Zone_Num=get(handles.popupmenu1,'value');
 switch Zone_Num
     case 2
        set(handles.text6,'Visible','on') ;
        set(handles.text7,'Visible','on') ;
        set(handles.edit4,'Visible','on') ;
        set(handles.edit6,'Visible','on') ;
        set(handles.text10,'Visible','on') ;
        set(handles.pushbutton1,'Visible','on') ;
        set(handles.edit3,'Visible','on') ;
        set(handles.text8,'Visible','off') ;
        set(handles.text28,'Visible','off') ;
        set(handles.edit7,'Visible','off') ;
        set(handles.edit8,'Visible','off') ;
        set(handles.text11,'Visible','off') ;
        set(handles.pushbutton2,'Visible','off') ;
        set(handles.edit5,'Visible','off') ;
        set(handles.text12,'Visible','off') ;
        set(handles.text29,'Visible','off') ;
        set(handles.edit11,'Visible','off') ;
        set(handles.edit12,'Visible','off') ;
        set(handles.text16,'Visible','off') ;
        set(handles.pushbutton3,'Visible','off') ;
        set(handles.edit9,'Visible','off') ;
        set(handles.text14,'Visible','off') ;
        set(handles.text30,'Visible','off') ;
        set(handles.edit13,'Visible','off') ;
        set(handles.edit14,'Visible','off') ;
        set(handles.text17,'Visible','off') ;
        set(handles.pushbutton4,'Visible','off') ;
        set(handles.edit10,'Visible','off') ;
        
         case 3
         set(handles.text6,'Visible','on') ;
        set(handles.text7,'Visible','on') ;
        set(handles.edit4,'Visible','on') ;
        set(handles.edit6,'Visible','on') ;
        set(handles.text10,'Visible','on') ;
        set(handles.pushbutton1,'Visible','on') ;
        set(handles.edit3,'Visible','on') ;
        set(handles.text8,'Visible','on') ;
        set(handles.text28,'Visible','on') ;
        set(handles.edit7,'Visible','on') ;
        set(handles.edit8,'Visible','on') ;
        set(handles.text11,'Visible','on') ;
        set(handles.pushbutton2,'Visible','on') ;
        set(handles.edit5,'Visible','on') ;
        set(handles.text12,'Visible','off') ;
        set(handles.text29,'Visible','off') ;
        set(handles.edit11,'Visible','off') ;
        set(handles.edit12,'Visible','off') ;
        set(handles.text16,'Visible','off') ;
        set(handles.pushbutton3,'Visible','off') ;
        set(handles.edit9,'Visible','off') ;
        set(handles.text14,'Visible','off') ;
        set(handles.text30,'Visible','off') ;
        set(handles.edit13,'Visible','off') ;
        set(handles.edit14,'Visible','off') ;
        set(handles.text17,'Visible','off') ;
        set(handles.pushbutton4,'Visible','off') ;
        set(handles.edit10,'Visible','off') ;
        case 4
        set(handles.text6,'Visible','on') ;
        set(handles.text7,'Visible','on') ;
        set(handles.edit4,'Visible','on') ;
        set(handles.edit6,'Visible','on') ;
        set(handles.text10,'Visible','on') ;
        set(handles.pushbutton1,'Visible','on') ;
        set(handles.edit3,'Visible','on') ;
        set(handles.text8,'Visible','on') ;
        set(handles.text28,'Visible','on') ;
        set(handles.edit7,'Visible','on') ;
        set(handles.edit8,'Visible','on') ;
        set(handles.text11,'Visible','on') ;
        set(handles.pushbutton2,'Visible','on') ;
        set(handles.edit5,'Visible','on') ;
        set(handles.text12,'Visible','on') ;
        set(handles.text29,'Visible','on') ;
        set(handles.edit11,'Visible','on') ;
        set(handles.edit12,'Visible','on') ;
        set(handles.text16,'Visible','on') ;
        set(handles.pushbutton3,'Visible','on') ;
        set(handles.edit9,'Visible','on') ;
        set(handles.text14,'Visible','off') ;
        set(handles.text30,'Visible','off') ;
        set(handles.edit13,'Visible','off') ;
        set(handles.edit14,'Visible','off') ;
        set(handles.text17,'Visible','off') ;
        set(handles.pushbutton4,'Visible','off') ;
        set(handles.edit10,'Visible','off') ;
        case 5
        set(handles.text6,'Visible','on') ;
        set(handles.text7,'Visible','on') ;
        set(handles.edit4,'Visible','on') ;
        set(handles.edit6,'Visible','on') ;
        set(handles.text10,'Visible','on') ;
        set(handles.pushbutton1,'Visible','on') ;
        set(handles.edit3,'Visible','on') ;
        set(handles.text8,'Visible','on') ;
        set(handles.text28,'Visible','on') ;
        set(handles.edit7,'Visible','on') ;
        set(handles.edit8,'Visible','on') ;
        set(handles.text11,'Visible','on') ;
        set(handles.pushbutton2,'Visible','on') ;
        set(handles.edit5,'Visible','on') ;
        set(handles.text12,'Visible','on') ;
        set(handles.text29,'Visible','on') ;
        set(handles.edit11,'Visible','on') ;
        set(handles.edit12,'Visible','on') ;
        set(handles.text16,'Visible','on') ;
        set(handles.pushbutton3,'Visible','on') ;
        set(handles.edit9,'Visible','on') ;
        set(handles.text14,'Visible','on') ;
        set(handles.text30,'Visible','on') ;
        set(handles.edit13,'Visible','on') ;
        set(handles.edit14,'Visible','on') ;
        set(handles.text17,'Visible','on') ;
        set(handles.pushbutton4,'Visible','on') ;
        set(handles.edit10,'Visible','on') ;
        
        
        
 end       

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] =uigetfile({'*.xls;*.xlsx'},'请选择文件');
set(handles.edit3,'string',fullfile(pathname,filename));


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] =uigetfile({'*.xls;*.xlsx'},'请选择文件');
set(handles.edit5,'string',fullfile(pathname,filename));


function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
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
[filename, pathname] =uigetfile({'*.xls;*.xlsx'},'请选择文件');
set(handles.edit9,'string',fullfile(pathname,filename));


function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
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
[filename, pathname] =uigetfile({'*.xls;*.xlsx'},'请选择文件');
set(handles.edit10,'string',fullfile(pathname,filename));


function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Checkbox1Num=get(handles.checkbox1,'value');
if(Checkbox1Num==1)
    set(handles.edit18,'Visible','off') ;
else
    set(handles.edit18,'Visible','on') ;
end
function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% OptimitionType parameters
global Optimition_type;
global StartTime;
global EndTime;
popupmenu2_select=get(handles.popupmenu2,'value');
switch popupmenu2_select
    case 1
        Optimition_select='Please Selected!';
    case 2
        Optimition_select='Energy';
    case 3
        Optimition_select='Economic';
    case 4
        Optimition_select='Energy&Economic';
end
Optimition_type=Optimition_select;
starttime_month=num2str((get(handles.popupmenu4,'value')-1));
starttime_day=num2str(get(handles.popupmenu5,'value')-1);
endttime_month=num2str((get(handles.popupmenu6,'value')-1));
endttime_day=num2str(get(handles.popupmenu7,'value')-1);
StartTime=strcat(starttime_month,'/',starttime_day);
EndTime=strcat(endttime_month,'/',endttime_day);
%% Design variable
global Design_variable;
Value_edit18=str2num(get(handles.edit18,'String'));
Value_edit19=str2num(get(handles.edit19,'String'));
Value_edit20=str2num(get(handles.edit20,'String'));
Value_edit21=str2num(get(handles.edit21,'String'));
Value_edit22=str2num(get(handles.edit22,'String'));
Value_edit23=str2num(get(handles.edit23,'String'));
Value_edit24=str2num(get(handles.edit24,'String'));
if(get(handles.checkbox1,'value')==1)
    Value_edit18=-1;
end
if(get(handles.checkbox2,'value')==1)
    Value_edit19=-1;
end
if(get(handles.checkbox3,'value')==1)
    Value_edit20=-1;
end
if(get(handles.checkbox4,'value')==1)
    Value_edit21=-1;
end
if(get(handles.checkbox5,'value')==1)
    Value_edit22=-1;
end
if(get(handles.checkbox6,'value')==1)
    Value_edit23=-1;
end
if(get(handles.checkbox7,'value')==1)
    Value_edit24=-1;
end
Design_variable=[{get(handles.checkbox1,'value')},{get(handles.checkbox2,'value')},{get(handles.checkbox3,'value')},{get(handles.checkbox4,'value')},{get(handles.checkbox5,'value')},{get(handles.checkbox6,'value')},{get(handles.checkbox7,'value')};...
    {Value_edit18},{Value_edit19},{Value_edit20},{Value_edit21},{Value_edit22},{Value_edit23},{Value_edit24}];
%% Algorithem parameters
global Generation;
global Population;
Generation=str2num(get(handles.edit15,'String'));
Population=str2num(get(handles.edit16,'String'));
%% Objective Building
global Tipical_floornum;
global Design_drytem;
global Design_rh;
global City_select;
global Floor_num;
global Floor_hgt;
global Floor_equip;
popupmenu3_select=get(handles.popupmenu3,'value');
switch popupmenu3_select
    case 1
        CitySelect='Please Selected!';
    case 2
        CitySelect='Shanghai';
    case 3
        CitySelect='Beijing';
    case 4
        CitySelect='Tianjin';
    case 5
        CitySelect='Shenzhen';
    case 6
        CitySelect='Foshan';
    case 7
        CitySelect='Guangzhou';
        
end
City_select=CitySelect;
Tipical_floornum=get(handles.popupmenu1,'value')-1;
Design_drytem=str2num(get(handles.edit1,'String'));
Design_rh=str2num(get(handles.edit2,'String'));
Floor_num=str2num(get(handles.edit26,'String'));
Floor_hgt=str2num(get(handles.edit27,'String'));
Floor_equip=get(handles.edit28,'String');
global TipicalFloor1_index;
global TipicalFloor2_index;
global TipicalFloor3_index;
global TipicalFloor4_index;
TipicalFloor1_index=[{str2num(get(handles.edit4,'String'))},str2num(get(handles.edit6,'String'))];
TipicalFloor2_index=[{str2num(get(handles.edit7,'String'))},str2num(get(handles.edit8,'String'))];
TipicalFloor3_index=[{str2num(get(handles.edit11,'String'))},str2num(get(handles.edit12,'String'))];
TipicalFloor4_index=[{str2num(get(handles.edit13,'String'))},str2num(get(handles.edit14,'String'))];
global TipicalFloor1_loadfile;
global TipicalFloor2_loadfile;
global TipicalFloor3_loadfile;
global TipicalFloor4_loadfile;
if(Tipical_floornum==0)
    TipicalFloor1_loadfile=0;
    TipicalFloor2_loadfile=0;
    TipicalFloor3_loadfile=0;
    TipicalFloor4_loadfile=0;
    TipicalFloor1_index=0;
    TipicalFloor2_index=0;
    TipicalFloor3_index=0;
    TipicalFloor4_index=0;
end
if(Tipical_floornum==1)
    TipicalFloor1_loadfile=xlsread(get(handles.edit3,'String'));
    [row1,col1]=size(TipicalFloor1_loadfile);
    if row1~=8760
        error ('please give load file1 in R1 with 8760 hour data!')
    end
    TipicalFloor2_loadfile=0;
    TipicalFloor3_loadfile=0;
    TipicalFloor4_loadfile=0;
    TipicalFloor2_index=0;
    TipicalFloor3_index=0;
    TipicalFloor4_index=0;
end
if(Tipical_floornum==2)
    TipicalFloor1_loadfile=xlsread(get(handles.edit3,'String'));
    [row1,col1]=size(TipicalFloor1_loadfile);
    if row1~=8760
        error ('please give load file1 in R1 with 8760 hour data!')
    end
    TipicalFloor2_loadfile=xlsread(get(handles.edit5,'String'));
    [row1,col1]=size(TipicalFloor2_loadfile);
    if row1~=8760
        error ('please give load file2 in R1 with 8760 hour data!')
    end
    TipicalFloor3_loadfile=0;
    TipicalFloor4_loadfile=0;
    TipicalFloor3_index=0;
    TipicalFloor4_index=0;
end
if(Tipical_floornum==3)
    TipicalFloor1_loadfile=xlsread(get(handles.edit3,'String'));
    [row1,col1]=size(TipicalFloor1_loadfile);
    if row1~=8760
        error ('please give load file1 in R1 with 8760 hour data!')
    end
    TipicalFloor2_loadfile=xlsread(get(handles.edit5,'String'));
    [row1,col1]=size(TipicalFloor2_loadfile);
    if row1~=8760
        error ('please give load file2 in R1 with 8760 hour data!')
    end
    TipicalFloor3_loadfile=xlsread(get(handles.edit9,'String'));
    [row1,col1]=size(TipicalFloor3_loadfile);
    if row1~=8760
        error ('please give load file3 in R1 with 8760 hour data!')
    end
    TipicalFloor4_loadfile=0;
    TipicalFloor4_index=0;
end
if(Tipical_floornum==4)
    TipicalFloor1_loadfile=xlsread(get(handles.edit3,'String'));
    [row1,col1]=size(TipicalFloor1_loadfile);
    if row1~=8760
        error ('please give load file1 in R1 with 8760 hour data!')
    end
    TipicalFloor2_loadfile=xlsread(get(handles.edit5,'String'));
    [row1,col1]=size(TipicalFloor2_loadfile);
    if row1~=8760
        error ('please give load file2 in R1 with 8760 hour data!')
    end
    TipicalFloor3_loadfile=xlsread(get(handles.edit9,'String'));
    [row1,col1]=size(TipicalFloor3_loadfile);
    if row1~=8760
        error ('please give load file3 in R1 with 8760 hour data!')
    end
    TipicalFloor4_loadfile=xlsread(get(handles.edit10,'String'));
    [row1,col1]=size(TipicalFloor4_loadfile);
    if row1~=8760
        error ('please give load file4 in R1 with 8760 hour data!')
    end
end
global x;
x=1;
OptInput.Generation=Generation;
OptInput.Population=Population;
OptInput.Design.Variable=Design_variable;


OptInput.City=City_select;
OptInput.Design.IndoorRH=Design_rh/100;
OptInput.Design.IndoorTDry=Design_drytem;

OptInput.Floor_equip=Floor_equip;
OptInput.Floor_high=Floor_hgt;
OptInput.Floor_num=Floor_num;

OptInput.TypicalFloorNum = Tipical_floornum;
OptInput.TypicalFloor1_index=TipicalFloor1_index;
OptInput.TypicalFloor1_loadfile=TipicalFloor1_loadfile;
OptInput.TypicalFloor2_index=TipicalFloor2_index;
OptInput.TypicalFloor2_loadfile=TipicalFloor2_loadfile;
OptInput.TypicalFloor3_index=TipicalFloor3_index;
OptInput.TypicalFloor3_loadfile=TipicalFloor3_loadfile;
OptInput.TypicalFloor4_index=TipicalFloor4_index;
OptInput.TypicalFloor4_loadfile=TipicalFloor4_loadfile;

OptInput.Time.StartDate=[2015,str2num(char(regexp(StartTime,'/','split')))'];
OptInput.Time.EndDate=[2015,str2num(char(regexp(EndTime,'/','split')))'];


switch Optimition_select
    case 'Energy' 
        Re=SingleObjective_energy(OptInput);
    case 'Economic'
        Re=SingleObjective_Economic(OptInput);
    case  'Energy&Economic'
        Re = MultiObjectiveOptimization(OptInput);
end
% Save the results

switch Optimition_select
    case 'Energy' 
       % optimization objective
         xlswrite('OptimizationOutput.xlsx',{Optimition_select},1,'B2');
       % optimization variables  
         xlswrite('OptimizationOutput.xlsx',cell2mat(Design_variable)',1,'B3:C10');
       % optimization results
         xlswrite('OptimizationOutput.xlsx',Re.x',1,'C11:C17');
         xlswrite('OptimizationOutput.xlsx',Re.fval,1,'C18');     
         xlswrite('OptimizationOutput.xlsx',{'W.h'},1,'D18');
    case 'Economic'
       % optimization objective
         xlswrite('OptimizationOutput.xlsx',{Optimition_select},1,'B2');
       % optimization variables  
         xlswrite('OptimizationOutput.xlsx',cell2mat(Design_variable)',1,'B3:C19');
       % optimization results
         xlswrite('OptimizationOutput.xlsx',Re.x',1,'C11:C17');
         xlswrite('OptimizationOutput.xlsx',Re.fval,1,'C18');
         xlswrite('OptimizationOutput.xlsx',{'Dollor'},1,'D18');
    case  'Energy&Economic'
       % optimization objective
         xlswrite('OptimizationOutput.xlsx',{Optimition_select},1,'B2');
       % optimization variables  
         xlswrite('OptimizationOutput.xlsx',cell2mat(Design_variable)',1,'B3:C10');
       % optimization results
         plot_AllPoints(Re);
         xlswrite('OptimizationOutput.xlsx',{'Multiple Obejective Results are Saved in "populations.txt"'},1,'A20');
end

% optimization end caption
button=questdlg('Optimization is finished. Do You Want to Quit？','Quit','YES','NO','NO');
if strcmp(button,'YES')
    close optimizitiongui;
else
    return;
end



function checkbox2_Callback(hObject, eventdata, handles)
Checkbox2Num=get(handles.checkbox2,'value');
if(Checkbox2Num==1)
    set(handles.edit19,'Visible','off') ;
else
    set(handles.edit19,'Visible','on') ;
end
function checkbox3_Callback(hObject, eventdata, handles)
Checkbox3Num=get(handles.checkbox3,'value');
if(Checkbox3Num==1)
    set(handles.edit20,'Visible','off') ;
else
    set(handles.edit20,'Visible','on') ;
end
function checkbox4_Callback(hObject, eventdata, handles)
Checkbox4Num=get(handles.checkbox4,'value');
if(Checkbox4Num==1)
    set(handles.edit21,'Visible','off') ;
else
    set(handles.edit21,'Visible','on') ;
end
function checkbox5_Callback(hObject, eventdata, handles)
Checkbox5Num=get(handles.checkbox5,'value');
if(Checkbox5Num==1)
    set(handles.edit22,'Visible','off') ;
else
    set(handles.edit22,'Visible','on') ;
end
function checkbox6_Callback(hObject, eventdata, handles)
Checkbox6Num=get(handles.checkbox6,'value');
if(Checkbox6Num==1)
    set(handles.edit23,'Visible','off') ;
else
    set(handles.edit23,'Visible','on') ;
end
function checkbox7_Callback(hObject, eventdata, handles)
Checkbox7Num=get(handles.checkbox7,'value');
if(Checkbox7Num==1)
    set(handles.edit24,'Visible','off') ;
else
    set(handles.edit24,'Visible','on') ;
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(optimizitiongui);


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit26_Callback(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit26 as text
%        str2double(get(hObject,'String')) returns contents of edit26 as a double


% --- Executes during object creation, after setting all properties.
function edit26_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit27_Callback(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit27 as text
%        str2double(get(hObject,'String')) returns contents of edit27 as a double


% --- Executes during object creation, after setting all properties.
function edit27_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
