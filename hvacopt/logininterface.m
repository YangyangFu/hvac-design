function varargout = logininterface(varargin)
% LOGININTERFACE MATLAB code for logininterface.fig
%      LOGININTERFACE, by itself, creates a new LOGININTERFACE or raises the existing
%      singleton*.
%
%      H = LOGININTERFACE returns the handle to a new LOGININTERFACE or the handle to
%      the existing singleton*.
%
%      LOGININTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOGININTERFACE.M with the given input arguments.
%
%      LOGININTERFACE('Property','Value',...) creates a new LOGININTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before logininterface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to logininterface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help logininterface

% Last Modified by GUIDE v2.5 26-Nov-2015 16:05:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @logininterface_OpeningFcn, ...
                   'gui_OutputFcn',  @logininterface_OutputFcn, ...
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


% --- Executes just before logininterface is made visible.
function logininterface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to logininterface (see VARARGIN)

% Choose default command line output for logininterface
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes logininterface wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = logininterface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
guidata(hObject, handles);
ha=axes('units','normalized','position',[0 0 1 1]);
uistack(ha,'down');
II=imread('logininterface1.jpg');
image(II);
colormap gray;
set(ha,'handlevisibility','off','visible','off');


function pushbutton1_Callback(hObject, eventdata, handles)
run('maininterface');

function pushbutton2_Callback(hObject, eventdata, handles)
button=questdlg('是否确认退出','退出确认','是','否','否');
if strcmp(button,'是')
    close all;
else
    return;
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
run('optimizitiongui');
