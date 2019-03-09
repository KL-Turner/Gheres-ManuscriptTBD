function varargout = GT_ScoringParameters(varargin)
%________________________________________________________________________________________________________________________
% Written by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%________________________________________________________________________________________________________________________
%
%   Purpose: Create a GUI to prompt the user for sleep scoring parameters. Created via Matlab's 'guide' GUI design.
%            Parameter default values are set during guide creation. 
%            Toggle button default values are set in the function GT_ScoringParameters_OpeningFcn.m (SEE BELOW)
%                   % Set default values for toggle buttons.
%                   set(handles.neurToggle, 'Value', 1);
%                   set(handles.ballToggle, 'Value', 1);
%                   set(handles.hrToggle, 'Value', 1);
%                   set(handles.saveStructToggle, 'Value', 1);
%                   set(handles.saveFigsToggle, 'Value', 1);
%
%            The GUI begins analysis when the GO. button is pressed through the function goButton_Callback.m (SEE BELOW)
%                   GT_StartAnalysis;   % When GO button is pressed, enter this function.
%________________________________________________________________________________________________________________________
%
%   Inputs: None. Calling this function opens the GUI, whose default parameters are set via the nested functions below.
%
%   Outputs: The GUI outputs a summary of the variable results that can be accessed with the Matlab function guidata.
%
%   Last Revised: March 8th, 2019
%________________________________________________________________________________________________________________________

% GT_SCORINGPARAMETERS MATLAB code for GT_ScoringParameters.fig
%      GT_SCORINGPARAMETERS, by itself, creates a new GT_SCORINGPARAMETERS or raises the existing
%      singleton*.
%
%      H = GT_SCORINGPARAMETERS returns the handle to a new GT_SCORINGPARAMETERS or the handle to
%      the existing singleton*.
%
%      GT_SCORINGPARAMETERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GT_SCORINGPARAMETERS.M with the given input arguments.
%
%      GT_SCORINGPARAMETERS('Property','Value',...) creates a new GT_SCORINGPARAMETERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GT_ScoringParameters_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GT_ScoringParameters_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GT_ScoringParameters

% Last Modified by GUIDE v2.5 04-Mar-2019 17:21:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GT_ScoringParameters_OpeningFcn, ...
                   'gui_OutputFcn',  @GT_ScoringParameters_OutputFcn, ...
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


% --- Executes just before GT_ScoringParameters is made visible.
function GT_ScoringParameters_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GT_ScoringParameters (see VARARGIN)

% Choose default command line output for GT_ScoringParameters
handles.output = hObject;

% Set default values for toggle buttons.
set(handles.neurToggle, 'Value', 1);
set(handles.ballToggle, 'Value', 1);
set(handles.hrToggle, 'Value', 1);
set(handles.saveStructToggle, 'Value', 1);
set(handles.saveFigsToggle, 'Value', 1);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GT_ScoringParameters wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = GT_ScoringParameters_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function awakeDuration_Callback(hObject, eventdata, handles)
% hObject    handle to awakeDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of awakeDuration as text
%        str2double(get(hObject,'String')) returns contents of awakeDuration as a double

% --- Executes during object creation, after setting all properties.
function awakeDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to awakeDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function minSleepTime_Callback(hObject, eventdata, handles)
% hObject    handle to minSleepTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minSleepTime as text
%        str2double(get(hObject,'String')) returns contents of minSleepTime as a double


% --- Executes during object creation, after setting all properties.
function minSleepTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minSleepTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function neurCrit_Callback(hObject, eventdata, handles)
% hObject    handle to neurCrit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of neurCrit as text
%        str2double(get(hObject,'String')) returns contents of neurCrit as a double

% --- Executes during object creation, after setting all properties.
function neurCrit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to neurCrit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ballCrit_Callback(hObject, eventdata, handles)
% hObject    handle to ballCrit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ballCrit as text
%        str2double(get(hObject,'String')) returns contents of ballCrit as a double

% --- Executes during object creation, after setting all properties.
function ballCrit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ballCrit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function hrCrit_Callback(hObject, eventdata, handles)
% hObject    handle to hrCrit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hrCrit as text
%        str2double(get(hObject,'String')) returns contents of hrCrit as a double

% --- Executes during object creation, after setting all properties.
function hrCrit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hrCrit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function scoringID_Callback(hObject, eventdata, handles)
% hObject    handle to scoringID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scoringID as text
%        str2double(get(hObject,'String')) returns contents of scoringID as a double

% --- Executes during object creation, after setting all properties.
function scoringID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scoringID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in neurToggle.
function neurToggle_Callback(hObject, eventdata, handles)
% hObject    handle to neurToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of neurToggle

% --- Executes on button press in ballToggle.
function ballToggle_Callback(hObject, eventdata, handles)
% hObject    handle to ballToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ballToggle

% --- Executes on button press in hrToggle.
function hrToggle_Callback(hObject, eventdata, handles)
% hObject    handle to hrToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hrToggle

% --- Executes on button press in saveStructToggle.
function saveStructToggle_Callback(hObject, eventdata, handles)
% hObject    handle to saveStructToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveStructToggle

% --- Executes on button press in saveFigsToggle.
function saveFigsToggle_Callback(hObject, eventdata, handles)
% hObject    handle to saveFigsToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of saveFigsToggle

% --- Executes on button press in goButton.
function goButton_Callback(hObject, eventdata, handles)
% hObject    handle to goButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

GT_StartAnalysis;   % When GO button is pressed, enter this function.

% --- Executes on button press in rerunProcData.
function rerunProcData_Callback(hObject, eventdata, handles)
% hObject    handle to rerunProcData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rerunProcData

% --- Executes on button press in rerunCatData.
function rerunCatData_Callback(hObject, eventdata, handles)
% hObject    handle to rerunCatData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rerunCatData

% --- Executes on button press in rerunSpecData.
function rerunSpecData_Callback(hObject, eventdata, handles)
% hObject    handle to rerunSpecData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rerunSpecData

% --- Executes on button press in rerunBase.
function rerunBase_Callback(hObject, eventdata, handles)
% hObject    handle to rerunBase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rerunBase
