function varargout = remappingGUI(varargin)

% NJ: remapping GUI is created to help visualize receptive field remapping
% simulation. The main script is remapping.m which handles the network
% simulation. remappingGUI provides an interactive interface for parameter
% exploration and network visualization.
%
% REMAPPINGGUI MATLAB code for remappingGUI.fig
%      REMAPPINGGUI, by itself, creates a new REMAPPINGGUI or raises the existing
%      singleton*.
%
%      H = REMAPPINGGUI returns the handle to a new REMAPPINGGUI or the handle to
%      the existing singleton*.
%
%      REMAPPINGGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REMAPPINGGUI.M with the given input arguments.
%
%      REMAPPINGGUI('Property','Value',...) creates a new REMAPPINGGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before remappingGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to remappingGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help remappingGUI

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @remappingGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @remappingGUI_OutputFcn, ...
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

% --- Executes just before remappingGUI is made visible.
function remappingGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to remappingGUI (see VARARGIN)

% Choose default command line output for remappingGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes remappingGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = remappingGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%% Main plot function - executes on button press in plot_button.
function plot_button_Callback(hObject, eventdata, handles)
% hObject    handle to plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Set initial conditions
IC= zeros(1,200);
FEF_A_in = str2double(get(handles.FEF_A_input,'String'));
FEF_C_in = str2double(get(handles.FEF_C_input,'String'));
FEF_E_in = str2double(get(handles.FEF_E_input,'String'));
SC_A_in = 0; %str2double(get(handles.SC_A_input,'String'));
SC_C_in = 0; %str2double(get(handles.SC_C_input,'String'));
SC_E_in = 0; %str2double(get(handles.SC_E_input,'String'));
FEF_input_node = str2double(get(handles.FEF_input_node,'String'));
SC_output_node = str2double(get(handles.SC_output_node,'String'));
In_kernel_width_input = str2double(get(handles.Inhibitory_kernel_width_input,'String'));
Ex_kernel_width_input = str2double(get(handles.Excitatory_kernel_width_input,'String'));
Inter_Areal_Kernel_in = str2double(get(handles.Inter_Areal_Kernel_input,'String'));
FEF_in_time_in = str2double(get(handles.FEF_in_time_input,'String'));

MatLab_ODE_Solver_On = get(handles.matlab_ode_solver_on,'Value');


% Let network reach equilibrium using either ode45 or manual Euler.
if MatLab_ODE_Solver_On == get(handles.matlab_ode_solver_on,'Max')
    
options = odeset('InitialStep',.01,'MaxStep',.01); 
disp('Using MatLab ODE solver 45...')
tic
[t,x] = ode45(@remappingML,[0 3],IC,options,FEF_C_in, FEF_E_in, SC_C_in, SC_E_in, FEF_A_in, SC_A_in, ...
    FEF_input_node, SC_output_node,In_kernel_width_input,Ex_kernel_width_input,Inter_Areal_Kernel_in);
toc 
disp('Computation completed')

meshc(handles.FEF_network_plot,x(:,1:100));
meshc(handles.SC_network_plot,x(:,101:200));

else
    disp('Manually integrating using Euler method...')
    tic
    [FEFs, SCs, MDs, exKernel, inKernel] = remapping(5000,FEF_C_in, FEF_E_in, FEF_A_in, SC_C_in, SC_E_in, SC_A_in, ...
        FEF_input_node, SC_output_node, Ex_kernel_width_input, In_kernel_width_input,Inter_Areal_Kernel_in, FEF_in_time_in);
    toc
    disp(' ')
    
    imagesc(FEFs,'Parent', handles.FEF_network_plot);
    imagesc(MDs, 'Parent', handles.MD_network_plot);
    meshc(handles.SC_network_plot,SCs);
    
    plot(handles.Kernel_plot, 1:100,exKernel,'g', 1:100, inKernel,'r');
    
end


%% Call back functions to collect user inputs

function FEF_C_input_Callback(hObject, eventdata, handles)
% hObject    handle to FEF_C_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FEF_C_input as text
%        str2double(get(hObject,'String')) returns contents of FEF_C_input as a double
FEF_C_in = str2double(get(hObject,'String'));
if isnan(FEF_C_in) || ~isreal(FEF_C_in)  
    % isdouble returns NaN for non-numbers and f1 cannot be complex
    % Disable the Plot button and change its string to say why
    set(handles.plot_button,'String','input must be numerical')
    set(handles.plot_button,'Enable','off')
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
else 
    % Enable the Plot button with its original name
    set(handles.plot_button,'String','Plot')
    set(handles.plot_button,'Enable','on')
