function varargout = gui_time_avg(varargin)
% GUI_TIME_AVG MATLAB code for gui_time_avg.fig
%      GUI_TIME_AVG, by itself, creates a new GUI_TIME_AVG or raises the existing
%      singleton*.
%
%      H = GUI_TIME_AVG returns the handle to a new GUI_TIME_AVG or the handle to
%      the existing singleton*.
%
%      GUI_TIME_AVG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_TIME_AVG.M with the given input arguments.
%
%      GUI_TIME_AVG('Property','Value',...) creates a new GUI_TIME_AVG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_time_avg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_time_avg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_time_avg

% Last Modified by GUIDE v2.5 10-Mar-2015 17:46:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_time_avg_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_time_avg_OutputFcn, ...
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


% --- Executes just before gui_time_avg is made visible.
function gui_time_avg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_time_avg (see VARARGIN)

% Choose default command line output for gui_time_avg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_time_avg wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_time_avg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% collect all the parameters and run the program
% variables
global time_avg_input_variable_fileName;
global time_avg_output_variable_fileName;

value = get(handles.time_avg_input_file_edit,'String');
if isempty(value)
    msgbox('Please enter data!');
    return;
end

value = get(handles.time_avg_output_file_edit,'String');
if isempty(value)
    msgbox('Please enter result file!');
    return;
end

% 1=year,2=month,3=day,4=hour,5=minute,6=second
metr_val = get(handles.time_avg_metrics_popupmenu,'Value');
if isempty(metr_val)
    msgbox('Please select metrics!');
    return;
end

intv = get(handles.time_avg_metrics_interval_edit,'String');
if isempty(intv)
    msgbox('Please enter a validate time interval!');
    return;
end
intv = str2num(intv);

% show input value for confirmation
disp(' ');
disp(' ');
disp('--------------------input parameters---------------------');
disp(['Input file name: ',time_avg_input_variable_fileName]);
disp(['Output_file_name: ',time_avg_output_variable_fileName]);

metr_str = [];
if metr_val == 1
    metr_str = 'year';
elseif metr_val == 2
    metr_str = 'month';
elseif metr_val == 3
    metr_str = 'day';
elseif metr_val == 4
    metr_str = 'hour';
elseif metr_val == 5
    metr_str = 'minute';
elseif metr_val == 6
    metr_str = 'second';
end
disp(['Time unit: ',metr_str]);

disp(['Time interval: ',num2str(intv)]);

% match data
%output = tavg(tav,unit,data);
msgbox('Done!');



function time_avg_input_file_edit_Callback(hObject, eventdata, handles)
% hObject    handle to time_avg_input_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_avg_input_file_edit as text
%        str2double(get(hObject,'String')) returns contents of time_avg_input_file_edit as a double


% --- Executes during object creation, after setting all properties.
function time_avg_input_file_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_avg_input_file_edit (see GCBO)
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
% open input file
global time_avg_input_variable_fileName;
[time_avg_input_variable_fileName,pathName,~] = uigetfile({'*.xlsx';'*.xls';'*.*'},'Open measured data');
if ~isempty(time_avg_input_variable_fileName)
    time_avg_input_variable_fileName = fullfile(pathName,time_avg_input_variable_fileName);
    disp(time_avg_input_variable_fileName);
    set(handles.time_avg_input_file_edit,'String',time_avg_input_variable_fileName);
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function time_avg_metrics_interval_edit_Callback(hObject, eventdata, handles)
% hObject    handle to time_avg_metrics_interval_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_avg_metrics_interval_edit as text
%        str2double(get(hObject,'String')) returns contents of time_avg_metrics_interval_edit as a double


% --- Executes during object creation, after setting all properties.
function time_avg_metrics_interval_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_avg_metrics_interval_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function time_avg_output_file_edit_Callback(hObject, eventdata, handles)
% hObject    handle to time_avg_output_file_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_avg_output_file_edit as text
%        str2double(get(hObject,'String')) returns contents of time_avg_output_file_edit as a double


% --- Executes during object creation, after setting all properties.
function time_avg_output_file_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_avg_output_file_edit (see GCBO)
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
global time_avg_output_variable_fileName;
[time_avg_output_variable_fileName,pathName,~] = uigetfile({'*.xlsx';'*.xls';'*.*'},'Open measured data');
if ~isempty(time_avg_output_variable_fileName)
    time_avg_output_variable_fileName = fullfile(pathName,time_avg_output_variable_fileName);
    disp(time_avg_output_variable_fileName);
    set(handles.time_avg_output_file_edit,'String',time_avg_output_variable_fileName);
end


% --- Executes on selection change in time_avg_metrics_popupmenu.
function time_avg_metrics_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to time_avg_metrics_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns time_avg_metrics_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from time_avg_metrics_popupmenu


% --- Executes during object creation, after setting all properties.
function time_avg_metrics_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_avg_metrics_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
