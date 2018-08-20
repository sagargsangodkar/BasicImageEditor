function varargout = gui(varargin)
%  H = GUI returns the handle to a new GUI or the handle to the existing singleton*.
% 
%  GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%  function named CALLBACK in GUI.M with the given input arguments.
% 
%  GUI('Property','Value',...) creates a new GUI or raises the
%  existing singleton*.  Starting from the left, property value pairs are
%  applied to the GUI before gui_OpeningFcn gets called.  An
%  unrecognized property name or invalid value makes property application
%  stop.  All inputs are passed to gui_OpeningFcn via varargin.

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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

% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;
set(handles.displaytext,'String','Image Editor')

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadbutton.
function loadbutton_Callback(hObject, eventdata, handles)
global im imbackup imtransformed mode figure;
figure = handles.figure1;
% 'im' stores the original loaded image. The variable is left untouched.
% Used to undo all image transformations applied.

% 'imtransformed' stores the current transformed image.
% 'imtransformed' is the only variable used to display in the image view
% area throughout the code

% 'imbackup' stores the backup of 'imtransformed' before applying another
% image transformation. Mainly used to undo the current image
% transformation.

% 'mode' can be either 'image' or 'hist'
% 'image' mode displays image in the display area whereas 'hist' mode
% displays histogram plot of the current image

global filepath name ext
mode = 'image';
[path,user_cancel] = imgetfile();
[filepath,name,ext] = fileparts(path); % Extracts file name and file extension from path.
if user_cancel
    msgbox(sprintf('User Pressed Cancel'),'Error','Error')
    %msgbox('String','Title','modal')
    return
end
im = imread(path);
imtransformed = im; % Special case: Here 'imtransformed' contains the original image. 
imbackup = imtransformed;
axes(handles.axes2);
imshow(uint8(imtransformed))
set(handles.displaytext,'String','Image Loaded Successfully')

% --- Executes on button press in undolatestbutton.
function undolatestbutton_Callback(hObject, eventdata, handles)
global imtransformed imbackup radiostate;
imtransformed = imbackup;
axes(handles.axes2);
imshow(imtransformed)
if get(handles.gammaradiobutton,'Value') || get(handles.logradiobutton,'Value')
    % De-selects radiobuttons if active and resets values of gamma or log
    % (whichever active) to default values of '1' and 'NA' respectively
    set(handles.gammaradiobutton,'Value',0)
    set(handles.logradiobutton,'Value',0);
    set(handles.gammaradiovalue,'String','1');
    set(handles.logradiovalue,'String','NA');
    radiostate = 'off';
end
set(handles.displaytext,'String','Latest Change Reverted')


% --- Executes on button press in undoallbutton.
function undoallbutton_Callback(hObject, eventdata, handles)
global imtransformed im;
% 'im' contains original loaded image
imtransformed = im;
axes(handles.axes2);
imshow(uint8(imtransformed))
set(handles.displaytext,'String','Original Image')
if get(handles.gammaradiobutton,'Value') || get(handles.logradiobutton,'Value')
    % De-selects radiobuttons if active and resets values of gamma or log
    % (whichever active) to default values of '1' and 'NA' respectively
    set(handles.gammaradiobutton,'Value',0)
    set(handles.logradiobutton,'Value',0);
    set(handles.gammaradiovalue,'String','1');
    set(handles.logradiovalue,'String','NA');
    radiostate = 'off';
end


% --- Executes on button press in saveimagebutton.
function saveimagebutton_Callback(hObject, eventdata, handles)
global imtransformed filepath name ext
% 'name' contains file name and 'ext' contains file extension
imwrite(uint8(imtransformed), strcat(filepath,name,'_modified',ext)); 
set(handles.displaytext,'String','Transformed Image Saved')


% --- Executes on button press in plothist.
function plothist_Callback(hObject, eventdata, handles)
% hObject    handle to plothist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imtransformed mode gammatransformed logtransformed;
mode = 'hist'; % Switches mode to 'image'
if size(imtransformed,3)>1
    msgbox(sprintf('Image should be grayscale'),'Error','Error')
    return
end
if get(handles.gammaradiobutton,'Value')
    % Displays histogram of gamma transformed image
    % if 'Gamma Correction' if radio button is active
    imhist(gammatransformed);
    % imhist plots the histogram
    set(handles.displaytext,'String','Histogram of gamma transformed image')
    return;
end
if get(handles.logradiobutton,'Value')
    % Displays histogram of log transformed image
    % if 'Log Transform' if radio button is active
    imhist(logtransformed);
    set(handles.displaytext,'String','Histogram of log transformed image')
    return;
