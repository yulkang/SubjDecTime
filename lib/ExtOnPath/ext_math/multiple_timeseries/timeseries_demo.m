% function timeseries_demo
% Multiple TimeSeriesDemo alá JFreeGraph-Demo
%
% The code behind is just a demo of what is possible with JFreeChart using it in Matlab. I played a little
% with codesnippets I found on the web and the API-Documentation
% (http://www.jfree.org/jfreechart/api/javadoc/index.html). When  you want to explore the whole functionality,
% I think it is better to buy the JFreeChart Developer Guide (http://www.jfree.org/jfreechart/devguide.html). 
%
% This function shows a multiple TimeSeries as an example of JFreeChart (http://www.jfree.org/). The Idea
% to this code is based on the UndocumentedMatlab-Blog of Yair Altman, who shows a sampleCode of JFreeChart
% for creating a PieChart (http://undocumentedmatlab.com/blog/jfreechart-graphs-and-gauges/#comments)
%
% Within the plot you can zoom by pressing the left mouse button and moving the pointer. Also you have some
% properties by right-clicking on the chart.   
%
% Before this demo works, you need to download JFreeChart and make matlab get to know with it. There are 2
% ways you can do this:
%
% 1. Add the jcommon and jfreechart jar to the dynamic matlab JavaClassPath (uncommented lines in the first
%    cell an change path to your local installation path
% 2. Add the jcommon and jfreechart jar to the static matlab JavaClassPath (see Matlab Help, modify
%    classpath.txt on matlabroot\toolbox\local) 
%
% Finally you must donwload jcontrol from Malcom Lidierth
% (http://www.mathworks.com/matlabcentral/fileexchange/15580-using-java-swing-components-in-matlab).
% 
%
% Bugs and suggestions:
%    Please send to Sven Koerner: koerner(underline)sven(add)gmx.de
% 
% You need to download and install first:
%    http://sourceforge.net/projects/jfreechart/files/1.%20JFreeChart/1.0.13/ 
%    http://sourceforge.net/projects/jfreechart/files/1.%20JFreeChart/1.0.9/
%    http://www.mathworks.com/matlabcentral/fileexchange/15580-using-java-swing-components-in-matlab 
%
%
% Programmed by Sven Koerner: koerner(underline)sven(add)gmx.de
% Date: 2011/02/14 



%%  JFreeChart to matlab
%  Add the JavaPackages to the static javaclasspath (see Matlab Help, modify classpath.txt on
%  matlabroot\toolbox\local) or alternativ turn it to the dynamic path (uncomment the next and change path to jFreeeChart) 

% javaaddpath C:/Users/sk/Documents/MATLAB/jfreechart-1.0.13/lib/jcommon-1.0.16.jar
% javaaddpath C:/Users/sk/Documents/MATLAB/jfreechart-1.0.13/lib/jfreechart-1.0.13.jar


%% Start
dataset1 = createDataset('1. TSeries', 100, org.jfree.data.time.Day(java.util.Date), 200 );

% generate chart and edit chart settings
chart = org.jfree.chart.ChartFactory.createTimeSeriesChart('Multiple Axis Demo 1', 'Time of Day', 'Primary Range Axis', dataset1, true, true, false);
background_color = chart.getBackgroundPaint;
chart.setBackgroundPaint(background_color.white); 

% plot object of chart editing
plot_obj = chart.getXYPlot();
plot_obj.setOrientation(org.jfree.chart.plot.PlotOrientation.VERTICAL);
plot_obj.setBackgroundPaint(background_color.lightGray);
plot_obj.setDomainGridlinePaint(background_color.white);
plot_obj.setRangeGridlinePaint(background_color.white);
%axis_spacer = plot_obj.getAxisOffset;
plot_obj.setAxisOffset(org.jfree.ui.RectangleInsets(5,5,5,5));
plot_obj.getRangeAxis().setFixedDimension(15.0);
Standard_renderer = org.jfree.chart.renderer.xy.XYLineAndShapeRenderer(true, false);
Standard_renderer.setSeriesPaint(0, background_color.black);
renderer          = plot_obj.getRenderer;
% renderer          = plot_obj.getRenderer;
renderer.setPaint(background_color.black);
%plot_obj.setRenderer(0, Standard_renderer);

%% AXIS 2 
axis2 = org.jfree.chart.axis.NumberAxis('Range Axis 2');
axis2.setAutoRangeIncludesZero(false);
axis2.setLabelPaint(java.awt.Color(255/255,0,0));
axis2.setTickLabelPaint(background_color.red);
plot_obj.setRangeAxis(1, axis2);
plot_obj.setRangeAxisLocation(1, org.jfree.chart.axis.AxisLocation.BOTTOM_OR_LEFT);
% create new Dataset
dataset2 = createDataset('2. TSeries', 1000, org.jfree.data.time.Day, 170 );
plot_obj.setDataset(1, dataset2); 
plot_obj.mapDatasetToRangeAxis(1,1);
renderer2 = org.jfree.chart.renderer.xy.XYLineAndShapeRenderer(true, false);
renderer2.setSeriesPaint(0, background_color.red);
plot_obj.setRenderer(1, renderer2);

%% AXIS 3 
axis3 = org.jfree.chart.axis.NumberAxis('Range Axis 3');
axis3.setLabelPaint(java.awt.Color(0,0,255/255));
axis3.setTickLabelPaint(background_color.blue);
plot_obj.setRangeAxis(2, axis3);
% create new Dataset
dataset3 = createDataset('3. TSeries', 10000, org.jfree.data.time.Day, 170 );
plot_obj.setDataset(2, dataset3);
plot_obj.mapDatasetToRangeAxis(2,2);
renderer3 = org.jfree.chart.renderer.xy.XYLineAndShapeRenderer(true, false);
renderer3.setSeriesPaint(0, background_color.blue);
plot_obj.setRenderer(2, renderer3);

%% AXIS 4
axis4 = org.jfree.chart.axis.NumberAxis('Range Axis 4');
axis4.setLabelPaint(java.awt.Color(0,255/255,0));
axis4.setTickLabelPaint(background_color.green);
plot_obj.setRangeAxis(3, axis4);
% create new Dataset
dataset4 = createDataset('4. TSeries', 25, org.jfree.data.time.Day, 200 );
plot_obj.setDataset(3, dataset4);
plot_obj.mapDatasetToRangeAxis(3,3);
renderer4 = org.jfree.chart.renderer.xy.XYLineAndShapeRenderer(true, true);   % Line and Marker
renderer4.setSeriesPaint(0, background_color.green);
plot_obj.setRenderer(3, renderer4);

%% Show graph
jPanel2 = org.jfree.chart.ChartPanel(chart);                         % create new panel
fh = figure('Units','normalized','position',[0.1,0.1,  0.7,  0.7]);  % create new figure
jp = jcontrol(fh, jPanel2,'Position',[0.01 0.01 0.98 0.98]);         % add the jPanel to figure


