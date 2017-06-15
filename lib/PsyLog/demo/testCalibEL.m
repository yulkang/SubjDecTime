%% Plot x,y against pupil
load(['/Users/yulkang/Dropbox/0_work/Shadlen/PsyLog/test/testPsyEyeHover_test/orig/' ...
      'testPsyEyeHover_test_20130225T105239.mat']);

%%
pup   = Eye.v('pupil');
xyDeg = Eye.v('xyDeg');

sm = @(v) smooth(v, 21, 'rloess');

pup        = sm(pup);
xyDeg(1,:) = sm(xyDeg(1,:));
xyDeg(2,:) = sm(xyDeg(2,:));

dPup        = sm(diff(pup));
dXyDeg(1,:) = sm(diff(xyDeg(1,:)));
dXyDeg(2,:) = sm(diff(xyDeg(2,:)));

ddPup        = sm(diff(dPup));
ddXyDeg(1,:) = sm(diff(dXyDeg(1,:)));
ddXyDeg(2,:) = sm(diff(dXyDeg(2,:)));

%%
for iPlot = 1:2
    subplot(3,2,iPlot); hold off;
    plot(pup, xyDeg(iPlot,:), '.-');
    
    xlim([-100 4000]);
    ylim([-10 25]);
end

for iPlot = 1:2
    subplot(3,2,2+iPlot); hold off;
    plot(dPup, dXyDeg(iPlot,:), '.');
    
    crossLine('v', 0, 'k-');
    crossLine('h', 0, 'k-');
    
%     xlim([-200 200]);
%     ylim([-2 2]);
end

for iPlot = 1:2
    subplot(3,2,4+iPlot); hold off;
    plot(ddPup, ddXyDeg(iPlot,:), '.');
    
    crossLine('v', 0, 'k-');
    crossLine('h', 0, 'k-');
    
%     xlim([-200 200]);
%     ylim([-2 2]);
end

%% Algorithm
%  When x and y are changing slowly, cancel the movement with pupil.
%  Think about how to do this online.
