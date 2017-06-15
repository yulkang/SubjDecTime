function varargout = Cursor_export(varargin)
% CURSOR_EXPORT M-file for Cursor_export.fig
%      CURSOR_EXPORT, by itself, creates a new CURSOR_EXPORT or raises the existing
%      singleton*.
%
%      H = CURSOR_EXPORT returns the handle to a new CURSOR_EXPORT or the handle to
%      the existing singleton*.
%
%      CURSOR_EXPORT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CURSOR_EXPORT.M with the given input arguments.
%
%      CURSOR_EXPORT('Property','Value',...) creates a new CURSOR_EXPORT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Cursor_export_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Cursor_export_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Cursor_export

% Last Modified by GUIDE v2.5 28-Jul-2006 14:29:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Cursor_export_OpeningFcn, ...
                   'gui_OutputFcn',  @Cursor_export_OutputFcn, ...
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


% --- Executes just before Cursor_export is made visible.
function Cursor_export_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Cursor_export (see VARARGIN)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
oldhandles = varargin{1};   %gets set of parameters from ourGUI.m

%Pass each parameter into current handles structure
handles.userdata = oldhandles.yvalues;
handles.t = oldhandles.xvalues;
handles.tstep = oldhandles.tstep;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

plot(handles.signal_axes, handles.t, handles.userdata);
xlim([handles.t(1) handles.t(end)]);
%added by Richard Peter 26/07/06
Ymax = max(handles.userdata);
Ymax = abs(Ymax)*0.1+Ymax
Ymin = min(handles.userdata);
Ymin = Ymin - abs(Ymin)*0.1
ylim([Ymin Ymax]);
%End of addition(26/07/06)

handles.path_entered = 0;   %For future error msg if no file path entered







% Choose default command line output for Cursor_export
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Cursor_export wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Cursor_export_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in activate_cursor.
function activate_cursor_Callback(hObject, eventdata, handles)
% hObject    handle to activate_cursor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'Value') == 1 %If they want to have a cursor
    jj = 1;
    while get(hObject, 'Value') == 1
        [x_coords(jj),y_coords(jj)]=ginput(1);
        if get(hObject, 'Value') == 1
            set(handles.time_coord, 'String' , num2str(x_coords(1),3));
            set(handles.voltage_coord, 'String' , num2str(y_coords(1),3));
        else
            break
        end
    end
end

 
 


% Update handles structure
guidata(hObject, handles);





% --- Executes on button press in export_to_excel.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to export_to_excel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.path_entered == 1
if get(hObject, 'Value') == 1 %If they want to have a cursor
    jj = 1;
    while get(hObject, 'Value') == 1
        [x_coords(jj),y_coords(jj)]=ginput(1)
        if get(hObject, 'Value') == 1
            set(handles.time_coord, 'String' , num2str(x_coords(1),3))
            set(handles.voltage_coord, 'String' , num2str(y_coords(1),3))
            z = [x_coords' y_coords']
            s = xlswrite(get(handles.file_path,'String'),z);
            jj = jj+1
        else
            break
        end
    end
end
else
     warndlg('You must enter a file path to continue',...
        'Incorrect Selection','modal')
     set(hObject, 'Value',1)
end


% Update handles structure
guidata(hObject, handles);



function time_coord_Callback(hObject, eventdata, handles)
% hObject    handle to time_coord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_coord as text
%        str2double(get(hObject,'String')) returns contents of time_coord as a double


% --- Executes during object creation, after setting all properties.
function time_coord_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_coord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function voltage_coord_Callback(hObject, eventdata, handles)
% hObject    handle to voltage_coord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of voltage_coord as text
%        str2double(get(hObject,'String')) returns contents of voltage_coord as a double


% --- Executes during object creation, after setting all properties.
function voltage_coord_CreateFcn(hObject, eventdata, handles)
% hObject    handle to voltage_coord (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function file_path_Callback(hObject, eventdata, handles)
% hObject    handle to file_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of file_path as text
%        str2double(get(hObject,'String')) returns contents of file_path as a double
handles.path_entered = 1


% Update handles structure
guidata(hObject, handles)





% --- Executes during object creation, after setting all properties.
function file_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

