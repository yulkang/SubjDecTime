%ProbDistPlot is a GUI program which plots statistical distributions commonly 
% used in reliability engineering. The program can plot the probability 
% distribution function, the cumulative distribution function and the 
% hazard rate of each distribution. The user can gain a better understanding 
% of the affect the distribution parameters have on the distribution but
% interactively changing distribution parameters with slides.
%
%ProbDistPlot is also able to create quick and easy figures by allowing
% multiple distributions to be plotted on the one figure with automatic
% legend annotations (updating parameter values), latex and tex labels, and
% export to the printer, clipboard, jpg, pdf, .mat and excel. Exporting to 
% excel actually transfers the data into an excel spreadsheet and creates an
% organic Excel chart which can be further manipulated in Excel. 
%
% Syntax:  ProbDistPlot
%
% License to freely distribute this program. License to modify this code is
% granted freely to all interested, as long as the original author is
% referenced and attributed as such. The original author maintains the 
% right to be solely associated with this work.
%
% Yair M. Altman, altmany(at)gmail.com is acknowledged as the author of the
% function findobj.m which allowed the properties of the slider objects to
% be modified. 
%
% Programmed and Copyright by Andrew O'Connor: AndrewNOConnor@gmail.com
% Revision: 1.0 
% Date: 12 Apr 2010

% Change log:
%    12 Apr 2010: First Version Posted on MathWorks file exchange


%IMPROVEMENTS NEEDED
% - change discrete plots to stem plots
% - change automatic decimal point on y-axis for excel export
% - fix error which occurs when re-opening .xls files after export
% - change excel function to handle step plots. Use stockcharts.
% - Make waiting dialog come up when doing drop down box the first time
% - Dialog boxes to open providing instructions on how to use program
% - Add commenting at the start of each function and through code
% - Make y-axis at x=0 (normal) or at box
% - Allow anotations and arrows etc.
% - Change color selector to the uisetcolor(fh, 'Pick a color')
% - Load and save a user preference file

function varargout = ProbDistPlot(varargin)
% PROBDISTPLOT
%
%    Provides the ability to create a graph with multiple probability plots.
%    It allows exporting to the printer, picture files, excel and the
%    clipboard.
% 
%    H = PROBDISTPLOT returns the handle to a new PROBDISTPLOT or the handle to
%    the existing singleton*.
%
%    PROBDISTPLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%    function named CALLBACK in PROBDISTPLOT.M with the given input arguments.
%
%    PROBDISTPLOT('Property','Value',...) creates a new PROBDISTPLOT or raises the
%    existing singleton*.  Starting from the left, property value pairs are
%    applied to the GUI before ProbDistPlot_OpeningFcn gets called.  An
%    unrecognized property name or invalid value makes property application
%    stop.  All inputs are passed to ProbDistPlot_OpeningFcn via varargin.
%
% Last Modified by Andrew O'Connor 11 Feb 2009

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProbDistPlot_OpeningFcn, ...
                   'gui_OutputFcn',  @ProbDistPlot_OutputFcn, ...
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

function ProbDistPlot_OpeningFcn(hObject, eventdata, handles, varargin)
    %Add functions path to MATLAB
    CurrentPath = cd;
    addpath([CurrentPath, '/New Functions/']);

    % Choose default command line output for ProbDistPlot
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % Set up invisible axes to plot the latex functions
    set(gcf, 'CurrentAxes', handles.axes_eqn);
    set(handles.axes_eqn,'xcolor',get(gcf,'color'));
    set(handles.axes_eqn,'ycolor',get(gcf,'color'));
    hEqn = text('String', '$$ $$','Position', [0.4, 0.65],'Interpreter', 'latex', 'Units', 'Normalized', 'FontSize', 14, 'HorizontalAlignment', 'center');
    handles.eqn = hEqn;
    guidata(hObject, handles)
    set(gcf,'CurrentAxes', handles.axis_main);
    
    % This sets up the initial plot - only do when we are invisible
    % so window can get raised using ProbDistPlot.
    IntroPic = imread('IntroPic.tif');
    image(IntroPic);
    axis off

    %Ensure all distribution panels are invisable
    set(findobj('-regexp', 'Tag', 'uipanel_dist'), 'visible', 'off')

    %Make Setting and Main Panel Functions Invisible
    set(findobj('-regexp', 'Tag', 'uipanel_set'), 'visible', 'off')
    set([get(handles.uipanel_set_axis, 'Children');...
        get(handles.uipanel_graph, 'Children');...
        handles.edit_xmin;...
        handles.edit_xmax;...
        handles.edit_ymin;...
        handles.edit_ymax;...
        handles.slider_yaxis;...
        handles.slider_xaxis], 'Enable', 'off')
    set(handles.uipanel_set_axis, 'visible', 'on')

    %Initialise global variables
    global plotdata selected_plot distdata lang

    selected_plot = 1;
    lang = 'Tex';
    
    %Create structured variable plotdata
    plotdata = struct(      'type',[],...
                            'title',' ',...
                            'visible', 1,... 
                            'parameters',[],...
                            'para_min', [],...
                            'para_max', [],...
                            'xMinMax', [],...
                            'function', [],...
                            'latex', ' ',....
                            'paneldata', [],...
                            'line_color', [], ...
                            'line_width', 0.5, ...
                            'line_style', '-', ...
                            'line_handle', 0);

    plotdata=repmat(plotdata, 1, 10);    
         
    %Set the colors and linestyle for each plot number and set togglebutton text color and line style                    
    plotdata(1).line_color = 'black'; %Black
    set(handles.togglebutton_plot1, 'ForegroundColor', 'black')
    plotdata(1).line_style = '-'; %Solid
    set(handles.togglebutton_plot1, 'String', 'Plot 1')
    
    plotdata(2).line_color = 'blue'; %Blue'
    set(handles.togglebutton_plot2, 'ForegroundColor', 'blue')
    plotdata(2).line_style = '-'; %Solid
    set(handles.togglebutton_plot2, 'String', 'Plot 2')
    
    plotdata(3).line_color = 'cyan'; %Cyan
    set(handles.togglebutton_plot3, 'ForegroundColor', 'cyan')
    plotdata(3).line_style = '-'; %Solid
    set(handles.togglebutton_plot3, 'String', 'Plot 3')
    
    plotdata(4).line_color = 'red'; %Red
    set(handles.togglebutton_plot4, 'ForegroundColor', 'red')
    plotdata(4).line_style = '-'; %Solid
    set(handles.togglebutton_plot4, 'String', 'Plot 4')
    
    plotdata(5).line_color = 'green'; %Green
    set(handles.togglebutton_plot5, 'ForegroundColor', 'green')
    plotdata(5).line_style = '-'; %Solid
    set(handles.togglebutton_plot5, 'String', 'Plot 5')
    
    plotdata(6).line_color = 'magenta'; %Magenta
    set(handles.togglebutton_plot6, 'ForegroundColor', 'magenta')
    plotdata(6).line_style = '-'; %Solid
    set(handles.togglebutton_plot6, 'String', 'Plot 6')
    
    plotdata(7).line_color = 'yellow'; %Yellow
    set(handles.togglebutton_plot7, 'ForegroundColor', 'yellow')
    plotdata(7).line_style = '-'; %Solid
    set(handles.togglebutton_plot7, 'String', 'Plot 7')
    
    plotdata(8).line_color = 'black'; %Black
    set(handles.togglebutton_plot8, 'ForegroundColor', 'black')
    plotdata(8).line_style = '--'; %Dashed
    set(handles.togglebutton_plot8, 'String', 'Plot 8 ---')
    
    plotdata(9).line_color = 'black'; %Black
    set(handles.togglebutton_plot9, 'ForegroundColor', 'black')
    plotdata(9).line_style = ':'; %Dotted
    set(handles.togglebutton_plot9, 'String', 'Plot 9 ...')    
    
    plotdata(10).line_color = 'black'; %Black
    set(handles.togglebutton_plot10, 'ForegroundColor', 'black')
    plotdata(10).line_style = '-.'; %Dashed Dotted
    set(handles.togglebutton_plot10, 'String', 'Plot 10 -.-')    
    
    %Set the background colors to the system color
    bColor = get(0, 'defaultUicontrolBackgroundColor');
    set(handles.axes_eqn, 'Color', bColor);
    set(findall(gcf, 'Type', 'uicontrol'), 'BackgroundColor', bColor);
    set(findall(gcf, 'Type', 'uipanel'), 'BackgroundColor', bColor);
    set(findall(gcf, 'Style', 'popupmenu'), 'BackgroundColor', [1,1,1]); %Change popup menus back to white
    set(findall(gcf, 'Style', 'edit'), 'BackgroundColor', [1,1,1]); %Change edit boxes back to white    
    

    i=3; %Index of distdata
    % Set Distribution Properties
    %COMMON LIFE DISTRIBUTIONS Heading
    n=i;
    distdata(n).paneltitle = '  COMMON LIFE DISTRIBUTIONS';
    
