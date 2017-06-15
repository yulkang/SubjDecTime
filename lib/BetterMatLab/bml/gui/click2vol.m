sim_mode = inputYN_def('Simulation mode', false);

if ~sim_mode
    device_id = 0;
    hw_chn = [0 2];
    
    ao = analogoutput('mcc', device_id);
    ao_chn = addchannel(ao, hw_chn);
    
    dio = digitalio('mcc', device_id);
    dio_chn = addline(dio, 0, 'Out');
end

xTick = 10;
yTick = 10;
xMinorTick = 2.5;
yMinorTick = 2.5;
xLim  = [-50, 50];
yLim  = [-50, 50];

deg2vol = 1/10;

fig_tag('Click2Vol'); clf;
hAx = gca;
xlim([-50 50]);
ylim([-50 50]);
axis square;
grid on;
set(hAx, 'XTick', xLim(1):xTick:xLim(2));
set(hAx, 'YTick', yLim(1):yTick:yLim(2));
% set(hAx, 'XMinorTick', 'on'); % xLim(1):xMinorTick:xLim(2));
% set(hAx, 'YMinorTick', 'on'); % yLim(1):yMinorTick:yLim(2));

x = 0;
y = 0;
line(xLim, [0 0], 'Color', 'k');
line([0 0], yLim, [0 0], 'Color', 'k');
hLine = line(x*10, y*10, 'Marker', 'o', 'Color', 'b');
xlabel('x (deg)');
ylabel('y (deg)');

while ishandle(hAx)
    axes(hAx); %#ok<LAXES>
    title(sprintf('x:%+1.1f, y:%+1.1f', x, y));
    set(hLine, 'XData', x, 'YData', y);
    drawnow;
    
    try
        [x, y] = ginput(1);
    catch
        break;
    end
    
    x = round(x / xMinorTick) * xMinorTick;
    y = round(y / yMinorTick) * yMinorTick;
    
    x = min(max(x, -50), 50);
    y = min(max(y, -50), 50);    
    
    if ~sim_mode
        putdata(ao, [x, y]./10);
        start(ao);
        
        putvalue(dio, true);
        pause(0.01);
        putvalue(dio, false); 
        pause(0.01);
    end
end

if ~sim_mode
    delete(ao);
    clear ao;
    
    delete(dio);
    clear dio;
end