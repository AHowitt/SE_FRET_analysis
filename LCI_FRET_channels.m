function varargout = LCI_FRET_channels(varargin)
%LCI_FRET_CHANNELS MATLAB code file for LCI_FRET_channels.fig
%      LCI_FRET_CHANNELS, by itself, creates a new LCI_FRET_CHANNELS or raises the existing
%      singleton*.
%
%      H = LCI_FRET_CHANNELS returns the handle to a new LCI_FRET_CHANNELS or the handle to
%      the existing singleton*.
%
%      LCI_FRET_CHANNELS('Property','Value',...) creates a new LCI_FRET_CHANNELS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to LCI_FRET_channels_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      LCI_FRET_CHANNELS('CALLBACK') and LCI_FRET_CHANNELS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in LCI_FRET_CHANNELS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LCI_FRET_channels

% Last Modified by GUIDE v2.5 10-Apr-2018 19:06:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LCI_FRET_channels_OpeningFcn, ...
                   'gui_OutputFcn',  @LCI_FRET_channels_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before LCI_FRET_channels is made visible.
function LCI_FRET_channels_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for LCI_FRET_channels
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LCI_FRET_channels wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = LCI_FRET_channels_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function donstr_Callback(hObject, eventdata, handles)
% hObject    handle to donstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of donstr as text
%        str2double(get(hObject,'String')) returns contents of donstr as a double


% --- Executes during object creation, after setting all properties.
function donstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to donstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function accstr_Callback(hObject, eventdata, handles)
% hObject    handle to accstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of accstr as text
%        str2double(get(hObject,'String')) returns contents of accstr as a double


% --- Executes during object creation, after setting all properties.
function accstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to accstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nucstr_Callback(hObject, eventdata, handles)
% hObject    handle to nucstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nucstr as text
%        str2double(get(hObject,'String')) returns contents of nucstr as a double


% --- Executes during object creation, after setting all properties.
function nucstr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nucstr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nextbutton.
function nextbutton_Callback(hObject, eventdata, handles)
% hObject    handle to nextbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

assignin('base', 'ch_don', str2double(get(handles.donstr,'string')));
assignin('base', 'ch_acc', str2double(get(handles.accstr,'string')));
assignin('base', 'ch_nuc', str2double(get(handles.nucstr,'string')));

%IMFRET_process

%close(LCI_FRET_channels);