%     %Beta Distribution 4 Parameter - Need to create MATLAB files for Pdf,
%     %cdf and haz
%     i=i+1;
%     n=i;
%     distdata(n).title = {'Beta', ' PDF', ' \alpha=5 \beta=2 a=0 b=1'};        
%     distdata(n).parameters = [5, 2, 0, 1]; 
%     distdata(n).para_min = @(parameters)[0, 0, -inf, parameters(3)+10^(floor(log10(parameters(3)))-RelAccuracy)];
%     distdata(n).para_max = @(parameters)[inf, inf, parameters(4)-10^(floor(log10(parameters(4)))-RelAccuracy), inf];
%     distdata(n).para_slider_min = [0, 0, 0, 1];
%     distdata(n).para_slider_max = [5, 5, 0.99, 2];    
%     distdata(n).xMinMax = @(parameters)[parameters(3), parameters(4)];
%     distdata(n).PDFfunction = @(x, parameters)betapdf(x, parameters(1), parameters(2), '?', parameters(3), parameters(4));
%     distdata(n).CDFfunction = @(x, parameters)betacdf(x, parameters(1), parameters(2));
% %    distdata(n).HAZfunction = @(x, parameters)parameters(1);
%     distdata(n).PDFlatex = '$$ f(t) = \frac{\Gamma(\alpha+\beta)}{\Gamma(\alpha)\Gamma(\beta)}\, t^{\alpha-1}(1-t)^{\beta-1}\! $$';
%     distdata(n).CDFlatex = '$$ F(t)= 1- e^{-\left( \frac{t}{\alpha} \right)^\beta $$';
% %    distdata(n).HAZlatex = '$$ h(t)= \frac{\beta}{\alpha} .{\left( \frac{t}{\alpha} \right)^{\beta-1} $$';
%     distdata(n).paneltitle = 'Beta Distribution';
%     distdata(n).parameterName = {'Alpha', 'Beta', 'a - lower bound', 'b - upper bound'};
%     distdata(n).paraLegendName = {'\alpha', '\beta', 'a', 'b'};
    

    %Exponential 1 Parameter Distribution
    i=i+1;
    n=i;
    distdata(n).title = {'Exponential(1 Para)', ' PDF', ' \lambda=1'};        
    distdata(n).parameters = [1]; 
    distdata(n).para_min = @(parameters)[-inf];
    distdata(n).para_max = @(parameters)[inf];
    distdata(n).para_slider_min = [0.1];
    distdata(n).para_slider_max = [10];
    distdata(n).xMinMax = @(parameters)[0, 7/parameters(1)];
    distdata(n).PDFfunction = @(x, parameters)exppdf(x, 1./parameters(1));
    distdata(n).CDFfunction = @(x, parameters)expcdf(x, 1./parameters(1));
    distdata(n).HAZfunction = @(x, parameters)exphaz(x, parameters(1));
    distdata(n).PDFlatex = '$$ f(x)=\lambda e^{\lambda t} $$';
    distdata(n).CDFlatex = '$$ F(x)=1- e^{\lambda t} $$';
    distdata(n).HAZlatex = '$$ h(t)=\lambda $$';
    distdata(n).paneltitle = 'Exponential(1 para) Distribution';
    distdata(n).parameterName = {'Lambda'};
    distdata(n).paraLegendName = {'\lambda'};    
    
    %LogNormal Distribution
    i=i+1;
    n=i;
    distdata(n).title = {'LogNormal', ' PDF', ' \mu''=0 \sigma''=1'};        
    distdata(n).parameters = [0, 1]; 
    distdata(n).para_min = @(parameters)[-inf,0+realmin ];
    distdata(n).para_max = @(parameters)[inf,inf ];
    distdata(n).para_slider_min = [0, 0.1];
    distdata(n).para_slider_max = [5, 2];
    distdata(n).xMinMax = @(parameters)[0,exp(parameters(1))+(0.7*exp(3*parameters(2)))^(0.6/parameters(2))];
    distdata(n).PDFfunction = @(x, parameters)lognpdf(x, parameters(1), parameters(2));
    distdata(n).CDFfunction = @(x, parameters)logncdf(x, parameters(1), parameters(2)); 
    distdata(n).HAZfunction = @(x, parameters)lognhaz(x, parameters(1), parameters(2));
    distdata(n).PDFlatex = '$$ f(t)=\frac{1}{\sigma'' t \sqrt{2\pi}}  exp\left[- \frac{1}{2} \left( \frac{ln(t)-\mu''}{\sigma''}\right)^{2} \right] $$';
    distdata(n).CDFlatex = '$$ F(t)=\frac{1}{\sigma'' \sqrt{2\pi}} \int_{0}^{t} \frac{1}{\theta} exp\left[- \frac{1}{2} \left( \frac{ln(\theta)-\mu''}{\sigma''}\right)^{2} \right]  d\theta $$';
    distdata(n).HAZlatex = '$$ h(t) = \frac{\phi\left[\frac{ln(t)-\mu''}{\sigma''} \right]}{t \sigma'' \left( 1-\Phi\left[\frac{ln(t)-\mu''}{\sigma''} \right] \right)} $$';
    distdata(n).paneltitle = 'LogNormal Distribution';
    distdata(n).parameterName = {'Mu''', 'Sigma'''};
    distdata(n).paraLegendName = {'\mu''', '\sigma'''};
    
    
    %Weibull Distribution
    i=i+1;
    n=i;
    distdata(n).title = {'Weibull', ' PDF', ' \alpha=1 \beta=2'};        
    distdata(n).parameters = [1, 2]; 
    distdata(n).para_min = @(parameters)[0+realmin, 0+realmin];
    distdata(n).para_max = @(parameters)[inf, inf];
    distdata(n).para_slider_min = [0.1, 0.5];
    distdata(n).para_slider_max = [5, 12];
    distdata(n).xMinMax = @(parameters)[0, wblinv(0.9999, parameters(1), parameters(2))];
    distdata(n).PDFfunction = @(x, parameters)wblpdf(x, parameters(1), parameters(2));
    distdata(n).CDFfunction = @(x, parameters)wblcdf(x, parameters(1), parameters(2)); 
    distdata(n).HAZfunction = @(x, parameters)wblhaz(x, parameters(1), parameters(2));
    distdata(n).PDFlatex = '$$ f(t)= \frac{\beta t^{\beta-1}}{\alpha^{\beta}} e^{-\left( \frac{t}{\alpha} \right)^{\beta}} $$';
    distdata(n).CDFlatex = '$$ F(t)= 1- e^{-\left( \frac{t}{\alpha} \right)^{\beta}} $$';
    distdata(n).HAZlatex = '$$ h(t)= \frac{\beta}{\alpha} .{\left( \frac{t}{\alpha} \right)^{\beta-1}} $$';
    distdata(n).paneltitle = 'Weibull Distribution';
    distdata(n).parameterName = {'Alpha', 'Beta'};
    distdata(n).paraLegendName = {'\alpha', '\beta'};       

    

    %BATHTUB LIFE DISTRIBUTIONS Heading
    i=i+2;
    n=i;
    distdata(n).paneltitle = '  BATHTUB LIFE DISTRIBUTIONS'; 
    
    %2-Fold Mixture Weibull Distribution - Bathtub
    i=i+1;
    n=i;
    distdata(n).title = {'2-Fold Mixture Weibull - Bathtub', ' PDF', 'p=0.5 \alpha_1=2 \beta_1=0.5 \alpha_2=10 \beta_2=20'};        
    distdata(n).parameters = [0.5, 2, 0.5, 10, 20]; 
    distdata(n).para_min = @(parameters)[0, 0+realmin, 0+realmin, 0+realmin, 0+realmin];
    distdata(n).para_max = @(parameters)[1, inf, inf, inf, inf];
    distdata(n).para_slider_min = [0, 0.1, 0.1, 1, 0.1];
    distdata(n).para_slider_max = [1, 10, 5, 30, 30];
    distdata(n).xMinMax = @(parameters)[0, 1.2.*parameters(4)];
    distdata(n).PDFfunction = @(x, parameters)parameters(1).*wblpdf(x,parameters(2),parameters(3))+(1-parameters(1)).*wblpdf(x,parameters(4),parameters(5));
    distdata(n).CDFfunction = @(x, parameters)parameters(1).*wblcdf(x,parameters(2),parameters(3))+(1-parameters(1)).*wblcdf(x,parameters(4),parameters(5)); 
    distdata(n).HAZfunction = @(x, parameters)parameters(1).*wblpdf(x,parameters(2),parameters(3))+(1-parameters(1)).*wblpdf(x,parameters(4),parameters(5))./((1-parameters(1)).*wblcdf(x,parameters(2),parameters(3))+(1-parameters(1)).*wblcdf(x,parameters(4),parameters(5)));
    distdata(n).PDFlatex = '$$ f(t)= p \frac{\beta_1 t^{\beta_1 -1}}{\alpha_1^{\beta_1}} e^{-\left( \frac{t}{\alpha_1} \right)^{\beta_1}} + (1-p) \frac{\beta_2 t^{\beta_2 -1}}{\alpha_2^{\beta}} e^{-\left( \frac{t}{\alpha_2} \right)^{\beta}}  $$';
    distdata(n).CDFlatex = '$$ F(t)= p \left( 1- e^{-\left( \frac{t}{\alpha_1} \right)^{\beta_1}}\right) + (1-p) \left( 1- e^{-\left( \frac{t}{\alpha_2} \right)^{\beta_2}} \right) $$';
    distdata(n).HAZlatex = '$$ h(t)= w_1 \frac{\beta_1}{\alpha_1} .{\left( \frac{t}{\alpha_1} \right)^{\beta_1-1}} + w_2 \frac{\beta_2}{\alpha_2} .{\left( \frac{t}{\alpha_2} \right)^{\beta_2-1}} $$  where  $$ w_i = \frac{p_i R_i(t)} {\sum_{i=1}^{n} p_i R_i(t)}$$';
    distdata(n).paneltitle = '2-Fold Mixture Weibull Distribution - Bathtub';
    distdata(n).parameterName = {'p', 'Alpha 1', 'Beta 1', 'Alpha 2', 'Beta 2'};
    distdata(n).paraLegendName = {'p', '\alpha_1', '\beta_1', '\alpha_2', '\beta_2'};    
            
    
    %Exponentiated Weibull Distribution - Bathtub
    i=i+1;
    n=i;
    distdata(n).title = {'Exponentiated Weibull - Bathtub', ' PDF', '\alpha=5 \beta=2 v=0.4'};        
    distdata(n).parameters = [5, 2, 0.4]; 
    distdata(n).para_min = @(parameters)[0+realmin, 0+realmin, 0+realmin];
    distdata(n).para_max = @(parameters)[inf, inf, inf];
    distdata(n).para_slider_min = [0.1, 0.1, 0.1];
    distdata(n).para_slider_max = [10, 5, 5];
    distdata(n).xMinMax = @(parameters)[0, 2.*parameters(1)];
    distdata(n).PDFfunction = @(x, parameters)expwblpdf(x,parameters(1),parameters(2),parameters(3));
    distdata(n).CDFfunction = @(x, parameters)expwblcdf(x,parameters(1),parameters(2),parameters(3)); 
    distdata(n).HAZfunction = @(x, parameters)expwblhaz(x,parameters(1),parameters(2),parameters(3));
    distdata(n).PDFlatex = '$$ f(t)= \frac{\beta v t^{\beta-1}}{\alpha^{\beta}} \left[ 1 - exp \left\{-\left( \frac{t}{\alpha} \right)^{\beta} \right\} \right]^{v-1} exp \left\{-\left( \frac{t}{\alpha} \right)^{\beta} \right\}  $$';
    distdata(n).CDFlatex = '$$ F(t)= \left[ 1 - exp \left\{-\left( \frac{t}{\alpha} \right)^{\beta} \right\} \right]^{v} $$';
    distdata(n).HAZlatex = '$$ h(t)= \frac{\beta v t^{\beta - 1} \left[ 1 - exp \left\{-\left( \frac{t}{\alpha} \right)^{\beta} \right\} \right]^{v-1} exp \left\{-\left( \frac{t}{\alpha} \right)^{\beta} \right\}} {\alpha^{\beta - 1}  \left( 1-\left[ 1 - exp \left\{-\left( \frac{t}{\alpha} \right)^{\beta} \right\} \right]^{v} \right) } $$';
    distdata(n).paneltitle = 'Exponentiated Weibull Distribution - Bathtub';
    distdata(n).parameterName = {'Alpha', 'Beta', 'v'};
    distdata(n).paraLegendName = {'\alpha', '\beta', 'v'};    
    
    %Weibull Modified Distribution - Bathtub
    i=i+1;
    n=i;
    distdata(n).title = {'Modified Weibull - Bathtub', ' PDF', ' a=10 b=0.8 \lambda=0.1'};        
    distdata(n).parameters = [10, 0.8, 0.1]; 
    distdata(n).para_min = @(parameters)[0+realmin, 0, 0+realmin];
    distdata(n).para_max = @(parameters)[inf, inf, inf];
    distdata(n).para_slider_min = [0.01, 0, 0.01];
    distdata(n).para_slider_max = [20, 2, 1];
    distdata(n).xMinMax = @(parameters)[0, 2*((parameters(2))^0.5-parameters(2))/parameters(3)];
    distdata(n).PDFfunction = @(x, parameters)modwblpdf(x,parameters(1),parameters(2),parameters(3));
    distdata(n).CDFfunction = @(x, parameters)modwblcdf(x, parameters(1), parameters(2), parameters(3)); 
    distdata(n).HAZfunction = @(x, parameters)modwblhaz(x, parameters(1), parameters(2), parameters(3));
    distdata(n).PDFlatex = '$$ f(t)= a(b+\lambda t) t^{b-1} exp(\lambda t) exp[-a t^b exp(\lambda t)]$$';
    distdata(n).CDFlatex = '$$ F(t)= 1 - exp[-a t^b exp(\lambda t)] $$';
    distdata(n).HAZlatex = '$$ h(t)= a(b+ \lambda t) t^{b-1} e^{\lambda t} $$';
    distdata(n).paneltitle = 'Modified Weibull Distribution - Bathtub';
    distdata(n).parameterName = {'a', 'b', 'lambda'};
    distdata(n).paraLegendName = {'a', 'b', '\lambda'};    
        
    
    
    
     %CONTINUOUS DISTRIBUTIONS Heading
    i=i+2;
    n=i;
    distdata(n).paneltitle = '  CONTINUOUS DISTRIBUTIONS'; 


    %Beta Distribution 2 Parameter
    i=i+1;
    n=i;
    distdata(n).title = {'Beta', ' PDF', ' \alpha=5 \beta=2'};        
    distdata(n).parameters = [5, 2]; 
    distdata(n).para_min = @(parameters)[0, 0];
    distdata(n).para_max = @(parameters)[inf, inf];
    distdata(n).para_slider_min = [0, 0];
    distdata(n).para_slider_max = [5, 5];    
    distdata(n).xMinMax = @(parameters)[0,1];
    distdata(n).PDFfunction = @(x, parameters)betapdf(x, parameters(1), parameters(2));
    distdata(n).CDFfunction = @(x, parameters)betacdf(x, parameters(1), parameters(2));
    distdata(n).HAZfunction = @(x, parameters)betahaz(x, parameters(1), parameters(2));
    distdata(n).PDFlatex = '$$ f(t) = \frac{\Gamma(\alpha+\beta)}{\Gamma(\alpha)\Gamma(\beta)}\, t^{\alpha-1}(1-t)^{\beta-1}\! $$';
    distdata(n).CDFlatex = '$$ F(t)=\frac{\Gamma(\alpha+\beta)}{\Gamma(\alpha)\Gamma(\beta)} \int_{0}^{t}u^{\alpha-1} (1-u)^{\beta-1}du $$';
    distdata(n).HAZlatex = '$$ h(t)= \frac{f(t)}{R(t)} $$';
    distdata(n).paneltitle = 'Beta Distribution';
    distdata(n).parameterName = {'Alpha', 'Beta'};
    distdata(n).paraLegendName = {'\alpha', '\beta'};   
    
    
    %Birnbaum-Saunders Distribution
    i=i+1;
    n=i;
    distdata(n).title = {'Birnbaum-Saunders', ' PDF', ' \alpha=1 \beta=1'};        
    distdata(n).parameters = [1, 1]; 
    distdata(n).para_min = @(parameters)[0+realmin, 0+realmin];
    distdata(n).para_max = @(parameters)[inf, inf];
    distdata(n).para_slider_min = [0.1, 0.1];
    distdata(n).para_slider_max = [10, 10];
    distdata(n).xMinMax = @(parameters)[0, 3.*parameters(2).*(1+parameters(1).^2./2)];
    distdata(n).PDFfunction = @(x, parameters)bspdf(x,parameters(1), parameters(2));
    distdata(n).CDFfunction = @(x, parameters)bscdf(x, parameters(1), parameters(2)); 
    distdata(n).HAZfunction = @(x, parameters)bshaz(x, parameters(1), parameters(2));
    distdata(n).PDFlatex = '$$ f(t)=\frac{\sqrt{t / \beta} + \sqrt{\beta / t}}{2 \alpha t \sqrt{2\pi}}  exp\left[- \frac{1}{2} \left( \frac{\sqrt{t / \beta} - \sqrt{\beta / t}}{\alpha}\right)^{2} \right] $$';
    distdata(n).CDFlatex = '$$ F(t)= \Phi \left( \frac{\sqrt{t / \beta} - \sqrt{\beta / t}}{\alpha}\right) $$';
    distdata(n).HAZlatex = '$$ h(t) = \frac{\sqrt{t / \beta} + \sqrt{\beta / t}}{2 \alpha t} \left[ \frac{\phi(z)} {\Phi(-z)} \right]$ where $z=\frac{\sqrt{t / \beta} - \sqrt{\beta / t}}{\alpha} $$';   distdata(n).paneltitle = 'Gamma Distribution';
    distdata(n).paneltitle = 'Birnbaum-Saunders (Fatigue Life) Distribution';
    distdata(n).parameterName = {'Alpha', 'Beta'};
    distdata(n).paraLegendName = {'\alpha', '\beta'};    
    
       
    %Gamma Distribution
    i=i+1;
    n=i;
    distdata(n).title = {'Gamma', ' PDF', ' k=3 \lambda=1'};        
    distdata(n).parameters = [3, 1]; 
    distdata(n).para_min = @(parameters)[0+realmin, 0+realmin];
    distdata(n).para_max = @(parameters)[inf, inf];
    distdata(n).para_slider_min = [0.9, 0.5];
    distdata(n).para_slider_max = [10, 2];
    distdata(n).xMinMax = @(parameters)[0, gaminv(0.9999, parameters(1), 1./parameters(2))];
    distdata(n).PDFfunction = @(x, parameters)gampdf(x,parameters(1),1./parameters(2));
    distdata(n).CDFfunction = @(x, parameters)gamcdf(x, parameters(1), 1./parameters(2)); 
    distdata(n).HAZfunction = @(x, parameters)gamhaz(x, parameters(1), 1./parameters(2));
    distdata(n).PDFlatex = '$$ f(t)=\frac{\lambda^k t^(k-1)}{\Gamma(k)} e ^{-\lambda t} $$';
    distdata(n).CDFlatex = '$$ F(t)=\frac{\gamma(k,\lambda t)}{\Gamma(k)} $$';
    distdata(n).HAZlatex = '$$ h(t)=\frac{\lambda^k t^{k-1}}{\Gamma(k, \lambda t)} e^{-\lambda t} $$';
    distdata(n).paneltitle = 'Gamma Distribution';
    distdata(n).parameterName = {'k', 'Lambda'};
    distdata(n).paraLegendName = {'k', '\lambda'};   

    %Logistic Distribution
    i=i+1;
    n=i;
    distdata(n).title = {'Logistic', ' PDF', ' \mu=0 s=1'};        
    distdata(n).parameters = [0, 1]; 
    distdata(n).para_min = @(parameters)[-inf, 0+realmin];
    distdata(n).para_max = @(parameters)[inf, inf];
    distdata(n).para_slider_min = [-10, 0.1];
    distdata(n).para_slider_max = [10, 10];
    distdata(n).xMinMax = @(parameters)[parameters(1)-7*parameters(2),parameters(1)+7*parameters(2)];
    distdata(n).PDFfunction = @(x, parameters)logisticpdf(x,parameters(1), parameters(2));
    distdata(n).CDFfunction = @(x, parameters)logisticcdf(x, parameters(1), parameters(2)); 
    distdata(n).HAZfunction = @(x, parameters)logistichaz(x, parameters(1), parameters(2));
    distdata(n).PDFlatex = '$$ f(t)=\frac{e^z}{s (1 + e^z)^2} $ where $z=\frac{t - \mu}{s} $$';
    distdata(n).CDFlatex = '$$ F(t)=\frac{1}{1 + e^-z} $ where $z=\frac{t - \mu}{s} $$';
    distdata(n).HAZlatex = '$$ h(t)=\frac{1}{s (1 + e^z)} $ where $z=\frac{t - \mu}{s} $$';
    distdata(n).paneltitle = 'Logistic Distribution';
    distdata(n).parameterName = {'mu', 's'};
    distdata(n).paraLegendName = {'\mu', 's'};  
    
    %Normal Distribution
    i=i+1;
    n=i;
    distdata(n).title = {'Normal', ' PDF', ' \mu=0 \sigma=1'};        
    distdata(n).parameters = [0, 1]; 
    distdata(n).para_min = @(parameters)[-inf,0+realmin ];
    distdata(n).para_max = @(parameters)[inf,inf];
    distdata(n).para_slider_min = [-10, 0.1];
    distdata(n).para_slider_max = [10, 10];
    distdata(n).xMinMax = @(parameters)[parameters(1)-4*parameters(2),parameters(1)+4*parameters(2)];
    distdata(n).PDFfunction = @(x, parameters)normpdf(x, parameters(1), parameters(2));
    distdata(n).CDFfunction = @(x, parameters)normcdf(x, parameters(1), parameters(2)); 
    distdata(n).HAZfunction = @(x, parameters)normhaz(x, parameters(1), parameters(2));
    distdata(n).PDFlatex = '$$ f(t)=\frac{1}{\sigma \sqrt{2\pi}}  exp\left[- \frac{1}{2} \left( \frac{t-\mu}{\sigma}\right)^{2} \right] $$';
    distdata(n).CDFlatex = '$$ F(t)=\frac{1}{\sigma \sqrt{2\pi}} \int_{-\infty}^{t} exp\left[- \frac{1}{2} \left( \frac{\theta-\mu}{\sigma}\right)^{2} \right]  d\theta $$';
    distdata(n).HAZlatex = '$$ h(t) = \frac{\phi\left[\frac{t-\mu}{\sigma} \right]}{\sigma \left( 1-\Phi\left[\frac{t-\mu}{\sigma} \right] \right)} $$';
    distdata(n).paneltitle = 'Normal Distribution';
    distdata(n).parameterName = {'Mu', 'Sigma'};
    distdata(n).paraLegendName = {'\mu', '\sigma'};

    %Pareto Distribution
    i=i+1;
    n=i;
    distdata(n).title = {'Pareto', ' PDF', ' \theta=1 \sigma=1'};        
    distdata(n).parameters = [1, 1]; 
    distdata(n).para_min = @(parameters)[0+realmin,0+realmin ];
    distdata(n).para_max = @(parameters)[inf,inf];
    distdata(n).para_slider_min = [0.5, 0.1];
    distdata(n).para_slider_max = [30, 5];
    distdata(n).xMinMax = @(parameters)[parameters(1),3*parameters(2)*parameters(1)./parameters(2)];
    distdata(n).PDFfunction = @(x, parameters)gppdf(x, parameters(2), parameters(1), parameters(1));
    distdata(n).CDFfunction = @(x, parameters)gpcdf(x, parameters(2), parameters(1), parameters(1)); 
    distdata(n).HAZfunction = @(x, parameters)gppdf(x, parameters(2), parameters(1), parameters(1))./(1-gpcdf(x, parameters(2), parameters(1), parameters(1)));
    distdata(n).PDFlatex = '$$ f(t)=\frac{\alpha \theta^{\alpha}} {t^{\alpha + 1}} $$';
    distdata(n).CDFlatex = '$$ F(t)= \left( \frac{\theta}{t} \right)^\alpha $$';
    distdata(n).HAZlatex = '$$ h(t) = \frac{\alpha} {t} $$';
    distdata(n).paneltitle = 'Pareto Distribution';
    distdata(n).parameterName = {'Theta', 'Sigma'};
    distdata(n).paraLegendName = {'\theta', '\sigma'};
    

    %Triangle Distribution
    i=i+1;
    n=i;
    distdata(n).title = {'Triangle Continous', ' PDF', ' a=0 b=1 c=0.5'};        
    distdata(n).parameters = [0, 1, 0.5]; 
    distdata(n).para_min = @(parameters)[-inf, parameters(1)+realmin, parameters(1)];
    distdata(n).para_max = @(parameters)[parameters(2)-realmin, inf, parameters(2)];
    distdata(n).para_slider_min = [0, 1, 0];
    distdata(n).para_slider_max = [0.99, 2, 2];    
    distdata(n).xMinMax = @(parameters)[(parameters(1).*(19)-parameters(2))./20, (parameters(2).*(21)-parameters(1))./20];
    distdata(n).PDFfunction = @(x, parameters)tripdf(x, parameters(1), parameters(2), parameters(3));
    distdata(n).CDFfunction = @(x, parameters)tricdf(x, parameters(1), parameters(2), parameters(3));
    distdata(n).HAZfunction = @(x, parameters)tripdf(x, parameters(1), parameters(2), parameters(3))./(1-tricdf(x, parameters(1), parameters(2), parameters(3)));
    distdata(n).PDFlatex = '$$ f(t)= \left \{ \begin{array}{cc} \frac{2(t-a)} {(b-a)(c-a)} & \mbox{for $a \leq t \leq c$} \\ \frac{2(b-t)}{(b-a)(b-c)} & \mbox{$c \leq t \leq b$} \end{array} \right. \{ 0 \mbox{$ \ \  otherwise$} $$';
    distdata(n).CDFlatex = '$$ F(t) = \left \{ \begin {array}{cc} 0 & \mbox{for $t < 0$} \\ \frac{(t-a)^2} {(b-a)(c-a)} & \mbox{for $a \leq t \leq c$} .\end {array} \right.     \left \{ \begin {array}{cc} 1 - \frac{(b-t)^2}{(b-a)(b-c)} & \mbox{$c \leq t \leq b$} \\ 1 & \mbox{for $t>b$}.\end {array} \right.  $$';
    distdata(n).HAZlatex = '$$ h(t) = \frac{f(t)}{R(t)} $$';
    distdata(n).paneltitle = 'Triangle Continuous Distribution';
    distdata(n).parameterName = {'a - lower bound', 'b - upper bound', 'c - mode'};
    distdata(n).paraLegendName = {'a', 'b', 'c'};       
    
    %Uniform Distribution
    i=i+1;
    n=i;
    distdata(n).title = {'Uniform Continous', ' PDF', ' a=0 b=1'};        
    distdata(n).parameters = [0, 1]; 
    distdata(n).para_min = @(parameters)[0, parameters(1)+10^(floor(log10(parameters(1)))-realmin)];
    distdata(n).para_max = @(parameters)[parameters(2)-10^(floor(log10(parameters(2)))-realmin), inf];
    distdata(n).para_slider_min = [0, 1];
    distdata(n).para_slider_max = [0.99, 2];    
    distdata(n).xMinMax = @(parameters)[(parameters(1).*(19)-parameters(2))./20, (parameters(2).*(21)-parameters(1))./20];
    distdata(n).PDFfunction = @(x, parameters)unifpdf(x, parameters(1), parameters(2));
    distdata(n).CDFfunction = @(x, parameters)unifcdf(x, parameters(1), parameters(2));
    distdata(n).HAZfunction = @(x, parameters)unifhaz(x, parameters(1), parameters(2));
    distdata(n).PDFlatex = '$$ f(t) = \left \{ \begin {array}{cc} \frac{1}{b-a} & \mbox{if $a \leq t \leq b$} \\ 0 & \mbox{otherwise}.\end {array} \right. $$';
    distdata(n).CDFlatex = '$$ F(t) = \left \{ \begin {array}{ccc} 0 & \mbox{for $t < a$} \\ \frac{t-a}{b-a} & \mbox{$a \leq t \leq b$} \\ 0 & \mbox{for $t>b$}.\end {array} \right.  $$';
    distdata(n).HAZlatex = '$$ h(t) = \left \{ \begin {array}{cc} \frac{1}{b-t} & \mbox{if $a \leq t \leq b$} \\ 1 & \mbox{otherwise}.\end {array} \right. $$';
    distdata(n).paneltitle = 'Uniform Continuous Distribution';
    distdata(n).parameterName = {'a - lower bound', 'b - upper bound'};
    distdata(n).paraLegendName = {'a', 'b'};   
    
    
    
 
    
    %DISCRETE DISTRIBUTIONS Heading
    i=i+2;
    n=i;
    distdata(n).paneltitle = '  DISCRETE DISTRIBUTIONS';

    %Bernoulli Distribution
    i=i+1;
    n=i;
    distdata(n).title = {'Bernoulli', ' PDF', ' p=0.3'};        
    distdata(n).parameters = [0.3]; 
    distdata(n).para_min = @(parameters)[0];
    distdata(n).para_max = @(parameters)[1];
    distdata(n).para_slider_min = [0];
    distdata(n).para_slider_max = [1];
    distdata(n).xMinMax = @(parameters)[0, 2];
    distdata(n).PDFfunction = @(x, parameters)binopdf(floor(x),1,parameters(1));
    distdata(n).CDFfunction = @(x, parameters)binocdf(floor(x), 1,parameters(1)); 
    distdata(n).HAZfunction = @(x, parameters)binohaz(floor(x), 1,parameters(1));
    distdata(n).PDFlatex = '$$ f(k)= p^k(1-p)^{1-k} $$';
    distdata(n).CDFlatex = '$$ F(k)= (1-p)^{1-k}. $$';
    distdata(n).HAZlatex = '$$ h(t) = \left \{ \begin {array}{cc} 1-p & \mbox{for $ k = 0$} \\ 1 & \mbox{for $ k = 1$}.\end {array} \right. $$';
    distdata(n).paneltitle = 'Bernoulli Distribution';
    distdata(n).parameterName = {'p'};
    distdata(n).paraLegendName = {'p'};      
    
    
    %Binomial Distribution
    i=i+1;
    n=i;
    distdata(n).title = {'Binomial', ' PDF', ' n=5 p=0.3'};        
    distdata(n).parameters = [5, 0.3]; 
    distdata(n).para_min = @(parameters)[1, 0];
    distdata(n).para_max = @(parameters)[inf, 1];
    distdata(n).para_slider_min = [1, 0];
    distdata(n).para_slider_max = [10, 1];
    distdata(n).xMinMax = @(parameters)[0, floor(parameters(1))+1];
    distdata(n).PDFfunction = @(x, parameters)binopdf(floor(x),floor(parameters(1)),parameters(2));
    distdata(n).CDFfunction = @(x, parameters)binocdf(floor(x), floor(parameters(1)),parameters(2)); 
    distdata(n).HAZfunction = @(x, parameters)binohaz(floor(x), floor(parameters(1)),parameters(2));
    distdata(n).PDFlatex = '$$ f(k)= {n\choose k}p^k(1-p)^{n-k} $$';
    distdata(n).CDFlatex = '$$ F(k)= \sum_{i=0}^{k} {n\choose i}p^i(1-p)^{n-i}. $$';
    distdata(n).HAZlatex = '$$ h(k)= \left[ 1 + \frac{(1+\theta)^n - \sum_{j=0}^{k} {n\choose k} \theta^j } {{n\choose k}\theta^k} \right ]^{-1}$ where $\theta = \frac{p} {1-p}  $$';
    distdata(n).paneltitle = 'Binomial Distribution';
    distdata(n).parameterName = {'n', 'p'};
    distdata(n).paraLegendName = {'n', 'p'};          
    
    
    %Poisson Distribution
    i=i+1;
    n=i;
    distdata(n).title = {'Poisson', ' PDF', ' \mu=10'};        
    distdata(n).parameters = [10]; 
    distdata(n).para_min = @(parameters)[0+realmin];
    distdata(n).para_max = @(parameters)[inf];
    distdata(n).para_slider_min = [0.5];
    distdata(n).para_slider_max = [100];
    distdata(n).xMinMax = @(parameters)[0, poissinv(0.9999, parameters(1))];
    distdata(n).PDFfunction = @(x, parameters)poisspdf(floor(x),parameters(1));
    distdata(n).CDFfunction = @(x, parameters)poisscdf(floor(x), parameters(1)); 
    distdata(n).HAZfunction = @(x, parameters)poisshaz(floor(x), parameters(1));
    distdata(n).PDFlatex = '$$ f(t)=\frac{\mu^k}{k!} e ^{-\mu} $$';
    distdata(n).CDFlatex = '$$ F(t)=e ^{-\mu} \sum^{k}_{j=0} \frac{\mu^j}{j!} $$';
    distdata(n).HAZlatex = '$$ h(t)= \left[ 1 + \frac{t!} {\mu} \left(e^{\mu} - 1 - \sum_{j=1}^t \frac{\mu^j} {j!} \right ) \right ]^{-1}  $$';
    distdata(n).paneltitle = 'Possion Distribution';
    distdata(n).parameterName = {'Mu'};
    distdata(n).paraLegendName = {'\mu'};      
    
    
    %Set the string in the drop down box to match the distdata array
    DistNames = {distdata.paneltitle};
    %CurrentNames = get(handles.popupmenu_dist, 'String');
    DistNames{1} = 'Select Distribution';
    set(handles.popupmenu_dist, 'String', DistNames);
    
    % Set values for all edit boxes and sliders to string value
    %Main Graph Area
    set(handles.edit_ymin, 'Value', str2double(get(handles.edit_ymin, 'String')));
    set(handles.edit_ymax, 'Value', str2double(get(handles.edit_ymax, 'String')));
    set(handles.edit_xmin, 'Value', str2double(get(handles.edit_xmin, 'String')));
    set(handles.edit_xmax, 'Value', str2double(get(handles.edit_xmax, 'String')));
    
