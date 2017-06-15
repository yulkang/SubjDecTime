clearPsyLog;

useEye = true;

%% Scr & Eye
Scr = PsyScr;
Scr.initSaveOpt('pathPostfix', '_test', ...
                'filePostfix', '_test')
Scr.saveDiary;
Scr.init('scr', 0, 'maxSec', 10)
Scr.open;

if useEye
    Eye = PsyEye(Scr)
    Scr.addObj('Inp', Eye)
end

%% Visual stimuli
FP = PsyPTB(Scr, 'FillCircle', [255 255 255]', ...
                 [0 0; -6 6; 6 6; -6 -6; 6 -6]', 0.5);
Scr.addObj('Vis', FP);

% Targ = PsyTargFlick(Scr)
% Targ.init('n', 4, 'angleRad', 3/4*pi, 'sortOrder', 'likeText', ...
%     'colorIn',  [100 100 0; 100 100 0; 0 100 100; 0 100 100]', ...
%     'colorOut', [ 30  30 0;  30  30 0; 0  30  30; 0  30  30]', ...
%     'holdSec', tHoldTargFor, 'eccenDeg', 6, 'sizeDeg', 3, 'answerRDeg', 0.7, ...
%     'commPsy', 'FrameCircle', 'penWidthDeg', 0.1);
% 
% Home            = PsyHover(Scr);
% init(Home, 'n', 1, 'eccenDeg', 0, 'sizeDeg', 0.3, ... 12, ...
%            'colorIn',  [155 155 155]', ...
%            'colorOut', [100 100 100]', ...
%            'holdSec', 0);

%%
if useEye
    Eye.initEL
    Eye.calibEL
    Eye.activate;
end

%%
Scr.initLogTrial

%%
FP.show;
Scr.wait('test', @() false, 'for', 5, 'sec')
FP.hide;

%%
Scr.closeLog

%%
if useEye
    Eye.deactivate;
    Eye.closeEL
end

%%
Scr.close

%%
saveWorkspace
diary off