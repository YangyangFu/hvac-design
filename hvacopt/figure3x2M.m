function varargout = figure3x2M(varargin)
% FIGURE3X2M MATLAB code for figure3x2M.fig
%      FIGURE3X2M, by itself, creates a new FIGURE3X2M or raises the existing
%      singleton*.
%
%      H = FIGURE3X2M returns the handle to a new FIGURE3X2M or the handle to
%      the existing singleton*.
%
%      FIGURE3X2M('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGURE3X2M.M with the given input arguments.
%
%      FIGURE3X2M('Property','Value',...) creates a new FIGURE3X2M or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before figure3x2M_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to figure3x2M_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help figure3x2M

% Last Modified by GUIDE v2.5 21-Oct-2015 11:55:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @figure3x2M_OpeningFcn, ...
                   'gui_OutputFcn',  @figure3x2M_OutputFcn, ...
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


% --- Executes just before figure3x2M is made visible.
function figure3x2M_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to figure3x2M (see VARARGIN)

% Choose default command line output for figure3x2M
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes figure3x2M wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = figure3x2M_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function pushbutton1_Callback(hObject, eventdata, handles)
global a;
switch a
    case 'radiobutton1';
        run('figure3x2');
        TopologyOpt=1;
        %dlmwrite('InputParameters.txt',TopologyOpt,'delimiter','');
        xlswrite('Input.xlsx',TopologyOpt,1,'C15');
    case 'radiobutton2'
        run('figure3x2Q2');
        TopologyOpt=2;
        %dlmwrite('InputParameters.txt',TopologyOpt,'delimiter','');
        xlswrite('Input.xlsx',TopologyOpt,1,'C15');
end

function uipanel1_CreateFcn(hObject, eventdata, handles)


function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
 global  a;
 a='radiobutton1';
 a=get(hObject,'tag');


function pushbutton2_Callback(hObject, eventdata, handles)
close(figure3x2M);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
global a;
a='radiobutton1';
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
