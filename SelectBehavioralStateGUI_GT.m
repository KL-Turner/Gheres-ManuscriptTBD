function varargout = SelectBehavioralStateGUI_GT(varargin)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
%   Purpose: GUI for selection of Awake/NREM/REM beahvioral state during manual sleep scoring
%________________________________________________________________________________________________________________________
%
% SELECTBEHAVIORALSTATEGUI_GT MATLAB code for SelectBehavioralStateGUI_GT.fig
%      SELECTBEHAVIORALSTATEGUI_GT, by itself, creates a new SELECTBEHAVIORALSTATEGUI_GT or raises the existing
%      singleton*.
%
%      H = SELECTBEHAVIORALSTATEGUI_GT returns the handle to a new SELECTBEHAVIORALSTATEGUI_GT or the handle to
%      the existing singleton*.
%
%      SELECTBEHAVIORALSTATEGUI_GT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTBEHAVIORALSTATEGUI_GT.M with the given input arguments.
%
%      SELECTBEHAVIORALSTATEGUI_GT('Property','Value',...) creates a new SELECTBEHAVIORALSTATEGUI_GT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SelectBehavioralStateGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SelectBehavioralStateGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SelectBehavioralStateGUI_GT

% Last Modified by GUIDE v2.5 07-Aug-2019 11:48:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectBehavioralStateGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectBehavioralStateGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State,varargin{:});
else
    gui_mainfcn(gui_State,varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before SelectBehavioralStateGUI is made visible.
function SelectBehavioralStateGUI_OpeningFcn(hObject,eventdata,handles,varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SelectBehavioralStateGUI_GT (see VARARGIN)

% Choose default command line output for SelectBehavioralStateGUI_GT
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SelectBehavioralStateGUI_GT wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = SelectBehavioralStateGUI_OutputFcn(hObject,eventdata,handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject,eventdata,handles) %#ok<*DEFNU,*INUSD>
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ButtonSelect_IOS_Manuscript2020
% Hint: get(hObject,'Value') returns toggle state of togglebutton1
end


% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject,eventdata,handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ButtonSelect_GT
% Hint: get(hObject,'Value') returns toggle state of togglebutton2
end


% --- Executes on button press in togglebutton3.
function togglebutton3_Callback(hObject,eventdata,handles)
% hObject    handle to togglebutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ButtonSelect_GT
% Hint: get(hObject,'Value') returns toggle state of togglebutton3
end