end
imhist(imtransformed)
set(handles.displaytext,'String','Histogram Plot')


% --- Executes on button press in showimagebutton.
function showimagebutton_Callback(hObject, eventdata, handles)
% This feature is usd to switch from 'hist' mode to 'image' mode
global imtransformed mode gammatransformed logtransformed;
mode = 'image'; % Switches mode to 'image'
if get(handles.gammaradiobutton,'Value')
    % If 'Gamma Correction' radio button is active, it displays gamma
    % transformed image
    axes(handles.axes2);
    imshow(gammatransformed);
    set(handles.displaytext,'String','Gamma Transformed Image')
    return;
end
if get(handles.logradiobutton,'Value')
    % If 'Log Transform' radio button is active, it displays log
    % transformed image
    axes(handles.axes2);
    imshow(logtransformed);
    set(handles.displaytext,'String','Log Transformed Image')
    return;
end
axes(handles.axes2);
imshow(imtransformed)
set(handles.displaytext,'String','Image Display')


% --- Executes on button press in transformcurvebuton.
function transformcurvebuton_Callback(hObject, eventdata, handles)
% EXTRA FEATURE
global imtransformed
if size(imtransformed,3)>1
    msgbox(sprintf('Image should be grayscale'),'Error','Error')
    return
end
global T 
axes(handles.axes2);
plot(0:255,T,'LineWidth',2);
xlim([0 255]); ylim([0 255]);
xlabel('Input Pixel (r)'); ylabel('Transformed Pixel (s)');
set(gca,'YTick',0:15:255,'YTickLabel',cellstr(num2str([0:15:255]'))');
set(gca,'XTick',0:15:255,'XTickLabel',cellstr(num2str([0:15:255]'))');
set(handles.displaytext,'String','Transformation Curve');





% --- Executes on button press in histeqbutton.
function histeqbutton_Callback(hObject, eventdata, handles)
% Calls custom defined function 'hist_equalise' to equalise histogram
global imbackup imtransformed mode gammatransformed logtransformed T radiostate;
% T stores the mapping from input pixel to output pixel.
if size(imtransformed,3)>1
    msgbox(sprintf('Image should be grayscale'),'Error','Error')
    %msgbox('String','Title','modal')
    return
end
if strcmp(mode,'hist')
    if get(handles.gammaradiobutton,'Value')
        imbackup = gammatransformed;
        [imtransformed,T] = hist_equalise(gammatransformed);
        imhist(imtransformed)
        set(handles.gammaradiobutton,'Value',0); % Resets gamma transform radio button
        set(handles.gammaradiovalue,'String','1');
        set(handles.displaytext,'String','Histogram of equalised gamma transformed image')
        radiostate = 'off';
        return;
    end
    if get(handles.logradiobutton,'Value')
        imbackup = logtransformed;
        [imtransformed,T] = hist_equalise(logtransformed);
        imhist(imtransformed)
        set(handles.logradiobutton,'Value',0); % Resets log transform radio button
        set(handles.logradiovalue,'String','NA');
        set(handles.displaytext,'String','Histogram of equalised log transformed image')
        radiostate = 'off';
        return;
    end
    imbackup = imtransformed;
    [imtransformed,T] = hist_equalise(imtransformed);
    imhist(imtransformed)
    set(handles.displaytext,'String','Histogram of equalised image')
return;    
end
if strcmp(mode,'image')
    if get(handles.gammaradiobutton,'Value') % To equalise gamma transformed image
        imbackup = gammatransformed;
        imtransformed = hist_equalise(gammatransformed);
        axes(handles.axes2);
        imshow(imtransformed)
        set(handles.gammaradiobutton,'Value',0);
        set(handles.gammaradiovalue,'String','1');
        set(handles.displaytext,'String','Equalised gamma transformed image')
        radiostate = 'off';
        return;
    end
    if get(handles.logradiobutton,'Value')  % To equalise log transformed image
        imbackup = logtransformed;
        imtransformed = hist_equalise(logtransformed);
        axes(handles.axes2);
        imshow(imtransformed)
        set(handles.logradiobutton,'Value',0);
        set(handles.logradiovalue,'String','NA');
        set(handles.displaytext,'String','Equalised log transformed image')
        radiostate = 'off';
        return;
    end
    imbackup = imtransformed;
    imtransformed = hist_equalise(imtransformed);
    axes(handles.axes2);
    imshow(imtransformed)
    set(handles.displaytext,'String','Equalised image')
return;
end


% --- Executes on button press in rgb2gray.
function rgb2gray_Callback(hObject, eventdata, handles)
global imbackup imtransformed T;
if size(imtransformed,3)==1
    msgbox(sprintf('Image is already in grayscale'),'Error','Error')
    return
end
imbackup = imtransformed;
imtransformed = rgb2gray(imtransformed);
axes(handles.axes2);
imshow(imtransformed)
set(handles.displaytext,'String','Image converted to grayscale')
for r = 1:256
    T(r) = r-1; % For linear transformation curve
end


function gammacorrection(gamma,handles)
global imtransformed imbackup mode gammatransformed T radiostate;
imbackup = imtransformed; % Keeps backup of image before applying gamma correction
% 'gammatransformed' contains image obtained after gamma correction.
if(size(imtransformed,3)>1)
    msgbox(sprintf('Image should be grayscale'),'Error','Error');
    if get(handles.gammaradiobutton,'Value') || get(handles.logradiobutton,'Value')
        set(handles.gammaradiobutton,'Value',0)
        set(handles.logradiobutton,'Value',0);
        set(handles.gammaradiovalue,'String','1');
        set(handles.logradiovalue,'String','NA');
        radiostate = 'off';
    end
    return;
end
if strcmp(mode,'hist')
    imtransformed_normalised = double(imtransformed)/double(255);
    gammatransformed = imtransformed_normalised.^gamma;
    gammatransformed = uint8(gammatransformed*255);
    for r = 1:256 % For plotting transformation curve
        T(r) = ((r-1)/255)^gamma; 
        T(r) = T(r).*255;
    end
    axes(handles.axes2);
    imhist(gammatransformed);
    set(handles.displaytext,'String','Histogram of gamma transformed image')
else
    imtransformed_normalised = double(imtransformed)/double(255);
    gammatransformed = imtransformed_normalised.^gamma;
    gammatransformed = uint8(gammatransformed*255);
    for r = 1:256 % For plotting transformation curve
        T(r) = ((r-1)/255)^gamma; 
        T(r) = T(r).*255;
    end
    axes(handles.axes2);
    imshow(gammatransformed)
    set(handles.displaytext,'String','Gamma transformed image')
end

function logtransform(scale,handles)
global imtransformed imbackup mode logtransformed T radiostate;
imbackup = imtransformed;
if(size(imtransformed,3)>1)
    msgbox(sprintf('Image should be grayscale'),'Error','Error');
    if get(handles.gammaradiobutton,'Value') || get(handles.logradiobutton,'Value')
        set(handles.gammaradiobutton,'Value',0)
        set(handles.logradiobutton,'Value',0);
        set(handles.gammaradiovalue,'String','1');
        set(handles.logradiovalue,'String','NA');
        radiostate = 'off';
    end
    return;
end
if strcmp(mode,'hist')
    logtransformed = scale*log(1+double(imtransformed));
    logtransformed = uint8(logtransformed);
    for r = 1:256
        T(r) = scale*log(1+double(r-1)); % For plotting transformation curve
    end
    axes(handles.axes2);
    imhist(logtransformed);
    set(handles.displaytext,'String','Histogram of log transformed image')
else
    logtransformed = scale*log(1+double(imtransformed));
    logtransformed = uint8(logtransformed);
    for r = 1:256
        T(r) = scale*log(1+double(r-1)); % For plotting transformation curve
    end
    axes(handles.axes2);
    imshow(logtransformed);
    set(handles.displaytext,'String','Log transformed image')
end

% --- Executes on slider movement.
function slidervalue_Callback(hObject, eventdata, handles)
global slidervalue radiostate;
slidervalue = get(hObject,'Value');
% get(hObject,'Value') returns position of slider
% get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if(strcmp(radiostate,'gamma'))
    % If 'Gamma Correction' radio button is selected, slider value is updated in the
    % corresponding 'Gamma Correction' text box
    set(handles.gammaradiovalue,'String',num2str(slidervalue));
    gammacorrection(slidervalue,handles) % Applies gamma correction
end
if(strcmp(radiostate,'log'))
    % If 'Log Transform' radio button is selected, slider value is updated in the
    % corresponding 'Log Transform' text box
    set(handles.logradiovalue,'String',num2str(slidervalue));
    logtransform(slidervalue,handles) % Applies log transform
end


% --- Executes during object creation, after setting all properties.
function slidervalue_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in gammaradiobutton.
function gammaradiobutton_Callback(hObject, eventdata, handles)
% get(hObject,'Value') returns toggle state of gammaradiobutton
global radiostate imbackup mode
if get(hObject,'Value')
    radiostate = 'gamma';
    set(handles.logradiovalue,'String','NA');
    set(handles.logradiobutton,'Value',0);
    set(handles.slidervalue,'Value',1);
    set(handles.gammaradiovalue,'String','1');
    set(handles.slidervalue,'Min',0.1)
    set(handles.slidervalue,'Max',10)
    gammacorrection(1,handles);
else
    radiostate = 'gammaoff';
    set(handles.gammaradiovalue,'String','1');
    if strcmp(mode,'hist')
        imhist(imbackup)
        set(handles.displaytext,'String','Reversed Gamma Correction')
    else
        axes(handles.axes2);
        imshow(imbackup)
        set(handles.displaytext,'String','Reversed Gamma Correction')
    end
end


function gammaradiovalue_Callback(hObject, eventdata, handles)
global radiostate 
if(strcmp(radiostate,'gamma'))
    set(handles.slidervalue,'Value',str2double(get(hObject,'String')));
    set(handles.gammaradiovalue,'String',str2double(get(hObject,'String')));
    gammacorrection(str2double(get(hObject,'String')),handles);
end

% --- Executes during object creation, after setting all properties.
function gammaradiovalue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',1)


% --- Executes on button press in logradiobutton.
function logradiobutton_Callback(hObject, eventdata, handles)
global radiostate imbackup mode;
% get(hObject,'Value') returns toggle state of logradiobutton
if get(hObject,'Value')
    radiostate = 'log';
    set(handles.gammaradiobutton,'Value',0);
    set(handles.gammaradiovalue,'String','1');
    set(handles.slidervalue,'Value',50);
    set(handles.logradiovalue,'String','50');
    set(handles.slidervalue,'Min',1)
    set(handles.slidervalue,'Max',100)
    logtransform(50,handles);
else
    radiostate = 'logoff';
    set(handles.logradiovalue,'String','NA');
    if strcmp(mode,'hist')
        imhist(imbackup)
    else
        axes(handles.axes2);
        imshow(uint8(imbackup))
    end
end


function logradiovalue_Callback(hObject, eventdata, handles)
% get(hObject,'String') returns contents of logradiovalue as text
% str2double(get(hObject,'String')) returns contents of logradiovalue as a double
global radiostate
if(strcmp(radiostate,'log'))
    set(handles.slidervalue,'Value',str2double(get(hObject,'String')));
    set(handles.logradiovalue,'String',num2str(get(hObject,'String')));
    logtransform(str2double(get(hObject,'String')),handles)
end

% --- Executes during object creation, after setting all properties.
function logradiovalue_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','NA') % Default value


% --- Executes on button press in helpgamma.
function helpgamma_Callback(hObject, eventdata, handles)
CreateStruct.Interpreter = 'tex';
CreateStruct.WindowStyle = 'modal';
msgbox({'Enter gamma';'Gamma Correction: s = c x r^{ gamma}';'c = 1, r: input pixel, s: optput pixel'},'Help',CreateStruct)


% --- Executes on button press in helplog.
function helplog_Callback(hObject, eventdata, handles)
CreateStruct.Interpreter = 'tex';
CreateStruct.WindowStyle = 'modal';
msgbox({'Enter \primec\prime';'Log Transform: s = c*log(1+r)';'c: Scale, r: input pixel, s: optput pixel'},'Help',CreateStruct)



% --- Executes on selection change in blurtype.
function blurtype_Callback(hObject, eventdata, handles)
% contents = cellstr(get(hObject,'String')) returns blurtype contents as cell array
% contents{get(hObject,'Value')} returns selected item from blurtype
global imtransformed imbackup mode blurselected
imbackup = imtransformed;
contents = cellstr(get(hObject,'String'));
blurselected = contents{get(hObject,'Value')};
set(handles.blurcontrol,'Min',1)
set(handles.blurcontrol,'Max',10);
set(handles.blurcontrol,'Value',1) % 1 default value (smallest blur)
switch(blurselected)
    case 'Gaussian (Custom)'
        if size(imtransformed,3)>1
            msgbox(sprintf('Image should be grayscale'),'Error','Error')
            return
        end
        output = gaussianblur(imtransformed,1);
        if strcmp(mode,'hist')
            imhist(output);
        else
            axes(handles.axes2);
            imshow(output);
        end
        set(handles.displaytext,'String','Gaussian Blur (Custom). Sigma = 1 (Default)')
    case 'Gaussian (Inbuilt)'
        output = imgaussfilt(imtransformed,1);
        if(strcmp(mode,'hist'))
            imhist(output)
        else
            axes(handles.axes2)
            imshow(output)
        end
        set(handles.displaytext,'String','Gaussian Blur (In-built). Sigma = 1 (Default)')
    otherwise
        msgbox('Will be available in future versions','error','error')
end


% --- Executes during object creation, after setting all properties.
function blurtype_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in blurhelp.
function blurhelp_Callback(hObject, eventdata, handles)
CreateStruct.Interpreter = 'tex';
CreateStruct.WindowStyle = 'modal';
msgbox({'Applicalbe only for gaussian blur type';'Controls \sigma value (Min:1 Max:10)';
    'Other tools will have their effect on the un-blurred image only'},'Help',CreateStruct);


% --- Executes on slider movement.
function blurcontrol_Callback(hObject, eventdata, handles)
% get(hObject,'Value') returns position of slider
% get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global gaussiansigma blurselected imtransformed mode
gaussiansigma = get(hObject,'Value');
if strcmp(blurselected,'Gaussian (Custom)')
    set(handles.displaytext,'String',strcat('Gaussian Blur (Custom). Sigma = ',num2str(gaussiansigma)))
    output = gaussianblur(imtransformed,gaussiansigma); 
    if strcmp(mode,'hist')
        imhist(output);
    else
        axes(handles.axes2);
        imshow(output);
    end
end
if strcmp(blurselected,'Gaussian (Inbuilt)')
    set(handles.displaytext,'String',strcat('Gaussian Blur (In-built). Sigma = ',num2str(gaussiansigma)))
    output = imgaussfilt(imtransformed,gaussiansigma);
    if(strcmp(mode,'hist'))
        imhist(output)
    else
        axes(handles.axes2)
        imshow(output)
    end
end

% --- Executes during object creation, after setting all properties.
function blurcontrol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blurcontrol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in sharpnesstype.
function sharpnesstype_Callback(hObject, eventdata, handles)
% hObject    handle to sharpnesstype (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imtransformed imsharpened sharpnesscontrol sharpness_type;
contents = cellstr(get(hObject,'String')); % Returns sharpnesstype contents as cell array
sharpness_type = contents{get(hObject,'Value')}; % Returns selected item from sharpnesstype
set(handles.sharpnesscontrol,'Min',1)
set(handles.sharpnesscontrol,'Max',10);
set(handles.sharpnesscontrol,'Value',1)
sharpnesscontrol = 1;
if size(imtransformed,3)>1
    msgbox(sprintf('Image should be grayscale'),'Error','Error')
    return
end
switch sharpness_type
    case 'Laplacian (2nd Order)'
        set(handles.displaytext,'String','Laplacian Blur (2nd Order)')
        imsharpened = laplacian_sharpen(imtransformed);
    case 'Unsharp Masking'
        set(handles.displaytext,'String',strcat('Unsharp Masking. Sharpness = ',num2str(sharpnesscontrol/10*100),'%'))
        imsharpened = unsharp_masking_sharpen(imtransformed,sharpnesscontrol);
    case 'High Boost Filtering'
        set(handles.displaytext,'String',strcat('High Boost Filtering. Sharpness = ',num2str(sharpnesscontrol/10*100),'%'))
        imsharpened = highboost_sharpen(imtransformed,sharpnesscontrol);
    otherwise
        msgbox('Will be available in future versions','error','error')
end
axes(handles.axes2)
imshow(imsharpened)


% --- Executes during object creation, after setting all properties.
function sharpnesstype_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sharpnesstype
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sharpnesshelp.
function sharpnesshelp_Callback(hObject, eventdata, handles)


% --- Executes on slider movement.
function sharpnesscontrol_Callback(hObject, eventdata, handles)
global sharpnesscontrol sharpness_type imtransformed
sharpnesscontrol = get(hObject,'Value'); % Returns position of slider
switch sharpness_type
    case 'Unsharp Masking'
        set(handles.displaytext,'String',strcat('Unsharp Masking. Sharpness = ',num2str(sharpnesscontrol/10*100),'%'))
        imsharpened = unsharp_masking_sharpen(imtransformed,sharpnesscontrol);
    case 'High Boost Filtering'
        set(handles.displaytext,'String',strcat('High Boost Filtering. Sharpness = ',num2str(sharpnesscontrol/10*100),'%'))
        imsharpened = highboost_sharpen(imtransformed,sharpnesscontrol);
end
axes(handles.axes2)
imshow(imsharpened)

% --- Executes during object creation, after setting all properties.
function sharpnesscontrol_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function displaytext_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function displaytext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