end

function FEF_E_input_Callback(hObject, eventdata, handles)
% hObject    handle to FEF_E_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FEF_E_input as text
%        str2double(get(hObject,'String')) returns contents of FEF_E_input as a double
FEF_E_in = str2double(get(hObject,'String'));
if isnan(FEF_E_in) || ~isreal(FEF_E_in)  
    % isdouble returns NaN for non-numbers and f1 cannot be complex
    % Disable the Plot button and change its string to say why
    set(handles.plot_button,'String','input must be numerical')
    set(handles.plot_button,'Enable','off')
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
else 
    % Enable the Plot button with its original name
    set(handles.plot_button,'String','Plot')
    set(handles.plot_button,'Enable','on')
end


function SC_C_input_Callback(hObject, eventdata, handles)
% hObject    handle to SC_C_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SC_C_input as text
%        str2double(get(hObject,'String')) returns contents of SC_C_input as a double
SC_C_in = str2double(get(hObject,'String'));
if isnan(SC_C_in) || ~isreal(SC_C_in)  
    % isdouble returns NaN for non-numbers and f1 cannot be complex
    % Disable the Plot button and change its string to say why
    set(handles.plot_button,'String','input must be numerical')
    set(handles.plot_button,'Enable','off')
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
else 
    % Enable the Plot button with its original name
    set(handles.plot_button,'String','Plot')
    set(handles.plot_button,'Enable','on')
end

function SC_E_input_Callback(hObject, eventdata, handles)
% hObject    handle to SC_E_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SC_E_input as text
%        str2double(get(hObject,'String')) returns contents of SC_E_input as a double
SC_E_in = str2double(get(hObject,'String'));
if isnan(SC_E_in) || ~isreal(SC_E_in)  
    % isdouble returns NaN for non-numbers and f1 cannot be complex
    % Disable the Plot button and change its string to say why
    set(handles.plot_button,'String','input must be numerical')
    set(handles.plot_button,'Enable','off')
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
else 
    % Enable the Plot button with its original name
    set(handles.plot_button,'String','Plot')
    set(handles.plot_button,'Enable','on')
end



function FEF_A_input_Callback(hObject, eventdata, handles)
% hObject    handle to FEF_A_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FEF_A_input as text
%        str2double(get(hObject,'String')) returns contents of FEF_A_input as a double

FEF_A_in = str2double(get(hObject,'String'));
if isnan(FEF_A_in) || ~isreal(FEF_A_in)  
    % isdouble returns NaN for non-numbers and f1 cannot be complex
    % Disable the Plot button and change its string to say why
    set(handles.plot_button,'String','input must be numerical')
    set(handles.plot_button,'Enable','off')
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
else 
    % Enable the Plot button with its original name
    set(handles.plot_button,'String','Plot')
    set(handles.plot_button,'Enable','on')
end


function SC_A_input_Callback(hObject, eventdata, handles)
% hObject    handle to SC_A_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SC_A_input as text
%        str2double(get(hObject,'String')) returns contents of SC_A_input as a double
SC_A_in = str2double(get(hObject,'String'));
if isnan(SC_A_in) || ~isreal(SC_A_in)  
    % isdouble returns NaN for non-numbers and f1 cannot be complex
    % Disable the Plot button and change its string to say why
    set(handles.plot_button,'String','input must be numerical')
    set(handles.plot_button,'Enable','off')
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
else 
    % Enable the Plot button with its original name
    set(handles.plot_button,'String','Plot')
    set(handles.plot_button,'Enable','on')
end


% --- Executes on button press in matlab_ode_solver_on.
function matlab_ode_solver_on_Callback(hObject, eventdata, handles)
% hObject    handle to matlab_ode_solver_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of matlab_ode_solver_on
button_state = get(hObject,'Value');



