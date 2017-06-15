clearPsyLog;

%%
maxSec = 3;
useEye = true;
tHoldTargFor = 0.01;

if useEye
    inpMode = 'Eye';
else
    inpMode = 'Mouse';
end

%% Scr
Scr = PsyScr;
Scr.initSaveOpt('pathPostfix', '_test', ...
                'filePostfix', '_test')

commPreRun = input('Prerun comment: ', 's');
Scr.saveDiary(commPreRun);
Scr.saveDep;

% VMaster
% H-Center 33.9, H-Size 61 (33.9cm), V-Center 39, V-Size 51 (25.4cm), 
% Zoom 61, Pincushion 32, Trapezoid 52, Pin-Balance 47,
% Parallelogram 52, Rotation 50, Contrast 100, Brightness 50
% 1400 x 1050, 60 Hz.
% User Color R 78, B 64
Scr.init('scr', 0, 'distCm', 54, 'refreshRate', 60, 'widthCm', 33.9, ...
         'hideCursor', true, 'maxSec', maxSec, 'bkgColor', [0 0 0]); 
     
Scr.open;

%% Input devices
if useEye
    Eye = PsyEye(Scr);
    Scr.addObj('Inp', Eye);
else
    Mouse = PsyMouse(Scr);
    Scr.addObj('Inp', Mouse);
end

Key = PsyKey(Scr,  {'escape', 'space'}, ...
            'freq', Scr.info.refreshRate, ...
            'highFreq', Scr.info.refreshRate, ...
            'lowFreq',  0, ...
            'maxSecAtHighFreq', maxSec, ...
            'maxSecAtLowFreq' , maxSec);
Scr.addObj('Inp', Key);

%% Visual stimuli
% FP = PsyPTB(Scr, 'FillCircle', [255 255 255]', ...
%                  [0 0; -6 6; 6 6; -6 -6; 6 -6]', 0.5);
% Scr.addObj('Vis', FP);

Targ = PsyHover(Scr, 'inpMode', inpMode);
Targ.init('n', 4, 'angleRad', 3/4*pi, 'sortOrder', 'likeText', ...
    'colorIn',  [100 100 0; 100 100 0; 0 100 100; 0 100 100]', ...
    'colorOut', [ 30  30 0;  30  30 0; 0  30  30; 0  30  30]', ...
    'holdSec', tHoldTargFor, 'eccenDeg', 6, ...
    'sizeDeg', 0.3, 'answerRDeg', 0.7, ...
    'sensRDeg', 2.7, ...
    'commPsy', 'FrameCircle', 'penWidthDeg', 0.2);

Home = PsyHover(Scr, 'inpMode', inpMode);
Home.init('n', 1, 'eccenDeg', 0, 'sizeDeg', 0.3, ... 12, ...
           'sensRDeg', 2.7, ...
           'colorIn',  [155 155 155]', ...
           'colorOut', [100 100 100]', ...
           'holdSec', 0, ...
           'commPsy', 'FrameCircle', 'penWidthDeg', 0.2);

Cursor = PsyCursor(Scr, [], [], inpMode);

Scr.addObj('Vis', Home, Targ, Cursor);

%%
if useEye
    Eye.initEL;
    Eye.calibEL;
end

Scr.c.(inpMode).activate;
Scr.c.Key.activate;

%%
close all;
tic;
for iTrial = 1:2
    if iTrial > 1
        Eye.calibEL('targ');
    end
    
    Scr.initSaveOpt;
    Scr.initLogTrial;
    toc;
    
    %%
    show(Scr, Targ, Home, Cursor);
    Scr.wait('test', @() false, 'for', maxSec, 'sec');
    hide(Scr, Targ, Home, Cursor);
    Scr.wait('blank', @() false, 'for', 0.5, 'sec');
    
    %%
    tic;
    Scr.closeLog;
    
    testEyeSampT;
    
    saveWorkspace;
end
toc;

%%
Scr.c.(inpMode).deactivate;
Scr.c.Key.deactivate;

if useEye
    Eye.closeEL;
end

%%
Scr.close;
saveWorkspace;

%%
commPostRun = input('Postrun comment: ', 's');
Scr.saveDiary(commPreRun, [commPreRun '_' commPostRun]);
diary off;