function varargout = ProbDistPlot_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;

function FigCloseFcn(hObject,eventdata,handles)
clear all
disp 'cleared'
delete(gcf)


%--------------------MENUS----------------------------------------
function About_Callback(hObject,eventdata,handles)
[sAbout, err] = sprintf('MATLAB. (c) 1984 - 2009 The MathWorks, Inc.  License to freely distribute this program. \n \nLicense to modify this code is granted freely to all interested, as long as the original author, Andrew O''Connor is referenced and attributed as such. The original author maintains the right to be solely associated with this work. \n \nYair M. Altman, altmany(at)gmail.com is acknowledged as the author of the function findobj.m which allowed the properties of the slider objects to be modified. \n \nProgrammed and Copyright by Andrew O''Connor: AndrewNOConnor@gmail.com Revision: 1.0 Date: 12 Apr 2010');
helpdlg(sAbout, 'About');

function FileMenu_Callback(hObject, eventdata, handles)

function OpenMenuItem_Callback(hObject, eventdata, handles)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

function PrintMenuItem_Callback(hObject, eventdata, handles)
printdlg(handles.MainPlotter)

function CloseMenuItem_Callback(hObject, eventdata, handles)
selection = questdlg(['Close ' get(handles.MainPlotter,'Name') '?'],...
                     ['Close ' get(handles.MainPlotter,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.MainPlotter)


%--------------------MAIN AXIS----------------------------------
function MainPlotter_WindowButtonMotionFcn(hObject, eventdata, handles)
%persistent in_axis hZoomIn hZoomOut hMove hDataCursor
% Doesn't work in comiled version and was unstable in MATLAB version. This
% was an attempt to only allow annotations in the axis area.
%
% if isempty(hZoomIn)
%     hZoomIn = findall(gcf, 'Tooltip', 'Zoom In');
%     hZoomOut = findall(gcf, 'Tooltip', 'Zoom Out');
%     hMove = findall(gcf, 'Tooltip', 'Pan');
%     hDataCursor = findall(gcf, 'Tooltip', 'Data Cursor');
%     
% %    in_axis = 0;
% end
% 
% %Get Mouse and Axes positions
% FigurePoint = get(hObject,'currentpoint');
% AxesPos = get(handles.axis_main, 'Position');
% 
% %Change Edit Mode when the position changes into the axes
% if ((FigurePoint(1)>=AxesPos(1)) & (FigurePoint(2)>=AxesPos(2)) & (FigurePoint(1)<(AxesPos(1)+AxesPos(3))) & (FigurePoint(2)<(AxesPos(2)+AxesPos(4))) & (get(hZoomIn, 'State')=='off') & (get(hZoomOut, 'State')=='off') & (get(hMove, 'State')=='off') & (get(hDataCursor, 'State')=='off') ) %& ~in_axis  
% %    in_axis = 1;
%     plotedit(handles.MainPlotter,'on')
%     set(handles.MainPlotter, 'Selected', 'off');
% else %~((FigurePoint(1)>=AxesPos(1)) & (FigurePoint(2)>=AxesPos(2)) & (FigurePoint(1)<(AxesPos(1)+AxesPos(3))) & (FigurePoint(2)<(AxesPos(2)+AxesPos(4))))% & in_axis
%     plotedit(handles.MainPlotter,'off')
% %    in_axis=0;
% %else
%     %Used to overcome problem with objects being set to inactive
%     set(findobj('Enable', 'inactive'), 'Enable', 'on')
% end

function edit_ymax_Callback(hObject, eventdata, handles)
    current_lim = ylim(handles.axis_main);
    value = str2num(get(hObject, 'string'));

    %Validate input to ensure it is a number
    if (~isfinite(value) || ~isreal(value)) || value <= current_lim(1)
        h = errordlg('ProbDistPlot: Incorrect Axis value.', 'ProbDistPlot');
        set(hObject, 'String', get(hObject, 'Value'));
        return
    end

    set(handles.checkbox_axis_yautoscale, 'Value', 0)
    set(handles.checkbox_fixYMax, 'Value', 1)
    ylim(handles.axis_main, [current_lim(1), value]);
    set(hObject, 'value', value);
    ProbDistPlot('slider_yaxis_Callback', handles.slider_xaxis, eventdata, handles, 'reset')

function edit_ymin_Callback(hObject, eventdata, handles)
    current_lim = ylim(handles.axis_main);
    value = str2double(get(hObject, 'string'));

    %Validate input to ensure it is a number
    if (~isfinite(value) || ~isreal(value)) || value >= current_lim(2)
        h = errordlg('ProbDistPlot: Incorrect Axis value.', 'ProbDistPlot');
        set(hObject, 'String', get(hObject, 'Value'));
        return
    end
    
    %Y_min can't be below zero
    if value<0
        h = errordlg('ProbDistPlot: YMin cannot be belore zero for density functions.', 'ProbDistPlot');
        set(hObject, 'String', get(hObject, 'Value'));
        return
    end 
    
    set(handles.checkbox_axis_yautoscale, 'Value', 0)
    set(handles.checkbox_fixYMin, 'Value', 1)
    ylim(handles.axis_main, [value, current_lim(2)]);
    set(hObject, 'value', value);
    ProbDistPlot('slider_yaxis_Callback', handles.slider_xaxis, eventdata, handles, 'reset')

function slider_yaxis_Callback(hObject, eventdata, handles, varargin)
persistent y_initial_limits value

    %If there is an extra input then reset x_initial_limits
    if ~isempty(varargin)
        clear y_initial_limits
        set(handles.slider_yaxis, 'Value', 0)
        value = 0;
        return;
    end
    
    %If there is recursion then cancel
    if value == get(handles.slider_yaxis, 'value'), return; end
    
    if isempty(y_initial_limits)
        y_limits = get(handles.axis_main, 'YLim');
        y_initial_limits = y_limits;
    end

    y_mean = (y_initial_limits(2)+y_initial_limits(1))/2;
    
    value = get(handles.slider_yaxis, 'value');
    
    new_delta = ((y_initial_limits(2)-y_initial_limits(1))/2)*(10^value);
    
    %Calc Limits. If only one check box is selected that limit is held constant.
    %If both boxes are blank or checked than the slider adjusts both sides.
    %Calc y_lower
    if get(handles.checkbox_fixYMin, 'Value') & ~(get(handles.checkbox_fixYMax, 'Value'))
        y_lower = get(handles.edit_ymin, 'Value');
    else
        y_lower = y_mean-new_delta;
        if y_lower<0, y_lower = 0;, end
    end
    
    %Calc y_upper
     if get(handles.checkbox_fixYMax, 'Value') & ~(get(handles.checkbox_fixYMin, 'Value'))
        y_upper = get(handles.edit_ymax, 'Value');
    else
        y_upper = y_mean+new_delta;
    end   
    
    ylim([y_lower, y_upper]);
    
    set(handles.edit_ymin, 'Value', y_lower, 'String', y_lower);
    set(handles.edit_ymax, 'Value', y_upper, 'String', y_upper);
    
    %Set all checkboxes to show manual
    set(handles.checkbox_axis_yautoscale, 'Value', 0)
    
    %If neither box is checked then both will be checked.
    if ~(get(handles.checkbox_fixYMin, 'Value')) & ~(get(handles.checkbox_fixYMax, 'Value'))
        set(handles.checkbox_fixYMax, 'Value', 1)
        set(handles.checkbox_fixYMin, 'Value', 1)
    end
    


function edit_xmax_Callback(hObject, eventdata, handles)
    current_lim = xlim(handles.axis_main);
    value = str2double(get(hObject, 'string'));

    %Validate input to ensure it is a number
    if (~isfinite(value) || ~isreal(value)) || value <= current_lim(1)
        h = errordlg('ProbDistPlot: Incorrect Axis value.', 'ProbDistPlot');
        set(hObject, 'String', get(hObject, 'Value'));
        return
    end

    xlim(handles.axis_main, [current_lim(1), value]);
    set(handles.checkbox_axis_xautoscale, 'Value', 0)
    set(handles.checkbox_fixXMax, 'Value', 1)
    set(hObject, 'value', value);
    
    ProbDistPlot('slider_xaxis_Callback', handles.slider_xaxis, eventdata, handles, 'reset')
    
    update_plot(handles, 0, 1)

function edit_xmin_Callback(hObject, eventdata, handles)
    current_lim = xlim(handles.axis_main);
    value = str2double(get(hObject, 'string'));

    %Validate input to ensure it is a number and below xmax
    if ~isfinite(value) || ~isreal(value) || value >= current_lim(2)
        h = errordlg('ProbDistPlot: Incorrect Axis value.', 'ProbDistPlot');
        set(hObject, 'String', get(hObject, 'Value'));
        return
    end
    
    
    xlim(handles.axis_main, [value, current_lim(2)]);
    set(handles.checkbox_axis_xautoscale, 'Value', 0)
    set(handles.checkbox_fixXMin, 'Value', 1)
    set(hObject, 'value', value);
    
    ProbDistPlot('slider_xaxis_Callback', handles.slider_xaxis, eventdata, handles, 'reset')
    
    update_plot(handles, 0, 1)

function slider_xaxis_Callback(hObject, eventdata, handles, varargin)
persistent x_initial_limits value

    %If there is an extra input then reset x_initial_limits
    if ~isempty(varargin)
        clear x_initial_limits
        set(handles.slider_xaxis, 'Value', 0)
        value = 0;
        return;
    end
    
    
    %If there is recursion then cancel
    if value == get(handles.slider_xaxis, 'value'), return; end
 
    if isempty(x_initial_limits)
        x_limits = get(handles.axis_main, 'XLim');
        x_initial_limits = x_limits;
    end

    x_mean = (x_initial_limits(2)+x_initial_limits(1))/2;
    
    value = get(handles.slider_xaxis, 'value');
    
    new_delta = ((x_initial_limits(2)-x_initial_limits(1))/2)*(20^value);
    
    %Calc Limits. If only one check box is selected that limit is held constant.
    %If both boxes are blank or checked than the slider adjusts both sides.
    %Calc x_lower
    if get(handles.checkbox_fixXMin, 'Value') & ~(get(handles.checkbox_fixXMax, 'Value'))
        x_lower = get(handles.edit_xmin, 'Value');
    else
        x_lower = x_mean-new_delta;
    end
    
    %Calc x_upper
    if get(handles.checkbox_fixXMax, 'Value') & ~(get(handles.checkbox_fixXMin, 'Value'))
        x_upper = get(handles.edit_xmax, 'Value');
    else
        x_upper = x_mean+new_delta;
    end   
    
    xlim([x_lower, x_upper]);
    
    set(handles.edit_xmin, 'Value', x_lower, 'String', x_lower);
    set(handles.edit_xmax, 'Value', x_upper, 'String', x_upper);
    
    %Set all checkboxes to show manual
    set(handles.checkbox_axis_xautoscale, 'Value', 0)
    
    %If neither box is checked then both will be checked.
    if ~(get(handles.checkbox_fixXMin, 'Value')) & ~(get(handles.checkbox_fixXMax, 'Value'))
        set(handles.checkbox_fixXMax, 'Value', 1)
        set(handles.checkbox_fixXMin, 'Value', 1)
    end    
    
    update_plot(handles, 0, 1);
    
function checkbox_fix_Callback(hObject, eventdata, handles, varargin)


if ~get(handles.checkbox_fixXMin, 'Value') & ~get(handles.checkbox_fixXMax, 'Value')
    set(handles.checkbox_axis_xautoscale, 'Value', 1)
    ProbDistPlot('slider_xaxis_Callback', handles.slider_xaxis, eventdata, handles, 'reset')
else
    set(handles.checkbox_axis_xautoscale, 'Value', 0)
end

if ~get(handles.checkbox_fixYMin, 'Value') & ~get(handles.checkbox_fixYMax, 'Value')
    set(handles.checkbox_axis_yautoscale, 'Value', 1)
    ProbDistPlot('slider_yaxis_Callback', handles.slider_yaxis, eventdata, handles, 'reset')
else
    set(handles.checkbox_axis_yautoscale, 'Value', 0)
end


update_plot(handles, 0, 1)


%---------------DISTRIBUTION BUTTONS & POPUPMENU---------------------------
function togglebutton_plot_Callback(hObject, eventdata, handles, button_number)
    global plotdata selected_plot distdata
    
    Prop_String = {'ListboxTop', 'Max', 'Min', 'SliderStep', 'String', 'Tag', 'UserData', 'Value', 'Visible'};
        
    %Make panel invisible
    set(handles.uipanel_dist, 'visible', 'off')

    %Save information from panel into plotdata
    PanelHandles = get(handles.uipanel_dist, 'Children');
    Current_Dist_Type = plotdata(selected_plot).type;
    if ~isempty(Current_Dist_Type)  %If there is a panel allocated
        %Save data into plotdata
        plotdata(selected_plot).paneldata = get(PanelHandles, Prop_String);
        set(handles.popupmenu_dist, 'Value', 1);
    end    

    %Set variables for new panel
    New_Dist_Type = plotdata(button_number).type;
    if ~isempty(New_Dist_Type)  %If there is a panel allocated
        % Load panel parameters
        set(PanelHandles, Prop_String, plotdata(button_number).paneldata);
        set(handles.popupmenu_dist, 'Value', New_Dist_Type);
        
        %Load variables that could have changed while not the current plot
        PlotType = plotdata(button_number).type;                                
        set(handles.eqn, 'String', plotdata(button_number).latex);                  %Update Equation
        set(handles.uipanel_dist, 'Title', distdata(PlotType).paneltitle)           %Update panel title
        sLine_width = get(handles.popupmenu_dist_linewidth, 'String');              %Update linewidth
        PopupValue = find(strcmp(num2str(plotdata(button_number).line_width), sLine_width)); 
        set(handles.popupmenu_dist_linewidth, 'Value', PopupValue);                 
        set(handles.edit_dist_plot_title, 'String', plotdata(button_number).title); %Updae plot title

        %Make new panel visible
        set(handles.uipanel_dist, 'Visible', 'on')
    else
        set(handles.popupmenu_dist_linewidth, 'Value', 1);
        set(handles.eqn, 'String', '$$ $$');
    end


    %Update selected_plot variable
    selected_plot = button_number;

function popupmenu_dist_Callback(hObject, eventdata, handles)
    global plotdata selected_plot distdata
    persistent first_run

    if isempty(first_run)
    
        %Make settings panel and main area functions active again
        set([get(handles.uipanel_set_axis, 'Children');...
            get(handles.uipanel_graph, 'Children');...
            handles.edit_xmin;...
            handles.edit_xmax;...
            handles.edit_ymin;...
            handles.edit_ymax;...
            handles.checkbox_fixYMax;...
            handles.checkbox_fixYMin;...
            handles.checkbox_fixXMax;...
            handles.checkbox_fixXMin;...
            handles.slider_yaxis;...
            handles.slider_xaxis], 'Enable', 'on')
        
        
        %     h = waitbar(0, 'Please wait while initialising distibutions');
        %     n = 7;   


        %Make sliders instantly update when slide (this needs to be called after the
        %figure is finished being created

        hjslider_dist_para1 = findjobj(handles.MainPlotter, 'property',{'toolTipText','slider_dist_para1'}, 'nomenu', 'persist');  
        set(hjslider_dist_para1, 'AdjustmentValueChangedCallback', {@(hObject, eventdata)ProbDistPlot('slider_dist_para_Callback',handles.slider_dist_para1, eventdata, handles, 1, 1)});       
    %     waitbar(1/n);

        hjslider_dist_para2 = findjobj(handles.MainPlotter, 'property',{'toolTipText','slider_dist_para2'},'nomenu', 'persist');  
        set(hjslider_dist_para2, 'AdjustmentValueChangedCallback', {@(hObject, eventdata)ProbDistPlot('slider_dist_para_Callback',handles.slider_dist_para2, eventdata, handles, 2, 1)});       
    %     waitbar(2/n);

        hjslider_dist_para3 = findjobj(handles.MainPlotter, 'property',{'toolTipText','slider_dist_para3'},'nomenu', 'persist');  
        set(hjslider_dist_para3, 'AdjustmentValueChangedCallback', {@(hObject, eventdata)ProbDistPlot('slider_dist_para_Callback',handles.slider_dist_para3, eventdata, handles, 3, 1)});       
    %     waitbar(3/n);

        hjslider_dist_para4 = findjobj(handles.MainPlotter, 'property',{'toolTipText','slider_dist_para4'},'nomenu', 'persist');  
        set(hjslider_dist_para4, 'AdjustmentValueChangedCallback', {@(hObject, eventdata)ProbDistPlot('slider_dist_para_Callback',handles.slider_dist_para4, eventdata, handles, 4, 1)});       
    %     waitbar(4/n);
    
        hjslider_dist_para5 = findjobj(handles.MainPlotter, 'property',{'toolTipText','slider_dist_para5'},'nomenu', 'persist');  
        set(hjslider_dist_para5, 'AdjustmentValueChangedCallback', {@(hObject, eventdata)ProbDistPlot('slider_dist_para_Callback',handles.slider_dist_para5, eventdata, handles, 5, 1)});       
    %     waitbar(4/n);

        hjslider_xaxis = findjobj(handles.MainPlotter, 'property',{'toolTipText','slider_xaxis'},'nomenu', 'persist');  
        set(hjslider_xaxis, 'AdjustmentValueChangedCallback', {@(hObject, eventdata)ProbDistPlot('slider_xaxis_Callback',handles.slider_xaxis, eventdata, handles)});       
    %     waitbar(5/n);

        hjslider_yaxis = findjobj(handles.MainPlotter, 'property',{'toolTipText','slider_yaxis'},'nomenu', 'persist');  
        set(hjslider_yaxis, 'AdjustmentValueChangedCallback', {@(hObject, eventdata)ProbDistPlot('slider_yaxis_Callback',handles.slider_yaxis, eventdata, handles)}); 
    %     waitbar(6/n);

       %Clear the picture off the axis
        cla(handles.axis_main);
        reset(handles.axis_main);
        first_run = 0;

        %Set the labels to the default
        xlabel(get(handles.edit_labels_xaxis, 'String'));
        ylabel(get(handles.edit_labels_yaxis, 'String'));
        title(get(handles.edit_labels_title, 'String'));


    %     waitbar(1)
    %     close(h)
    end

    %If another plot is already loaded make panel invisible
    set(handles.uipanel_dist, 'visible', 'off')
    
    %Load Distribution Data into Panel
    PlotType = get(hObject, 'Value');
    
    %If the user selected a heading entry of the popup menu, then exit
    if isempty(distdata(PlotType).title), return, end

    %Make Plot Title
    cInd = get([handles.checkbox_options_legendname, handles.checkbox_options_legendpdf, handles.checkbox_options_legendpara], 'Value');
    aInd = find([cInd{1:3}]);
    sTitle = [distdata(PlotType).title{aInd}];

    %Load default variables into plotdata
    plotdata(selected_plot).type = PlotType;
    plotdata(selected_plot).title = sTitle;
    plotdata(selected_plot).parameters = distdata(PlotType).parameters;
    plotdata(selected_plot).para_min = distdata(PlotType).para_min;
    plotdata(selected_plot).para_max = distdata(PlotType).para_max;
    plotdata(selected_plot).xMinMax = distdata(PlotType).xMinMax;
    plotdata(selected_plot).function = distdata(PlotType).PDFfunction;
    plotdata(selected_plot).latex = distdata(PlotType).PDFlatex;

    %Setup Panel Distribution Controls
    set(handles.eqn, 'String', plotdata(selected_plot).latex);
    set(handles.uipanel_dist, 'Title', distdata(PlotType).paneltitle);

    parameters = distdata(PlotType).parameters;                 %numerical array length = # parameters
    para_slider_min = distdata(PlotType).para_slider_min;       %numerical array length = # parameters
    para_slider_max = distdata(PlotType).para_slider_max;       %numerical array length = # parameters

    %First Parameter
        n=1;
        set(handles.text_dist_para1, {'String', 'Visible'}, {distdata(PlotType).parameterName(n), 'on'});
        set(handles.edit_dist_para1, {'String', 'Value', 'Visible'}, {parameters(n), parameters(n), 'on'});
        set(handles.slider_dist_para1, {'Min', 'Max', 'Value', 'Visible'},{para_slider_min(n), para_slider_max(n), parameters(n), 'on'});

    %Second Parameter
    n=2;
    if length(distdata(PlotType).parameters)>=n
        set(handles.text_dist_para2, {'String', 'Visible'}, {distdata(PlotType).parameterName(n), 'on'});
        set(handles.edit_dist_para2, {'String', 'Value', 'Visible'}, {parameters(n), parameters(n), 'on'});
        set(handles.slider_dist_para2, {'Min', 'Max', 'Value', 'Visible'},{para_slider_min(n), para_slider_max(n), parameters(n), 'on'});
    else
        set(findobj('-regexp', 'Tag', 'para2'), 'Visible', 'off');
    end

    %Third Parameter
    n=3;
    if length(distdata(PlotType).parameters)>=n
        set(handles.text_dist_para3, {'String', 'Visible'}, {distdata(PlotType).parameterName(n), 'on'});
        set(handles.edit_dist_para3, {'String', 'Value', 'Visible'}, {parameters(n), parameters(n), 'on'});
        set(handles.slider_dist_para3, {'Min', 'Max', 'Value', 'Visible'},{para_slider_min(n), para_slider_max(n), parameters(n), 'on'});
    else
        set(findobj('-regexp', 'Tag', 'para3'), 'Visible', 'off');
    end

    %Forth Parameter
    n=4;
    if length(distdata(PlotType).parameters)>=n
        set(handles.text_dist_para4, {'String', 'Visible'}, {distdata(PlotType).parameterName(n), 'on'});
        set(handles.edit_dist_para4, {'String', 'Value', 'Visible'}, {parameters(n), parameters(n), 'on'});
        set(handles.slider_dist_para4, {'Min', 'Max', 'Value', 'Visible'},{para_slider_min(n), para_slider_max(n), parameters(n), 'on'});
    else
        set(findobj('-regexp', 'Tag', 'para4'), 'Visible', 'off');
    end   

    %Fifth Parameter
    n=5;
    if length(distdata(PlotType).parameters)>=n
        set(handles.text_dist_para5, {'String', 'Visible'}, {distdata(PlotType).parameterName(n), 'on'});
        set(handles.edit_dist_para5, {'String', 'Value', 'Visible'}, {parameters(n), parameters(n), 'on'});
        set(handles.slider_dist_para5, {'Min', 'Max', 'Value', 'Visible'},{para_slider_min(n), para_slider_max(n), parameters(n), 'on'});
    else
        set(findobj('-regexp', 'Tag', 'para5'), 'Visible', 'off');
    end      
    
    %Setup Panel Line Controls        
    set(handles.popupmenu_dist_linecolor, 'Value', strmatch(plotdata(selected_plot).line_color, {'black', 'white', 'red', 'green', 'blue', 'cyan', 'magenta', 'yellow'}, 'exact'));
    set(handles.popupmenu_dist_linestyle, 'Value', strmatch(plotdata(selected_plot).line_style, {'-' '--' ':' '-.'}, 'exact'));
    set(handles.popupmenu_dist_linewidth, 'Value', find(plotdata(selected_plot).line_width == [0.5, 1, 2, 3, 4, 5, 6], 1));
    set(handles.radiobutton_dist_pdf, 'Value', 1);
    set(handles.radiobutton_dist_cdf, 'Value', 0);
    set(handles.radiobutton_dist_haz, 'Value', 0);
    set(handles.checkbox_dist_invisible, 'Value', 0);
    set(handles.edit_dist_plot_title, 'String', plotdata(selected_plot).title);

    %Make panel visible
    set(handles.uipanel_dist, 'Visible', 'on');        

    %Draw Plot      
    update_plot(handles, selected_plot, 1);

    legend_refresh(hObject, eventdata, handles)

function togglebutton_set_Callback(hObject, eventdata, handles, panel_tag)
     %Make Setting Panels Invisible
     set(findobj('-regexp', 'Tag', 'uipanel_set'), 'visible', 'off')
     set(findobj('Tag', panel_tag), 'visible', 'on') 

function togglebutton_plot_clearall_Callback(hObject, eventdata, handles)
clear all;
close all;
ProbDistPlot;





%----------------- DISTRIBUTION PANEL------------------------
function slider_dist_para_Callback(hObject, eventData, handles, paraNum, motion)
    global plotdata selected_plot distdata
    persistent value
        
    %Get Handles
    hSlider = hObject;
    hEditBox = findobj('Tag', ['edit_dist_para', num2str(paraNum)]);
    
    %Prevent Recursion
    if isempty(value), value = get(hSlider, 'Value'); end  %Initialise Value
    if value == get(hSlider, 'Value') && motion, return;, end
 
    %Update uicontrols and variables with new value
    value = get(hSlider, 'Value');
    set(hEditBox, 'String', value)
    plotdata(selected_plot).parameters(paraNum) = value;
    
    %Conduct abbreviated update if mouse is still moving slider
    if motion
        update_plot(handles, selected_plot, 0)
    else
        set(hEditBox, 'Value', value)
        update_plot(handles, selected_plot, 1) %All plots are updated
        %Update plot label for new value
        PlotType = plotdata(selected_plot).type;
        LegendText = distdata(PlotType).paraLegendName{paraNum};
        success = update_label(handles.edit_dist_plot_title, selected_plot, LegendText, value);
    end   
    
function edit_dist_para_Callback(hObject, eventdata, handles, paraNum)
    global plotdata selected_plot distdata

    %Get Handles & Values & Bounds
    hEditBox = hObject;
    hSlider = findobj('Tag', ['slider_dist_para', num2str(paraNum)]);
    value = str2double(get(hEditBox, 'String'));
    
    parameters = plotdata(selected_plot).parameters;
    parameters(paraNum) = value;
    
    PlotType = plotdata(selected_plot).type;
    para_min = distdata(PlotType).para_min(parameters);
    para_max = distdata(PlotType).para_max(parameters);
    ParaName = distdata(PlotType).parameterName;
    
    %Validate input to ensure it is a number
    if (~isfinite(value) || ~isreal(value))
        h = errordlg(['ProbDistPlot: Incorrect ', ParaName{paraNum},' value.'], 'ProbDistPlot');
        set(hEditBox, 'String', get(hEditBox, 'Value'));
        return
    end

    %Check Lower Bound
    if value < para_min(paraNum)
        h = errordlg(['ProbDistPlot: ', ParaName{paraNum},' is below the lower bound'], 'ProbDistPlot');
        set(hEditBox, 'String', get(hEditBox, 'Value'));
        return
    end
    
    %Check Upper Bound
    if value > para_max(paraNum)
        h = errordlg(['ProbDistPlot: ', ParaName{paraNum},' above upper bound'], 'ProbDistPlot');
        set(hEditBox, 'String', get(hEditBox, 'Value'));
        return
    end
    
    %Value Validated - Save in PlotData
    plotdata(selected_plot).parameters = parameters;
    
    %Update Sliders
    %Change slide boundries to include new number
    if value > get(hSlider, 'max'), set(hSlider, 'max', value); end
    if value < get(hSlider, 'min'), set(hSlider, 'min', value); end
    
    %Check other slider boundries to ensure their bounds won't create an
    %error
    hAllSliders = [handles.slider_dist_para1, handles.slider_dist_para2, handles.slider_dist_para3, handles.slider_dist_para4, handles.slider_dist_para5];

    cMinSliders = get(hAllSliders, 'min');
    aMinSliders = [cMinSliders{1:length(para_min)}];
    MinInd = find(para_min > aMinSliders);
    if ~isempty(MinInd); set(hAllSliders(MinInd), 'min', para_min(MinInd)); end;
    
    cMaxSliders = get(hAllSliders, 'max');
    aMaxSliders = [cMaxSliders{1:length(para_max)}];
    MaxInd = find(para_max < aMaxSliders);
    if ~isempty(MaxInd); set(hAllSliders(MaxInd), 'max', para_max(MaxInd)); end;   

    %Set Slider and Edit Box Value
    set(hEditBox, 'Value', value);
    set(hSlider, 'Value', value);
    
    %Update the plot
    update_plot(handles, selected_plot, 1)
    
    %Update plot label for new value
    LegendText = distdata(PlotType).paraLegendName{paraNum};
    success = update_label(handles.edit_dist_plot_title, selected_plot, LegendText, value);
 
function radiobutton_dist_pdf_Callback(hObject, eventdata, handles)
    global plotdata selected_plot distdata
    
    set(handles.radiobutton_dist_pdf, 'Value', 1)
    set(handles.radiobutton_dist_cdf, 'Value', 0)
    set(handles.radiobutton_dist_haz, 'Value', 0)
    
    PlotType = plotdata(selected_plot).type;
    plotdata(selected_plot).function = distdata(PlotType).PDFfunction;
    plotdata(selected_plot).latex = distdata(PlotType).PDFlatex;
    set(handles.eqn, 'String', plotdata(selected_plot).latex);
    
    update_plot(handles, selected_plot, 1)
    
    %Update plot label for new value
    success = update_label(handles.edit_dist_plot_title, selected_plot, 'CDF', 'PDF');
    success = update_label(handles.edit_dist_plot_title, selected_plot, 'Haz', 'PDF');

function radiobutton_dist_cdf_Callback(hObject, eventdata, handles)
    global plotdata selected_plot distdata
    
    set(handles.radiobutton_dist_pdf, 'Value', 0)
    set(handles.radiobutton_dist_cdf, 'Value', 1)
    set(handles.radiobutton_dist_haz, 'Value', 0)
    
    PlotType = plotdata(selected_plot).type;
    plotdata(selected_plot).function = distdata(PlotType).CDFfunction;
    plotdata(selected_plot).latex = distdata(PlotType).CDFlatex;
    set(handles.eqn, 'String', plotdata(selected_plot).latex);
    
    update_plot(handles, selected_plot, 1)
    
    %Update plot label for new value
    success = update_label(handles.edit_dist_plot_title, selected_plot, 'PDF', 'CDF');
    success = update_label(handles.edit_dist_plot_title, selected_plot, 'Haz', 'CDF');

function radiobutton_dist_haz_Callback(hObject, eventdata, handles)
    global plotdata selected_plot distdata
    
    set(handles.radiobutton_dist_pdf, 'Value', 0)
    set(handles.radiobutton_dist_cdf, 'Value', 0)
    set(handles.radiobutton_dist_haz, 'Value', 1)
    
    PlotType = plotdata(selected_plot).type;
    plotdata(selected_plot).function = distdata(PlotType).HAZfunction;
    plotdata(selected_plot).latex = distdata(PlotType).HAZlatex;
    set(handles.eqn, 'String', plotdata(selected_plot).latex);
    
    update_plot(handles, selected_plot, 1)
    
    %Update plot label for new value
    success = update_label(handles.edit_dist_plot_title, selected_plot, 'PDF', 'Haz');
    success = update_label(handles.edit_dist_plot_title, selected_plot, 'CDF', 'Haz');
    
    
    
function checkbox_dist_invisible_Callback(hObject, eventdata, handles)

    global plotdata selected_plot

    value = get(hObject, 'Value');
    plotdata(selected_plot).visible = ~value;

    update_plot(handles, 0, 1);
    legend_refresh(hObject, eventdata, handles);

function edit_dist_plot_title_Callback(hObject, eventdata, handles)
    global plotdata selected_plot

    plotdata(selected_plot).title = get(hObject, 'String');

    legend_refresh(hObject, eventdata, handles);

function linewidth_Callback(hObject, eventdata, handles)
    global plotdata selected_plot

    %Get text of selected item
    sObject = get(hObject, 'String');
    sSize = sObject{get(hObject, 'Value'), :};

    %Set value
    plotdata(selected_plot).line_width = str2num(sSize);
    set(plotdata(selected_plot).line_handle,'LineWidth',str2num(sSize));

    %Refresh Legend
    ProbDistPlot('legend_refresh', hObject, eventdata, handles);

function linestyle_Callback(hObject, eventdata, handles)
    global plotdata selected_plot

    value = get(hObject, 'Value');
    sValue = {'-' '--' ':' '-.'};
    sValueButton = {'' ' ---' ' ...' ' -.-'};
    plotdata(selected_plot).line_style = sValue{value};
    set(plotdata(selected_plot).line_handle, 'LineStyle', sValue{value})

    %Updates the Plot Button name to include the line style information
    hButton = findobj('Tag', strcat('togglebutton_plot', num2str(selected_plot)))
    set(hButton, 'String', strcat('Plot ', num2str(selected_plot), sValueButton{value}))

    %Refresh Legend
    ProbDistPlot('legend_refresh', hObject, eventdata, handles);

function linecolor_Callback(hObject, eventdata, handles)
    global plotdata selected_plot

    value = get(hObject, 'Value');
    sValue = {'black', 'white', 'red', 'green', 'blue', 'cyan', 'magenta', 'yellow'};

    plotdata(selected_plot).line_color = sValue{value};
    hButton = findobj('Tag', strcat('togglebutton_plot', num2str(selected_plot)))
    set(hButton, 'ForegroundColor', sValue{value})
    set(plotdata(selected_plot).line_handle, 'Color', sValue{value})

    %Refresh Legend
    ProbDistPlot('legend_refresh', hObject, eventdata, handles);




%------------------- Legend Panel ---------------------------------%

function checkbox_legend_display_Callback(hObject, eventdata, handles)
    ProbDistPlot('legend_refresh', hObject, eventdata, handles)

function popupmenu_legend_boxcolor_Callback(hObject, eventdata, handles)
    legend_handle = legend;

    value = get(hObject, 'Value');

    if value == 1
        set(legend_handle, 'Box', 'off')
    else
        color_string = {'white', 'black', 'white', 'red', 'green', 'blue', 'cyan', 'magenta', 'yellow'};
        set(legend_handle, 'EdgeColor', color_string{value})
        set(legend_handle, 'Box', 'on')
    end

function popupmenu_legend_backcolor_Callback(hObject, eventdata, handles)
    legend_handle = legend;

    value = get(hObject, 'Value');

    color_string = {'none', 'black', 'white', 'red', 'green', 'blue', 'cyan', 'magenta', 'yellow'};

    set(legend_handle, 'Color', color_string{value})

function popupmenu_legend_txtcolor_Callback(hObject, eventdata, handles)
    legend_handle = legend;

    value = get(hObject, 'Value');

    color_string = {'white', 'black', 'white', 'red', 'green', 'blue', 'cyan', 'magenta', 'yellow'};

    set(legend_handle, 'TextColor', color_string{value})

function radiobutton_legend_arrow_Callback(hObject, eventdata, handles)

    global plotdata
    ColIntervals = 4;
    VertSpacing = 35;


    %Set radiobutton values
    set(handles.radiobutton_legend_arrow, 'Value', 1);
    set(handles.radiobutton_legend_table, 'Value', 0);

    %Creates masks of valid entries
    cell_titles = {plotdata.title};
    exist_mask = ~strcmp(cell_titles, repmat({' '}, 1, 10));

    %Creates masks of visible plots
    legend_mask = [plotdata.visible];

    %Create Display Arrays
    display_mask = exist_mask.*legend_mask;
    concate_titles = cell_titles(find(display_mask));
    hlines = [plotdata.line_handle];
    concate_hlines = hlines(find(display_mask));


    %find which point will be best to place labels
    YData = cell2mat(get(concate_hlines, 'YData'));
    ASize = size(YData);
    int = round(ASize(2)/ColIntervals);    %
    interval = int:int:ASize(2)-int;
    max_at_int = max(YData(:,interval));
    [max_y label_int] = max(max_at_int);
    label_col = label_int.*int;

    %find column for plotting the tip of the arrow
    plotshape = [2 3 2].*int;
    if max_at_int(3)<max_at_int(1), plotshape(2) = 1; end;

    arrow_col = plotshape(label_int);

    % Find order to put place textarrows
    [YSortData, Order] = sort(YData(:,arrow_col),  'descend');

    %plot arrows
    %Get position of arrows in normalised unit
    XData = cell2mat(get(concate_hlines, 'XData'));
    [x y] = dsxy2figxy(handles.axis_main, XData(:,label_col), YData(:,label_col))
    [x(:,2) y(:,2)] = dsxy2figxy(handles.axis_main, XData(:,arrow_col), YData(:,arrow_col))

    %Change the y value so the text boxes are above plot
    FigPos = get(handles.MainPlotter, 'Position');
    AxesPos = get(handles.axis_main, 'Position');
    TopY = (AxesPos(2)+AxesPos(4) - VertSpacing)/FigPos(4);

    %Plot TextArrows
    for i = 1:ASize(1)
        y(i,1) = TopY
        hTextArrow(i) = annotation('textarrow',x(Order(i),:),y(Order(i),:),'String', concate_titles{Order(i)})
        TopY = TopY-VertSpacing/FigPos(4);
    end


% %Move Boxes so that they fit onto the axes
% set(hTextArrow, 'Units', 'pixels');
% Pos = cell2mat(get(hTextArrow, 'Position'));
% set(hTextArrow, 'Units', 'normalized')



function radiobutton_legend_table_Callback(hObject, eventdata, handles)
    set(handles.radiobutton_legend_arrow, 'Value', 0);
    set(handles.radiobutton_legend_table, 'Value', 1);


%------------------- Labels Panel ---------------------------------%

function edit_labels_title_Callback(hObject, eventdata, handles)
global lang
title(handles.axis_main, get(hObject, 'String'), 'interpreter',lang)

function edit_labels_xaxis_Callback(hObject, eventdata, handles)
global lang    
xlabel(handles.axis_main, get(hObject, 'String'), 'interpreter',lang)

function edit_labels_yaxis_Callback(hObject, eventdata, handles)
global lang    
ylabel(handles.axis_main, get(hObject, 'String'), 'interpreter',lang)

function ChangeFontSize_Callback(hObject, eventdata, handles, sTitle)
    %Get text of selected item
    sObject = get(hObject, 'String');
    sSize = sObject{get(hObject, 'Value'), :};

    %Get handle to label/title
    hTitle = get(handles.axis_main, sTitle);

    %If valid selection set value
    try
        set(hTitle,'fontsize',str2num(sSize));
    catch

    end

function ChangeBold_Callback(hObject, eventdata, handles, sTitle)
    %Get text of selected item
    value = get(hObject, 'Value');

    %Set string value for bold
    if value, sValue = 'bold'; else sValue = 'normal'; end

    %Get handle to label/title
    hTitle = get(handles.axis_main, sTitle);

    %Set value
    set(hTitle,'FontWeight',sValue);


%--------------------- Axis Panel -----------------------------------%
function radiobutton_axis_normal_Callback(hObject, eventdata, handles)
    set(handles.radiobutton_axis_normal, 'value', 1)
    set(handles.radiobutton_axis_box, 'value', 0)
    set(handles.radiobutton_axis_zero, 'value', 0)
    set(handles.axis_main, 'box', 'off')

function radiobutton_axis_box_Callback(hObject, eventdata, handles)
    set(handles.radiobutton_axis_normal, 'value', 0)
    set(handles.radiobutton_axis_box, 'value', 1)
    set(handles.radiobutton_axis_zero, 'value', 0)
    set(handles.axis_main, 'box', 'on')

function radiobutton_axis_zero_Callback(hObject, eventdata, handles)
% This function will have the axis occur at x = 0. Yet to be written


function checkbox_axis_xautoscale_Callback(hObject, eventdata, handles)

    value = get(hObject, 'Value');

    if value
        set([handles.checkbox_fixXMin, handles.checkbox_fixXMax], 'Value', 0)
        ProbDistPlot('slider_xaxis_Callback', handles.slider_xaxis, eventdata, handles, 'reset')
    else
        set([handles.checkbox_fixXMin, handles.checkbox_fixXMax], 'Value', 1)
    end

    update_plot(handles, 0, 1);

function checkbox_axis_xlogscale_Callback(hObject, eventdata, handles)
    value = get(hObject, 'Value');

    if value
        set(handles.axis_main, 'XScale', 'log')
    else
        set(handles.axis_main, 'XScale', 'linear')
    end

function checkbox_axis_xmajorgrid_Callback(hObject, eventdata, handles)
    value = get(hObject, 'Value');

    if value
        set(handles.axis_main, 'XGrid', 'on')
    else
        set(handles.axis_main, 'XGrid', 'off')
    end

function checkbox_axis_xminorgrid_Callback(hObject, eventdata, handles)
    value = get(hObject, 'Value');

    if value
        set(handles.axis_main, 'XMinorGrid', 'on')
    else
        set(handles.axis_main, 'XMinorGrid', 'off')
    end

function edit_axis_xstep_Callback(hObject, eventdata, handles)



function checkbox_axis_yautoscale_Callback(hObject, eventdata, handles)
    value = get(hObject, 'Value');

    if value
        set([handles.checkbox_fixYMin, handles.checkbox_fixYMax], 'Value', 0)
        ProbDistPlot('slider_yaxis_Callback', handles.slider_yaxis, eventdata, handles, 'reset')
    else
        set([handles.checkbox_fixYMin, handles.checkbox_fixYMax], 'Value', 1)
    end

    update_plot(handles, 0, 1);

function checkbox_axis_ylogscale_Callback(hObject, eventdata, handles)
    value = get(hObject, 'Value');

    if value
        set(handles.axis_main, 'YScale', 'log')
    else
        set(handles.axis_main, 'YScale', 'linear')
    end

function checkbox_axis_ymajorgrid_Callback(hObject, eventdata, handles)
    value = get(hObject, 'Value');

    if value
        set(handles.axis_main, 'YGrid', 'on')
    else
        set(handles.axis_main, 'YGrid', 'off')
    end

function checkbox_axis_yminorgrid_Callback(hObject, eventdata, handles)
    value = get(hObject, 'Value');

    if value
        set(handles.axis_main, 'YMinorGrid', 'on')
    else
        set(handles.axis_main, 'YMinorGrid', 'off')
    end

function edit_axis_ystep_Callback(hObject, eventdata, handles)



function popupmenu_axis_gridstyle_Callback(hObject, eventdata, handles)
    value = get(hObject, 'Value');
    sValue = {'-' '--' ':' '-.'};
    set(handles.axis_main, 'GridLineStyle', sValue{value})

    

%--------------------- Export Panel -----------------------------------%

function pushbutton_export_print_Callback(hObject, eventdata, handles)
    %Get Axis Size
    a_inset = get(handles.axis_main, 'TightInset');  %Left Bottom Right Top
    a_position = get(handles.axis_main, 'Position');
    f_position = get(handles.MainPlotter, 'Position');

    %Create New Figure the slightly bigger than the axes
    new_pos = [f_position(1)+a_position(1)-a_inset(1), f_position(2)+a_position(2)-a_inset(2), a_position(3)+a_inset(1)+a_inset(3)+10, a_position(4)+a_inset(2)+a_inset(4)+40];
    hExportFigure = figure('Position', new_pos, 'Menubar', 'none', 'Toolbar', 'none', 'Tag', 'ExportFigure','PaperPositionMode', 'auto');

    %Move axes to new figure and print
    set(handles.axis_main, 'Parent', hExportFigure)

    %Move annotation overlay to new figure
    hScribe = findall(handles.MainPlotter, 'Tag', 'scribeOverlay');
    if ~isempty(hScribe)
        set(hScribe, 'Units', 'pixels')
        set(hScribe, 'Parent', hExportFigure)
    end

    %Move legend overlay to new figure
    hLegend = findall(handles.MainPlotter, 'Tag', 'legend')
    if ~isempty(hLegend)
        set(hLegend, 'Units', 'pixels')
        set(hLegend, 'Parent', hExportFigure)
    end


    %Print
    h = printpreview;
    waitfor(h)

    %Move axes back to original figure and close old figure
    set(handles.axis_main, 'Parent', handles.MainPlotter)
    if ~isempty(hScribe), set(hScribe, 'Parent', handles.MainPlotter), end
    if ~isempty(hLegend), set(hLegend, 'Parent', handles.MainPlotter), end
    close(hExportFigure)

function pushbutton_export_clipboard_Callback(hObject, eventdata, handles)
    %Get Axis Size
    a_inset = get(handles.axis_main, 'TightInset');  %Left Bottom Right Top
    a_position = get(handles.axis_main, 'Position');
    f_position = get(handles.MainPlotter, 'Position');

    %Create New Figure the slightly bigger than the axes
    new_pos = [f_position(1)+a_position(1)-a_inset(1), f_position(2)+a_position(2)-a_inset(2), a_position(3)+a_inset(1)+a_inset(3)+10, a_position(4)+a_inset(2)+a_inset(4)+40];
    hExportFigure = figure('Position', new_pos, 'Menubar', 'none', 'Toolbar', 'none', 'Tag', 'ExportFigure','PaperPositionMode', 'auto');

    %Move axes to new figure and print
    set(handles.axis_main, 'Parent', hExportFigure)

    %Move annotation overlay to new figure
    hScribe = findall(handles.MainPlotter, 'Tag', 'scribeOverlay');
    if ~isempty(hScribe)
        set(hScribe, 'Units', 'pixels')
        set(hScribe, 'Parent', hExportFigure)
    end

    %Move legend overlay to new figure
    hLegend = findall(handles.MainPlotter, 'Tag', 'legend')
    if ~isempty(hLegend)
        set(hLegend, 'Units', 'pixels')
        set(hLegend, 'Parent', hExportFigure)
    end

    hgexport(hExportFigure,'-clipboard')

    %Move axes back to original figure and close old figure
    set(handles.axis_main, 'Parent', handles.MainPlotter)
    if ~isempty(hScribe), set(hScribe, 'Parent', handles.MainPlotter), end
    if ~isempty(hLegend), set(hLegend, 'Parent', handles.MainPlotter), end
    close(hExportFigure)

function pushbutton_export_picture_Callback(hObject, eventdata, handles)
    %Get save info and save
    FileExt = {'*.tif','TIFF Image (*.tif)';'*.jpg', 'JPEG Image (*.jpg)';'*.bmp', 'BITMAP Image (*.bmp)'};

    [filename, pathname, Index] = uiputfile( FileExt, 'Save as');

    %If valid save inputs then do the save
    if filename~=0

        %Get Axis Size
        a_inset = get(handles.axis_main, 'TightInset');  %Left Bottom Right Top
        a_position = get(handles.axis_main, 'Position');
        f_position = get(handles.MainPlotter, 'Position');

        %Create New Figure the slightly bigger than the axes
        new_pos = [f_position(1)+a_position(1)-a_inset(1), f_position(2)+a_position(2)-a_inset(2), a_position(3)+a_inset(1)+a_inset(3)+10, a_position(4)+a_inset(2)+a_inset(4)+40];
        hExportFigure = figure('Position', new_pos, 'Menubar', 'none', 'Toolbar', 'none', 'Tag', 'ExportFigure','PaperPositionMode', 'auto');

        %Move axes to new figure and print
        set(handles.axis_main, 'Parent', hExportFigure)

        %Move annotation overlay to new figure
        hScribe = findall(handles.MainPlotter, 'Tag', 'scribeOverlay');
        if ~isempty(hScribe)
            set(hScribe, 'Units', 'pixels')
            set(hScribe, 'Parent', hExportFigure)
        end

        %Move legend overlay to new figure
        hLegend = findall(handles.MainPlotter, 'Tag', 'legend')
        if ~isempty(hLegend)
            set(hLegend, 'Units', 'pixels')
            set(hLegend, 'Parent', hExportFigure)
        end

        %Change Directory
        CurrentDir = cd;
        cd(pathname);

        %Save File
        saveas(hExportFigure, filename)

        %Move axes back to original figure and close old figure
        set(handles.axis_main, 'Parent', handles.MainPlotter)
        if ~isempty(hScribe), set(hScribe, 'Parent', handles.MainPlotter), end
        if ~isempty(hLegend), set(hLegend, 'Parent', handles.MainPlotter), end
        close(hExportFigure)

        %Return to normal directory
        cd(CurrentDir);
    end

function pushbutton_export_pdf_Callback(hObject, eventdata, handles)
    [filename, pathname] = uiputfile( {'*.pdf'}, 'Save as');

    if filename~=0

        %Get Axis Size
        a_inset = get(handles.axis_main, 'TightInset');  %Left Bottom Right Top
        a_position = get(handles.axis_main, 'Position');
        f_position = get(handles.MainPlotter, 'Position');

        %Create New Figure the slightly bigger than the axes
        new_pos = [f_position(1)+a_position(1)-a_inset(1), f_position(2)+a_position(2)-a_inset(2), a_position(3)+a_inset(1)+a_inset(3)+10, a_position(4)+a_inset(2)+a_inset(4)+40];
        hExportFigure = figure('Position', new_pos, 'Menubar', 'none', 'Toolbar', 'none', 'Tag', 'ExportFigure','PaperPositionMode', 'auto');

        %Move axes to new figure and print
        set(handles.axis_main, 'Parent', hExportFigure)

        %Move annotation overlay to new figure
        hScribe = findall(handles.MainPlotter, 'Tag', 'scribeOverlay');
        if ~isempty(hScribe)
            set(hScribe, 'Units', 'pixels')
            set(hScribe, 'Parent', hExportFigure)
        end

        %Move legend overlay to new figure
        hLegend = findall(handles.MainPlotter, 'Tag', 'legend')
        if ~isempty(hLegend)
            set(hLegend, 'Units', 'pixels')
            set(hLegend, 'Parent', hExportFigure)
        end

        %Change Directory
        CurrentDir = cd;
        cd(pathname);

        %Save Figure
        saveas(hExportFigure, filename)

        %Move axes back to original figure and close old figure
        set(handles.axis_main, 'Parent', handles.MainPlotter)
        if ~isempty(hScribe), set(hScribe, 'Parent', handles.MainPlotter), end
        if ~isempty(hLegend), set(hLegend, 'Parent', handles.MainPlotter), end
        close(hExportFigure)

        %Return to normal directory
        cd(CurrentDir);
    end

function pushbutton_export_MATLAB_Callback(hObject, eventdata, handles)
    [filename, pathname] = uiputfile( {'*.fig'}, 'Save as');

    if filename~=0

        %Get Axis Size
        a_inset = get(handles.axis_main, 'TightInset');  %Left Bottom Right Top
        a_position = get(handles.axis_main, 'Position');
        f_position = get(handles.MainPlotter, 'Position');

        %Create New Figure the slightly bigger than the axes
        new_pos = [f_position(1)+a_position(1)-a_inset(1), f_position(2)+a_position(2)-a_inset(2), a_position(3)+a_inset(1)+a_inset(3)+10, a_position(4)+a_inset(2)+a_inset(4)+40];
        hExportFigure = figure('Position', new_pos, 'Menubar', 'none', 'Toolbar', 'none', 'Tag', 'ExportFigure','PaperPositionMode', 'auto');

        %Move axes to new figure and print
        set(handles.axis_main, 'Parent', hExportFigure)

        %Move annotation overlay to new figure
        hScribe = findall(handles.MainPlotter, 'Tag', 'scribeOverlay');
        if ~isempty(hScribe)
            set(hScribe, 'Units', 'pixels')
            set(hScribe, 'Parent', hExportFigure)
        end

        %Move legend overlay to new figure
        hLegend = findall(handles.MainPlotter, 'Tag', 'legend')
        if ~isempty(hLegend)
            set(hLegend, 'Units', 'pixels')
            set(hLegend, 'Parent', hExportFigure)
        end

        %Change Directory
        CurrentDir = cd;
        cd(pathname);

        %Save Figure
        saveas(hExportFigure, filename)

        %Move axes back to original figure and close old figure
        set(handles.axis_main, 'Parent', handles.MainPlotter)
        if ~isempty(hScribe), set(hScribe, 'Parent', handles.MainPlotter), end
        if ~isempty(hLegend), set(hLegend, 'Parent', handles.MainPlotter), end
        close(hExportFigure)

        %Return to normal directory
        cd(CurrentDir);
    end

function pushbutton_export_excel_Callback(hObject, eventdata, handles)
    %Wont take across scribes nor text size

    global plotdata lang
    
   %Set Colors Arrays
    LColor =    {[1 1 0],...    %Yellow
                [1 0 1],...     %Magneta
                [0 1 1],...     %Cyan
                [1 0 0],...     %Red
                [0 1 0],...     %Green
                [0 0 1],...     %Blue
                [1 1 1],...     %White
                [0 0 0]};       %Black

    LEColor =   [65535, ...     %Yellow
                5066944,...     %Magneta
                13020235,...    %Cyan
                255,...         %Red
                5880731,...     %Green
                12419407,...    %Blue
                16777215,...    %White
                0];             %Black
  
    %Build Array for Export

    a = 1;
    for k=1:length(plotdata)
        if ~(plotdata(k).line_handle==0) &  plotdata(k).visible
            Data(:,a) = get(plotdata(k).line_handle, 'XData');
            Data(:,a+1) = get(plotdata(k).line_handle, 'YData');
            SeriesName{a} = plotdata(k).title;
            SeriesName{a+1} = ' ';
            plot_num((a+1)/2) = k;  %Records the number of each valid plot
            a = a + 2;
        end
    end
    
    %Replace Latex with Greek Symbols
    if strcmp(lang,'LaTex'), SeriesName = Latex2Tex(SeriesName);end
    SeriesName = Tex2Unicode(SeriesName);
    
    % Continue building data matrix to export    
    ASize = size(Data);
    cData=cell(ASize(1)+1, ASize(2));
    cData(1,:) = SeriesName;
    cData(2:end,:) = num2cell(Data);

    %Get save as information for excel file
    [filename, pathname] = uiputfile( {'*.xls'}, 'Save as');
    if isnumeric(filename) return; end
       
    %----------------Start / Load Excel-------------
    try
        Excel = actxserver('Excel.Application');
    catch
        h = errordlg('ProbDistPlot: Excel is not available on this computer', 'PDFBeta'); return;
    end
    
    Excel.Visible = 1;
    
    Workbook = Excel.workbooks.Add;
    Workbook.SaveAs([pathname filename]);
    Workbook.Close(false);
    Workbook = Excel.workbooks.Open([pathname filename]);
    Sheet = Excel.ActiveSheet;
    Sheet.Name = 'Chart Data';
    
    Chart = Workbook.Charts.Add; 
    Chart.ChartType = 'xlXYScatterSmoothNoMarkers';
    Chart.Name = 'Prob Chart';
    
    %Put Data into Excel Sheet
    firstcol = 'A';
    lastcol = num2ExCol(ASize(2));
    firstrow = num2str(2);
    lastrow = num2str(str2num(firstrow) + ASize(1));  
    range = [firstcol firstrow ':' lastcol lastrow];
    
    Sheet.Activate;
    Select(Range(Excel,range));
    set(Excel.selection,'Value',cData); 
    
    % If the Y Axis is Log then take out all Y values less than or = 0
    if strcmp(get(handles.axis_main, 'yscale'), 'log')
        yind = 2:2:ASize(2);
        Mask = zeros(ASize);
        Mask(:,yind) = Data(:,yind)<=0;
        [r, c] = find(Mask);
        r = r + 2;
        for i = 1:length(r)
            Select(Range(Excel,[num2ExCol(c(i)) num2str(r(i))]));
            set(Excel.selection,'Value',[]);
        end
    end
    
    % If the X Axis is Log then take out all X values less than or = 0
    if strcmp(get(handles.axis_main, 'xscale'), 'log')
        xind = 1:2:ASize(2);
        Mask = zeros(ASize);
        Mask(:,xind) = Data(:,xind)<=0;
        [r, c] = find(Mask);
        r = r + 2;
        for i = 1:length(r)
            Select(Range(Excel,[num2ExCol(c(i)) num2str(r(i))]));
            set(Excel.selection,'Value',[]);
        end
    end

    Workbook.Save;
    
    %Make Chart Series
    Chart.Activate
    for col = 1:2:ASize(2)
        %Make New Series
        Series = Chart.SeriesCollection.NewSeries;
        %Take off Markers
        Series.MarkerStyle = 'xlMarkerStyleNone';
            
        %Set Line Style
        switch get(plotdata(plot_num((col+1)/2)).line_handle, 'LineStyle')
            case '-'
                Series.Format.Line.DashStyle = 'msoLineSolid';
            case '--'
                Series.Format.Line.DashStyle = 'msoLineLongDash';
            case ':'
                Series.Format.Line.DashStyle = 'msoLineSysDot';
            case '-.'
                Series.Format.Line.DashStyle = 'msoLineDashDot';
        end
        
        %Set line weight
        Series.Format.Line.Weight = get(plotdata(plot_num((col+1)/2)).line_handle, 'LineWidth');
        
        %Set Series Name        
        Series.Name = ['=''' Sheet.name '''!' num2ExCol(col) firstrow];
        
        %Set plot values
        Series.XValues = ['=''' Sheet.name '''!' num2ExCol(col)  int2str(str2num(firstrow)+1) ':' num2ExCol(col)  lastrow];
        Series.Values = ['=''' Sheet.name '''!' num2ExCol(col+1)  int2str(str2num(firstrow)+1) ':' num2ExCol(col+1)  lastrow];
        
        %Set Line Color (unexpected performance of excel requires you to
        %visibility on and off before the line color can be changed
        Series.Format.Line.Visible = 'msoFalse';
        Series.Format.Line.Visible = 'msoTrue';
        iseq = @(c)isequal(c, get(plotdata(plot_num((col+1)/2)).line_handle, 'Color'));     
        Series.Format.Line.ForeColor.RGB =  LEColor(find(cellfun(iseq, LColor)));
        
    end  

    
    %-----------Chart Title-----------------------
    sTitle = get(get(handles.axis_main, 'Title'), 'String');
    %If Latex then covert back to Unicode
    if strcmp(lang,'LaTex'), sTitle = Latex2Tex(sTitle);end
    
    if ~isempty(sTitle)
        Chart.HasTitle = 1;
        
        Sheet.Activate;
        Select(Range(Excel,'A1'));
        set(Excel.selection,'Value',Tex2Unicode(sTitle));
        Chart.Activate
        Chart.ChartTitle.Text = '=''Chart Data''!$A$1';
           
        if strcmp(get(get(handles.axis_main, 'Title'), 'FontWeight'),'bold')
            Chart.ChartTitle.Characters.Font.Bold = 1;
        else
            Chart.ChartTitle.Characters.Font.Bold = 0;
        end
    else
        Chart.HasTitle = 0;
    end
    
    %------------Add Legend------------------------
    if get(handles.checkbox_legend_display, 'Value')
        
        Chart.HasLegend = 1;
        Chart.Legend.IncludeInLayout = 0;  %Make legend inside chart
        
        %Set position of legend to be similar
        hLeg = findall(handles.MainPlotter, 'Tag', 'legend');
        LPos = get(hLeg, 'Position');
        Chart.Legend.Left = LPos(1);
        APos = get(handles.axis_main, 'Position');
        Chart.Legend.Top = APos(2)+APos(4)-LPos(2)-LPos(4);
        
        %Set Background Color
        if  isstr(get(hLeg, 'Color'))
            Chart.Legend.Format.Fill.Visible = 'msoFalse';
        else
            Chart.Legend.Format.Fill.Visible = 'msoTrue';
            iseq = @(c)isequal(c, get(hLeg, 'Color'));      
            Chart.Legend.Format.Fill.ForeColor.RGB = LEColor(find(cellfun(iseq, LColor)));
        end
        
        
        %Set Border Color
        if strcmp(get(hLeg, 'Box'), 'off')
            Chart.Legend.Format.Line.Visible = 'msoFalse';
        else
            Chart.Legend.Format.Line.Style = 'msoLineSingle';
            Chart.Legend.Format.Line.Visible = 'msoTrue';
            iseq = @(c)isequal(c, get(hLeg, 'EdgeColor'));
            Chart.Legend.Format.Line.ForeColor.RGB = LEColor(find(cellfun(iseq, LColor)));       
        end
    else
        Chart.HasLegend = 0;
    end
    
    
    
    %--------------Plot Area Border------------------
    
    if strcmp(get(handles.axis_main, 'Box'), 'on')
        Chart.PlotArea.Format.Line.Visible = 'msoTrue';
        Chart.PlotArea.Format.Line.ForeColor.RGB = 0;
    else
        Chart.PlotArea.Format.Line.Visible = 'msoFalse';
    end
    
    
    %----------------X Axis-----------------------------
    % X Label
    XTitle = get(get(handles.axis_main, 'xlabel'), 'String');
    %Covert back to Unicode
    if strcmp(lang,'LaTex'), XTitle = Latex2Tex(XTitle);end
            
    if ~isempty(XTitle)
        Chart.Axes(1).HasTitle = 1;
        
        Sheet.Activate;
        Select(Range(Excel,'B1'));
        set(Excel.selection,'Value',Tex2Unicode(XTitle)); 
        Chart.Activate
        Chart.Axes(1).AxisTitle.Text = '=''Chart Data''!$B$1';        
        
        if strcmp(get(get(handles.axis_main, 'xlabel'), 'FontWeight'),'bold')
            Chart.Axes(1).AxisTitle.Characters.Font.Bold = 1;
        else
            Chart.Axes(1).AxisTitle.Characters.Font.Bold = 0;
        end
    else % If there is no XTitle in MATLAB
        Chart.Axes(1).HasTitle = 0;
    end

    %X Limits
    XLimits = get(handles.axis_main, 'xLim');
    Chart.Axes(1).MinimumScale = XLimits(1);
    Chart.Axes(1).MaximumScale = XLimits(2);
    
    % X Scale
    if  strcmp(get(handles.axis_main, 'xscale'), 'log')
        try
            Chart.Axes(1).ScaleType = 'xlScaleLogarithmic';
        catch
            
        end
    else
        Chart.Axes(1).ScaleType = 'xlScaleLinear';
    end
    
    %GridLines
    Chart.Axes(1).HasMajorGridlines = strcmp(get(handles.axis_main, 'xGrid'), 'on');
    Chart.Axes(1).HasMinorGridlines = strcmp(get(handles.axis_main, 'xMinorGrid'), 'on');
    
    Chart.Axes(1).MinorGridLines.Format.Line.DashStyle = 'msoLineDash';
    
    switch get(handles.axis_main, 'GridLineStyle')
        case '-'
            Chart.Axes(1).MajorGridLines.Format.Line.DashStyle = 'msoLineSolid';
        case '--'
            Chart.Axes(1).MajorGridLines.Format.Line.DashStyle = 'msoLineLongDash';
        case ':'
            Chart.Axes(1).MajorGridLines.Format.Line.DashStyle = 'msoLineSysDot';
        case '-.'
            Chart.Axes(1).MajorGridLines.Format.Line.DashStyle = 'msoLineDashDot';
    end
    
    %Set Ticklabels to 2 decimal places
    TLabels = Chart.Axes(2).TickLabels;
    TLabels.NumberFormat = '0.00';
    
    %----------------Y Axis-----------------------------
    % Y Label
    YTitle = get(get(handles.axis_main, 'ylabel'), 'String');
    %Covert back to Unicode
    if strcmp(lang,'LaTex'), YTitle = Latex2Tex(YTitle);end
    
    if ~isempty(YTitle)       
        Chart.Axes(2).HasTitle = 1;
        
        Sheet.Activate;
        Select(Range(Excel,'C1'));
        set(Excel.selection,'Value',Tex2Unicode(YTitle));
        Chart.Activate
        Chart.Axes(2).AxisTitle.Text = '=''Chart Data''!$C$1'; 
        
        if strcmp(get(get(handles.axis_main, 'ylabel'), 'FontWeight'),'bold')
            Chart.Axes(2).AxisTitle.Characters.Font.Bold = 1;
        else
            Chart.Axes(2).AxisTitle.Characters.Font.Bold = 0;
        end
    else
        Chart.Axes(2).HasTitle = 0;
    end
    
    %Y Limits
    YLimits = get(handles.axis_main, 'yLim');
    Chart.Axes(2).MinimumScale = YLimits(1);
    Chart.Axes(2).MaximumScale = YLimits(2);
    
    % Y Scale
    if  strcmp(get(handles.axis_main, 'yscale'), 'log')
        Chart.Axes(2).ScaleType = 'xlScaleLogarithmic';
    else
        Chart.Axes(2).ScaleType = 'xlScaleLinear';
    end
    
    %GridLines
    Chart.Axes(2).HasMajorGridlines = strcmp(get(handles.axis_main, 'yGrid'), 'on');
    Chart.Axes(2).HasMinorGridlines = strcmp(get(handles.axis_main, 'yMinorGrid'), 'on');
    
    Chart.Axes(2).MinorGridLines.Format.Line.DashStyle = 'msoLineDash';
    
    switch get(handles.axis_main, 'GridLineStyle')
        case '-'
            Chart.Axes(2).MajorGridLines.Format.Line.DashStyle = 'msoLineSolid';
        case '--'
            Chart.Axes(2).MajorGridLines.Format.Line.DashStyle = 'msoLineLongDash';
        case ':'
            Chart.Axes(2).MajorGridLines.Format.Line.DashStyle = 'msoLineSysDot';
        case '-.'
            Chart.Axes(2).MajorGridLines.Format.Line.DashStyle = 'msoLineDashDot';
    end
    
    %Take off box surrounding chart sheet
    Chart.ChartArea.Format.Line.Visible = 'msoFalse';

%--------------------- Options Panel -----------------------------------%

function edit_options_PlotRes_Callback(hObject, eventdata, handles)
    value = str2num(get(hObject, 'String'));

    %Validate input to ensure it is a number
    if ~isfinite(value) || ~isreal(value)
        h = errordlg('ProbDistPlot: Incorrect value.', 'ProbDistPlot');
        set(hObject, 'String', get(hObject, 'Value'));
        return
    end

    set(hObject, 'Value', value)
    update_plot(handles, 0, 1)

function popupmenu_options_linewidth_Callback(hObject, eventdata, handles)
    global plotdata

    %Get text of selected item
    value = get(hObject, 'Value');
    sObject = get(hObject, 'String');
    sSize = sObject{value, :};

    %Set value
    [plotdata.line_width] = deal(str2num(sSize));
    set(handles.popupmenu_dist_linewidth, 'Value', value);

    %Refresh Legend and Plot
    update_plot(handles, 0, 1)
    ProbDistPlot('legend_refresh', hObject, eventdata, handles);

function checkbox_options_legend_Callback(hObject, eventdata, handles)
    global plotdata distdata selected_plot lang

    button = questdlg('Warning: This will reset your label inputs. Proceed?', 'ProbDistPlot');
    if strcmp(button, 'Yes')
    
        cInd = get([handles.checkbox_options_legendname, handles.checkbox_options_legendpdf, handles.checkbox_options_legendpara], 'Value');
        aInd = find([cInd{1:3}]);

        cParameters = {plotdata.parameters};
        aPlotNums = find(~cellfun(@isempty,cParameters));
        cParameters = {plotdata(aPlotNums).parameters};
        aPlotType = [plotdata(aPlotNums).type];

        for i=1:length(aPlotNums)
            cTitle = distdata(aPlotType(i)).title;
            paraTitle = '';
            aParameters = [cParameters{i}];
            %Re-make the parameter section to reflect the new values
            for j=1:length(aParameters)
                paraTitle = [paraTitle, ' ', distdata(aPlotType(i)).paraLegendName{j}, '=', num2str(aParameters(j))];
            end
            cTitle{3} = paraTitle; 

            sTitle = [cTitle{aInd}];
            if strcmp(lang, 'LaTex'); sTitle = Tex2Latex(sTitle, 1); end

            plotdata(aPlotNums(i)).title = sTitle ;
        end

        set(handles.edit_dist_plot_title, 'String', plotdata(selected_plot).title);

        legend_refresh(hObject, eventdata, handles);
    else
        value = get(hObject, 'Value')
        set(hObject, 'Value', ~value)       
    end;
    
    
function radiobutton_options_interp_Callback(hObject, eventdata, handles)
global lang plotdata selected_plot

%Ensure only one button is selected
oldlang = lang;
hButtons = [handles.radiobutton_options_latex, handles.radiobutton_options_tex, handles.radiobutton_options_none];
set(hButtons(find(hButtons~=hObject)), 'Value', 0)
set(hObject, 'Value', 1)
lang = get(hObject, 'String');

%Ask user if they want this program to convert the labels to the new
%language
if (strcmp(oldlang,'LaTex') & (strcmp(lang,'Tex') | strcmp(lang,'None')))
    button = questdlg('Do you want the labels convered to Tex/None?', 'ProbDistPlot');
    switch button
        case 'Yes'
            %Convert all Labels
            sXLabel = Latex2Tex(get(handles.edit_labels_xaxis, 'String'));
            set(handles.edit_labels_xaxis, 'String', sXLabel);
            sYLabel = Latex2Tex(get(handles.edit_labels_yaxis, 'String'));
            set(handles.edit_labels_yaxis, 'String', sYLabel);  
            sTitle = Latex2Tex(get(handles.edit_labels_title, 'String'));
            set(handles.edit_labels_title, 'String', sTitle); 
            
            %Convert all legend labels
            cTitles = {plotdata.title};
            aPlotNums = find(~cellfun(@strcmp,cTitles, repmat({' '},1,10)));
            cTitles = {plotdata(aPlotNums).title};
            for i=1:length(aPlotNums)
                plotdata(aPlotNums(i)).title = Latex2Tex(cTitles{i});
            end           
            
            set(handles.edit_dist_plot_title, 'String', plotdata(selected_plot).title);
            
        case 'No'
            
        otherwise
            hOld = findobj('String', oldlang);
            set(hOld, 'Value', 1);
            set(hObject, 'Value', 0);  
            lang = oldlang;
            return;
    end
    
elseif (strcmp(lang,'LaTex') & (strcmp(oldlang,'Tex') | strcmp(oldlang,'None')))
    button = questdlg('Do you want the labels convered to LaTex?', 'ProbDistPlot');
    switch button
        case 'Yes'
            %Convert all Labels
            sXLabel = Tex2Latex(get(handles.edit_labels_xaxis, 'String'), 1);
            set(handles.edit_labels_xaxis, 'String', sXLabel);
            sYLabel = Tex2Latex(get(handles.edit_labels_yaxis, 'String'), 1);
            set(handles.edit_labels_yaxis, 'String', sYLabel);  
            sTitle = Tex2Latex(get(handles.edit_labels_title, 'String'), 1);
            set(handles.edit_labels_title, 'String', sTitle); 
            
            %Convert all legend labels
            cTitles = {plotdata.title};
            aPlotNums = find(~cellfun(@strcmp,cTitles, repmat({' '},1,10)));
            cTitles = {plotdata(aPlotNums).title};
            for i=1:length(aPlotNums)
                plotdata(aPlotNums(i)).title = Tex2Latex(cTitles{i}, 1);
            end           
            
            set(handles.edit_dist_plot_title, 'String', plotdata(selected_plot).title);
            
        case 'No'
            
        otherwise
            hOld = findobj('String', oldlang);
            set(hOld, 'Value', 1);
            set(hObject, 'Value', 0);  
            lang = oldlang;
            return;
    end
    
end

%Set all axis labels to interpreter    
xlabel(handles.axis_main, get(handles.edit_labels_xaxis, 'String'), 'interpreter',lang)
ylabel(handles.axis_main, get(handles.edit_labels_yaxis, 'String'), 'interpreter',lang)
title(handles.axis_main, get(handles.edit_labels_title, 'String'), 'interpreter',lang)

%Set legend to interpreter
legend_refresh(hObject, eventdata, handles)



%-------------------- Repedative Functions ------------------------%

function update_plot (handles, plot_number, clear_axis)
    global plotdata

    set(gcf, 'CurrentAxes', handles.axis_main);
    
    res = get(handles.edit_options_PlotRes, 'Value');

    %Get XMin and XMax
    xMinMaxFixed = xlim(handles.axis_main);
    %If either axis box is not checked then auto limits need to be calculated
    %if (~get(handles.checkbox_fixXMax, 'Value') || ~(get(handles.checkbox_fixXMin, 'Value')) || plot_number<1 || plot_number>10)
    if get(handles.checkbox_axis_xautoscale, 'Value')        
        %If full replot then calculate all xMinMaxs.
        if clear_axis || plot_number<1 || plot_number>10
            
            cParameters = {plotdata.parameters};
            cParameters(cellfun(@isempty,cParameters)|~[plotdata.visible]) = [];
            if isempty(cParameters); cla; return; end; %If no plots need to be plotted then exit

            cMinMax = {plotdata.xMinMax};
            cMinMax(cellfun(@isempty,cMinMax)|~[plotdata.visible]) = []; %delete all cells which are empty or set to be invisible

            %Calculate each plots optimum plotting range Note these depend on the
            %parameters hence the loop.
            for i = 1:length(cMinMax)
                aMinMax(i,:)=cMinMax{i}(cParameters{i});
            end
            
            xMinMaxAuto = max(aMinMax, [], 1);
            
        %Update plot with auto adjust selected
        else
            fMinMax = plotdata(plot_number).xMinMax;
            aParameters = plotdata(plot_number).parameters;
            xMinMaxAuto = fMinMax(aParameters);
            %Now see if this is more or less than previous xMinMax Value
            xMinMaxAuto(1) = min([xMinMaxAuto(1), xMinMaxFixed(1)]);
            xMinMaxAuto(2) = max([xMinMaxAuto(2), xMinMaxFixed(2)]);
        end
      
     xMinMax = xMinMaxAuto;
        
    %Otherwise auto adjusting not needed so use existing limits
    else
        xMinMax = xMinMaxFixed;
    end
    
    xlim(xMinMax);
    
    %Plot / Replot Lines
    x =  xMinMax(1):(xMinMax(2)-xMinMax(1))/res:xMinMax(2);

    yMinMaxFixed = ylim(handles.axis_main);
    
    if ~clear_axis % then only replot the single line
       yMinMaxAuto = yMinMaxFixed;
        
        try
        aParameters = plotdata(plot_number).parameters;      %Get Plot Parameters
        y = plotdata(plot_number).function(x, aParameters);  %Calculate y values
        yMinMaxAuto(1) = min([y, yMinMaxAuto(1)]);
        yMinMaxAuto(2) = max([y, yMinMaxAuto(2)]);
        
        %If a previous plot exists for this plot then delete it first
        if ~(plotdata(plot_number).line_handle==0), delete(plotdata(plot_number).line_handle), end

        %Make new plot
        plotdata(plot_number).line_handle = line(x, y, ...
                                                 'color', plotdata(plot_number).line_color,...
                                                 'linewidth', plotdata(plot_number).line_width, ...
                                                 'linestyle', plotdata(plot_number).line_style);   %handles.axis_main,
       catch
            disp('Error in update_plot');
       end
    else %replot all functions
        yMinMaxAuto = [inf, 0];
        %Delete all lines
        cla;

        %Get Plot Data
        cParameters = {plotdata.parameters};
        aPlotNums = find(not(cellfun(@isempty,cParameters)|~[plotdata.visible]));
        cParameters(cellfun(@isempty,cParameters)|~[plotdata.visible]) = [];
        if isempty(cParameters); return; end; %If no plots need to be plotted then exit

        %Replot all plots
        for i = 1:length(aPlotNums)
            try
                parameters = cParameters{i};
                y = plotdata(aPlotNums(i)).function(x, parameters);
                set(gcf, 'CurrentAxes', handles.axis_main);
                plotdata(aPlotNums(i)).line_handle = line(x, y, ...
                                                 'color', plotdata(aPlotNums(i)).line_color,...
                                                 'linewidth', plotdata(aPlotNums(i)).line_width, ...
                                                 'linestyle', plotdata(aPlotNums(i)).line_style); 
                yMinMaxAuto(1) = min([y, yMinMaxAuto(1)]);
                yMinMaxAuto(2) = max([y, yMinMaxAuto(2)]);
            catch
                disp('Error in replot all - update_plot');
            end
        end
        
       
    end  

%     %Calculate limits based on fixed and auto
%     if get(handles.checkbox_fixYMin, 'Value')
%         yMinMax(1) = yMinMaxFixed(1);
%     else
%         yMinMax(1) = yMinMaxAuto(1);
%     end
% 
%     if get(handles.checkbox_fixYMax, 'Value')
%         yMinMax(2) = yMinMaxFixed(2);
%     else
%         yMinMax(2) = yMinMaxAuto(2);
%     end
    if get(handles.checkbox_axis_yautoscale, 'Value')
        yMinMaxAuto(2) = 1.01.*yMinMaxAuto(2); %Add 1% to Ymax to see the top of the plot
        yMinMax = yMinMaxAuto;
    else
        yMinMax = yMinMaxFixed;
    end  
    
    if yMinMax(1)==yMinMax(2), yMinMax(1)=yMinMax(1)-0.1; end
    
    ylim(yMinMax);
    
    %Update axis edit boxes
    set(handles.edit_ymin, 'Value', yMinMax(1), 'String', yMinMax(1));
    set(handles.edit_ymax, 'Value', yMinMax(2), 'String', yMinMax(2));
    set(handles.edit_xmin, 'Value', xMinMax(1), 'String', xMinMax(1));
    set(handles.edit_xmax, 'Value', xMinMax(2), 'String', xMinMax(2)); 

function legend_refresh(hObject, eventdata, handles)

    global plotdata lang
    
    legend_handle = legend;
    
    %Draw invisible legend so properties get updated despite it not
    %existing to the user
    if isempty(legend_handle)
        hlegend = legend('show', 'Location','NorthWest');
        set(hlegend, 'Visible', 'off')
        %Set properties which are default to the uicontrols for the label
        popupmenu_legend_boxcolor_Callback(handles.popupmenu_legend_boxcolor, eventdata, handles)
        popupmenu_legend_backcolor_Callback(handles.popupmenu_legend_backcolor, eventdata, handles)
        popupmenu_legend_txtcolor_Callback(handles.popupmenu_legend_txtcolor, eventdata, handles)
    end
    
    %If the use has selected to display the legend and selected a table
    if get(handles.checkbox_legend_display, 'value') & get(handles.radiobutton_legend_table, 'value')
        %Creates masks of valid entries
        cell_titles = {plotdata.title};
        exist_mask = ~strcmp(cell_titles, repmat({' '}, 1, 10));

        %Creates masks of visible plots
        legend_mask = [plotdata.visible];

        %Create Display Arrays
        display_mask = exist_mask.*legend_mask;
        if sum(display_mask) == 0; set(legend_handle, 'Visible', 'off'); return; end;
        
        concate_titles = cell_titles(find(display_mask));       
        hlines = [plotdata.line_handle];
        concate_hlines = hlines(find(display_mask));

        %Save legend properties
        legend_PropString = {'Position', 'TextColor', 'EdgeColor', 'Box', 'Color'};
        legend_Prop = get(legend_handle, legend_PropString);
        legend_PropString{6} = 'interpreter';
        legend_Prop{6} = lang;
                
        %Draw Legend
        legend_handle = legend(concate_hlines, concate_titles);
        
        %Reset Properties
        set(legend_handle, legend_PropString(2:6), legend_Prop(2:6));
        
        %Alows for re-sizing but keeps the old position
        new_position = get(legend_handle, 'Position');
        Axes_Size = get(handles.axis_main, 'Position');
        new_position(1) = min([max([legend_Prop{1}(1), Axes_Size(1)]), Axes_Size(1)+Axes_Size(3)-new_position(3)]); % between left and right of axes
        new_position(2) = min([max([legend_Prop{1}(2), Axes_Size(2)]), Axes_Size(2)+Axes_Size(4)-new_position(4)]); % between top and bottom of axes        
        set(legend_handle, 'Position', new_position)
        
    else
        set(legend_handle, 'Visible', 'off');
    end

function varargout = dsxy2figxy(varargin)
    % dsxy2figxy -- Transform point or position from axis to figure coords
    % Transforms [axx axy] or [xypos] from axes hAx (data) coords into coords
    % wrt GCF for placing annotation objects that use figure coords into data
    % space. The annotation objects this can be used for are
    %    arrow, doublearrow, textarrow
    %    ellipses (coordinates must be transformed to [x, y, width, height])
    % Note that line, text, and rectangle anno objects already are placed
    % on a plot using axes coordinates and must be located within an axes.
    % Usage: Compute a position and apply to an annotation, e.g.,
    %   [axx axy] = ginput(2);
    %   [figx figy] = getaxannopos(gca, axx, axy);
    %   har = annotation('textarrow',figx,figy);
    %   set(har,'String',['(' num2str(axx(2)) ',' num2str(axy(2)) ')'])


    % Obtain arguments (only limited argument checking is performed).
    % Determine if axes handle is specified


    % Determine if axes handle is specified
    if length(varargin{1})== 1 && ishandle(varargin{1}) && ...
      strcmp(get(varargin{1},'type'),'axes') 
     hAx = varargin{1};
     varargin = varargin(2:end);
    else
     hAx = gca;
    end;
    % Parse either a position vector or two 2-D point tuples
    if length(varargin)==1 % Must be a 4-element POS vector
     pos = varargin{1};
    else
     [x,y] = deal(varargin{:});  % Two tuples (start & end points)
    end
    % Get limits
    axun = get(hAx,'Units');
    set(hAx,'Units','normalized');  % Need normaized units to do the xform
    axpos = get(hAx,'Position');
    axlim = axis(hAx);              % Get the axis limits [xlim ylim (zlim)]
    axwidth = diff(axlim(1:2));
    axheight = diff(axlim(3:4));
    % Transform data from figure space to data space
    if exist('x','var')     % Transform a and return pair of points
     varargout{1} = (x-axlim(1))*axpos(3)/axwidth + axpos(1);
     varargout{2} = (y-axlim(3))*axpos(4)/axheight + axpos(2);
    else                    % Transform and return a position rectangle
     pos(1) = (pos(1)-axlim(1))/axwidth*axpos(3) + axpos(1);
     pos(2) = (pos(2)-axlim(3))/axheight*axpos(4) + axpos(2);
     pos(3) = pos(3)*axpos(3)/axwidth;
     pos(4) = pos(4)*axpos(4)/axheight;
     varargout{1} = pos;
    end
    % Restore axes units
    set(hAx,'Units',axun)

function varargout = pix2norm(varargin)
    %Convert the input from pixels to a normalised for given figure
    %input can either be x and y vectors or a position vector
    %eg. [NormX NormY] = pix2norm(gcf, PixX, PixY)
    %eg. Position_Nom = pix2norm(get(gca, 'Position')

    % Determine if figure handle is specified
    if length(varargin{1})== 1 && ishandle(varargin{1}) && ...
      strcmp(get(varargin{1},'type'),'figure') 
     hFig = varargin{1};
     varargin = varargin(2:end);
    else
     hFig = gcf;
    end;
    % Parse either a position vector or two 2-D point tuples
    if length(varargin)==1 % Must be a 4-element POS vector
     pos = varargin{1};
    else
     [x,y] = deal(varargin{:});  % Two tuples (start & end points)
    end
    % Get figure limits
    figunits = get(hFig,'Units');
    set(hFig,'Units','pixels');  
    figpos = get(hFig,'Position');

    % Transform data from figure space to data space
    if exist('x','var')     % Transform a and return pair of points
     varargout{1} = x / figpos(3);
     varargout{2} = y / figpos(4);
    else                    % Transform and return a position rectangle
     pos(1) = pos(1)/ figpos(3);
     pos(2) = pos(2)/ figpos(4);
     pos(3) = pos(3)/ figpos(3);
     pos(4) = pos(4)/ figpos(4);
     varargout{1} = pos;
    end
    % Restore axes units
    set(hFig,'Units',figunits)

function successful = update_label(strhandle, selected_plot, para, value)

    global plotdata

    sLabel = get(strhandle, 'String');

    if isnumeric(value)  %If value is a number search for para string and replace number

        %Add space before string
        para = [' ' para];

        %Find all matches
        ind = strfind(sLabel, para);
        ind = ind+length(para)-1; %adjustment to ref para

        %If there is a space after the para then take it out
        ind(find(ind+1 > length(sLabel)))=[];
        for i=1:length(ind)
            if isspace(sLabel(ind(i)+1)), ind(i) = ind(i)+1;end

            ind(find(ind+1 > length(sLabel)))=[];
            if (sLabel(ind(i)+1) == ':') | (sLabel(ind(i)+1) == '-') | (sLabel(ind(i)+1) == '='), ind(i) = ind(i)+1; end

            ind(find(ind+1 > length(sLabel)))=[];
            if isspace(sLabel(ind(i)+1)), ind(i) = ind(i)+1;end
        end

        %If the next indicies contains a number then it is a valid find
        ind(find(ind+1 > length(sLabel)))=[];
        ind(find(~isstrprop(sLabel(ind+1), 'digit'))) = [];
        ind = ind + 1;

        if length(ind)==1
            ind_start = ind;
            %Find length of number
            while isstrprop(sLabel(ind), 'digit') | sLabel(ind)=='.'
                ind = ind + 1;
                if ind > length(sLabel), break, end
            end
            ind_end = ind -1;

            %Replace existing number with new number
            if ind_end == length(sLabel)
                sLabel = [sLabel(1:ind_start-1) num2str(value)];
            else
                sLabel = [sLabel(1:ind_start-1) num2str(value) sLabel(ind_end+1:length(sLabel))];
            end
            successful = 1;

        else
            successful = 0;
        end

    else%   %When value is a string do a search and replace
        para = [' ' para ' '];
        value = [' ' value ' '];

        sLabel = strrep(sLabel, upper(para), upper(value));
        sLabel = strrep(sLabel, lower(para), lower(value));       

        successful = 2;
    end

    set(strhandle, 'String', sLabel)
    plotdata(selected_plot).title = sLabel;
    handles = guidata(gcf);
    legend_refresh([], [], handles);

function sUnicode = Tex2Unicode(TexStr)

    TexStr = regexprep(TexStr, '\\alpha', char(945));
    TexStr = regexprep(TexStr, '\\beta', char(946));
    TexStr = regexprep(TexStr, '\\gamma', char(947));
    TexStr = regexprep(TexStr, '\\delta', char(948));
    TexStr = regexprep(TexStr, '\\epsilon', char(949));
    TexStr = regexprep(TexStr, '\\zeta', char(950));
    TexStr = regexprep(TexStr, '\\eta', char(951));
    TexStr = regexprep(TexStr, '\\theta', char(952));
    TexStr = regexprep(TexStr, '\\vartheta', char(977));
    TexStr = regexprep(TexStr, '\\iota', char(953));
    TexStr = regexprep(TexStr, '\\kappa', char(954));
    TexStr = regexprep(TexStr, '\\lambda', char(955));
    TexStr = regexprep(TexStr, '\\mu', char(956));
    TexStr = regexprep(TexStr, '\\nu', char(957));
    TexStr = regexprep(TexStr, '\\xi', char(958));
    TexStr = regexprep(TexStr, '\\pi', char(960));
    TexStr = regexprep(TexStr, '\\rho', char(961));
    TexStr = regexprep(TexStr, '\\sigma', char(963)); 
    TexStr = regexprep(TexStr, '\\varsigma', char(962));
    TexStr = regexprep(TexStr, '\\tau', char(964));
    TexStr = regexprep(TexStr, '\\equiv', char(8801));
    %TexStr = regexprep(TexStr, '\\Im', char(946));
    TexStr = regexprep(TexStr, '\\otimes', char(8855));
    TexStr = regexprep(TexStr, '\\cap', char(8745));
    TexStr = regexprep(TexStr, '\\supset', char(8835));
    TexStr = regexprep(TexStr, '\\int', char(8747));
    TexStr = regexprep(TexStr, '\\rfloor', char(1105));
    TexStr = regexprep(TexStr, '\\lfloor', char(251));
    TexStr = regexprep(TexStr, '\\perp', char(8869));
    TexStr = regexprep(TexStr, '\\wedge', char(8743));
    TexStr = regexprep(TexStr, '\\rceil', char(249));
    TexStr = regexprep(TexStr, '\\vee', char(8744));
    TexStr = regexprep(TexStr, '\\langle', char(9001));
    TexStr = regexprep(TexStr, '\\upsilon', char(965));
    TexStr = regexprep(TexStr, '\\phi', char(966));
    TexStr = regexprep(TexStr, '\\chi', char(967));
    TexStr = regexprep(TexStr, '\\psi', char(968));
    TexStr = regexprep(TexStr, '\\omega', char(969));
    TexStr = regexprep(TexStr, '\\Gamma', char(915));
    TexStr = regexprep(TexStr, '\\Delta', char(916));
    TexStr = regexprep(TexStr, '\\Theta', char(920));
    TexStr = regexprep(TexStr, '\\Lambda', char(923));
    TexStr = regexprep(TexStr, '\\Xi', char(926));
    TexStr = regexprep(TexStr, '\\Pi', char(928));
    TexStr = regexprep(TexStr, '\\Sigma', char(931));
    TexStr = regexprep(TexStr, '\\Upsilon', char(933));
    TexStr = regexprep(TexStr, '\\Phi', char(934));
    TexStr = regexprep(TexStr, '\\Omega', char(937));
    TexStr = regexprep(TexStr, '\\forall', char(8704));
    TexStr = regexprep(TexStr, '\\exists', char(8707));
%    TexStr = regexprep(TexStr, '\\ni', char(946));
    TexStr = regexprep(TexStr, '\\cong', char(8773));
    TexStr = regexprep(TexStr, '\\approx', char(8776));
    TexStr = regexprep(TexStr, '\\Re', char(8476));
    TexStr = regexprep(TexStr, '\\oplus', char(8853));
    TexStr = regexprep(TexStr, '\\cup', char(8746));
    TexStr = regexprep(TexStr, '\\subseteq', char(8838));
    TexStr = regexprep(TexStr, '\\in', char(8712));
    TexStr = regexprep(TexStr, '\\lceil', char(233));
    TexStr = regexprep(TexStr, '\\cdot', char(8901));
%    TexStr = regexprep(TexStr, '\\neg', char(946));
    TexStr = regexprep(TexStr, '\\times', char(8727));
    TexStr = regexprep(TexStr, '\\surd', char(8737));
    TexStr = regexprep(TexStr, '\\varpi', char(982));
    TexStr = regexprep(TexStr, '\\rangle', char(9002));
    TexStr = regexprep(TexStr, '\\sim', char(8764));
    TexStr = regexprep(TexStr, '\\leq', char(8804));
    TexStr = regexprep(TexStr, '\\infty', char(8734));
%    TexStr = regexprep(TexStr, '\\clubsuit', char(946));
%    TexStr = regexprep(TexStr, '\\diamondsuit', char(946));
%    TexStr = regexprep(TexStr, '\\heartsuit', char(946));
%    TexStr = regexprep(TexStr, '\\spadesuit', char(946));
    TexStr = regexprep(TexStr, '\\leftrightarrow', char(8596));
    TexStr = regexprep(TexStr, '\\leftarrow', char(8592));
    TexStr = regexprep(TexStr, '\\uparrow', char(8593));
    TexStr = regexprep(TexStr, '\\rightarrow', char(8594));
    TexStr = regexprep(TexStr, '\\downarrow', char(8595));
    TexStr = regexprep(TexStr, '\\circ', char(8728));
    TexStr = regexprep(TexStr, '\\pm', char(177));
    TexStr = regexprep(TexStr, '\\geq', char(8805));
    TexStr = regexprep(TexStr, '\\propto', char(8733));
    TexStr = regexprep(TexStr, '\\partial', char(8706));
    TexStr = regexprep(TexStr, '\\bullet', char(8729));
    TexStr = regexprep(TexStr, '\\div', char(8725));
    TexStr = regexprep(TexStr, '\\neq', char(8800));
    TexStr = regexprep(TexStr, '\\aleph', char(1008));
%    TexStr = regexprep(TexStr, '\\wp', char(946));
    TexStr = regexprep(TexStr, '\\oslash', char(8709));
    TexStr = regexprep(TexStr, '\\supseteq', char(8839));
    TexStr = regexprep(TexStr, '\\subset', char(8834));
    TexStr = regexprep(TexStr, '\\o', char(8728));
    TexStr = regexprep(TexStr, '\\nabla', char(8711));
    TexStr = regexprep(TexStr, '\\ldots', char(8943));
    TexStr = regexprep(TexStr, '\\prime', char(8242));
    TexStr = regexprep(TexStr, '\\0', char(8709));
    TexStr = regexprep(TexStr, '\\mid', char(8739));
    TexStr = regexprep(TexStr, '\\copyright', char(169));
    
    sUnicode = TexStr;

function default_CreateFcn(hObject, eventdata, handles)
% Set edit controls to white background on Windows.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function sTex = Latex2Tex(sLatex)
%Remove all dollar signs
sLatex = regexprep(sLatex, '[$]', '');

%Removal all space symbols with actual spaces
sLatex = regexprep(sLatex, ' \\ ', ' ');  sLatex = regexprep(sLatex, '\\ ', ' ');
sLatex = regexprep(sLatex, ' \\: ', ' '); sLatex = regexprep(sLatex, '\\: ', ' '); sLatex = regexprep(sLatex, '\\:', ' ');
sLatex = regexprep(sLatex, ' \\; ', ' '); sLatex = regexprep(sLatex, '\\; ', ' '); sLatex = regexprep(sLatex, '\\;', ' ');
sLatex = regexprep(sLatex, ' \\, ', ' '); sLatex = regexprep(sLatex, '\\, ', ' '); sLatex = regexprep(sLatex, '\\,', ' ');

sTex = sLatex;

function sLatex = Tex2Latex(sTex, bInline)
%Put dollar signs at the start and end of the string
if bInline
    sTex = ['$', sTex, '$'];
else
    sTex = ['$$', sTex, '$$'];
end

%Replace spaces with Latex Spaces
sTex = strrep(sTex, ' ', '\ ');

sLatex = sTex;





% function PosOut = inaxes(hAxes, PosIn)
% % Takes pixel values for PosIn and makes sure the whole box is drawn inside the    
% new_position = get(legend_handle, 'Position');
% Axes_Size = get(handles.axis_main, 'Position');
% new_position(1) = min([max([legend_Prop{1}(1), Axes_Size(1)]), Axes_Size(1)+Axes_Size(3)-new_position(3)]); % between left and right of axes
% new_position(2) = min([max([legend_Prop{1}(2), Axes_Size(2)]), Axes_Size(2)+Axes_Size(4)-new_position(4)]); % between top and bottom of axes        
% set(legend_handle, 'Position', new_position)


%%%%%%%%%%%%%%%   TO DELETE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%


%These need finding and deleting from the GUIDE fig file, I can't find it
function popupmenu_legend_textcolor_CreateFcn(hObject, eventdata, handles)
% Set edit controls to white background on Windows.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenu_axis_gridstyle_CreateFcn(hObject, eventdata, handles)
% Set edit controls to white background on Windows.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