function SC_output_node_Callback(hObject, eventdata, handles)
% hObject    handle to SC_output_node (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SC_output_node as text
%        str2double(get(hObject,'String')) returns contents of SC_output_node as a double
SC_output_node = str2double(get(hObject,'String'));
if isnan(SC_output_node) || ~isreal(SC_output_node)  
    % isdouble returns NaN for non-numbers and f1 cannot be complex
    % Disable the Plot button and change its string to say why
    set(handles.plot_button,'String','input must be numerical')
    set(handles.plot_button,'Enable','off')
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
else 
    % Enable the Plot button with its original name
    set(handles.plot_button,'String','Plot')
    set(handles.plot_button,'Enable','on')
end


function FEF_input_node_Callback(hObject, eventdata, handles)
% hObject    handle to FEF_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FEF_input as text
%        str2double(get(hObject,'String')) returns contents of FEF_input as a double
FEF_input_node = str2double(get(hObject,'String'));
if isnan(FEF_input_node) || ~isreal(FEF_input_node)  
    % isdouble returns NaN for non-numbers and f1 cannot be complex
    % Disable the Plot button and change its string to say why
    set(handles.plot_button,'String','input must be numerical')
    set(handles.plot_button,'Enable','off')
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
else 
    % Enable the Plot button with its original name
    set(handles.plot_button,'String','Plot')
    set(handles.plot_button,'Enable','on')
end



function Inhibitory_kernel_width_input_Callback(hObject, eventdata, handles)
% hObject    handle to Inhibitory_kernel_width_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Inhibitory_kernel_width_input as text
%        str2double(get(hObject,'String')) returns contents of Inhibitory_kernel_width_input as a double
In_kernel_width_input = str2double(get(hObject,'String'));
if isnan(In_kernel_width_input) || ~isreal(In_kernel_width_input)  
    % isdouble returns NaN for non-numbers and f1 cannot be complex
    % Disable the Plot button and change its string to say why
    set(handles.plot_button,'String','input must be numerical')
    set(handles.plot_button,'Enable','off')
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
else 
    % Enable the Plot button with its original name
    set(handles.plot_button,'String','Plot')
    set(handles.plot_button,'Enable','on')
end

function Excitatory_kernel_width_input_Callback(hObject, eventdata, handles)
% hObject    handle to Excitatory_kernel_width_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Excitatory_kernel_width_input as text
%        str2double(get(hObject,'String')) returns contents of Excitatory_kernel_width_input as a double
Ex_kernel_width_input = str2double(get(hObject,'String'));
if isnan(Ex_kernel_width_input) || ~isreal(Ex_kernel_width_input)  
    % isdouble returns NaN for non-numbers and f1 cannot be complex
    % Disable the Plot button and change its string to say why
    set(handles.plot_button,'String','input must be numerical')
    set(handles.plot_button,'Enable','off')
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
else 
    % Enable the Plot button with its original name
    set(handles.plot_button,'String','Plot')
    set(handles.plot_button,'Enable','on')
end



function Inter_Areal_Kernel_input_Callback(hObject, eventdata, handles)
% hObject    handle to Inter_Areal_Kernel_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Inter_Areal_Kernel_input as text
%        str2double(get(hObject,'String')) returns contents of Inter_Areal_Kernel_input as a double
Inter_Areal_Kernel_input = str2double(get(hObject,'String'));
if isnan(Inter_Areal_Kernel_input) || ~isreal(Inter_Areal_Kernel_input)  
    % isdouble returns NaN for non-numbers and f1 cannot be complex
    % Disable the Plot button and change its string to say why
    set(handles.plot_button,'String','input must be numerical')
    set(handles.plot_button,'Enable','off')
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
else 
    % Enable the Plot button with its original name
    set(handles.plot_button,'String','Plot')
    set(handles.plot_button,'Enable','on')
end



function FEF_in_time_input_Callback(hObject, eventdata, handles)
% hObject    handle to FEF_in_time_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FEF_in_time_input as text
%        str2double(get(hObject,'String')) returns contents of FEF_in_time_input as a double

FEF_in_time_input = str2double(get(hObject,'String'));
if isnan(FEF_in_time_input) || ~isreal(FEF_in_time_input)  
    % isdouble returns NaN for non-numbers and f1 cannot be complex
    % Disable the Plot button and change its string to say why
    set(handles.plot_button,'String','input must be numerical')
    set(handles.plot_button,'Enable','off')
    % Give the edit text box focus so user can correct the error
    uicontrol(hObject)
else 
    % Enable the Plot button with its original name
    set(handles.plot_button,'String','Plot')
    set(handles.plot_button,'Enable','on')
end
