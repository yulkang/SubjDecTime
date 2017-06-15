% testPsyCursor
try    Scr.delTree; catch; end
try    delete(Mouse); catch; end
try    delete(Cursor); catch; end

clear classes;

maxSec  = 3;
nTarg   = 2;

%%
Scr     = PsyScr('scr', 0, 'distCm', 66, 'refreshRate', 60, ...
                 'hideCursor', true, 'maxSec', maxSec);

%%
open(Scr);

Mouse           = PsyMouse(Scr, 'freq', 200, 'maxSec', 7   );
Key             = PsyKey(Scr);
Cursor          = PsyCursor(Scr, [255 0 0], 0.1);
RDKCol          = PsyRDKCol(Scr);
Targ            = PsyHover(Scr);
Home            = PsyHover(Scr);
Clock           = PsyClock(Scr);
ClockFeedback   = PsyClockFeedback(Scr);
Banner          = PsyBanner(Scr);
Aud             = PsyAud(Scr, {'cue',  'beeps', 'nBeep', 3, 'durs', 0.1, 'delays', 0.9}, ...
                              {'sndTimeOut',    'wav/click.WAV'}, ...
                              {'sndFixBreak',   'wav/secalert.WAV'}, ...
                              {'sndWrong',      'wav/signon.WAV'}, ...
                              {'sndCorrect',    'wav/ding.wav'});

Scr.addObj('Inp', Mouse, Key);
Scr.addObj('Vis', RDKCol, Targ, Home, Clock, ClockFeedback, Cursor, Banner);
Scr.addObj('Aud', Aud);

Aud.open;

%
init(RDKCol, 0, 0, 'shuffle', ...
             'dotDensity', 16.7/3, 'dotSizeDeg', 0.1, ...
             'apInnerRDeg', 0.55, 'apRDeg', 1.5);

init(Clock, 'shuffle', 'eccenDeg', 0.5);
init(ClockFeedback, Clock);         

init(Targ, 'n', nTarg, 'stAngle', pi, ...
    'colorIn',  [0   255 255; 255 255 0]', ...
    'colorOut', [0   155 155; 155 155 0]');

init(Home, 'n', 1, 'stAngle', 1/2*pi, ...
           'colorIn',  [155 155 155]', ...
           'colorOut', [100 100 100]');
       
for ii = 1  :2 
    
    init(RDKCol, 0, invLogit(rand*3-1.55    ), 'shuffle');
    
    initLogTrial(Scr);

    %% Wait fixation  
    activate(Mouse);
    show(Scr, Cursor, Targ, Home); 

    wait(Scr, @() (Home.did('hold') || Home.did('exit')), ...
                'for', maxSec, 'sec');

%     if Home.exited
%         show(Banner, 'Stay longer at Home!');
%         play(Aud, 'sndFixBreak');
%         
%         finishTrial(Scr, 'nextAfter', 1); % InterTrial interval
%         continue;  
%     end  
    
    %% Random dot
    show(Scr, RDKCol, Clock);    
    play(Aud, 'cue');  

    wait(Scr, @() any(Targ.did('hold')) || any(Targ.did('exit')), ...
              'for', maxSec, 'sec');

%     if any(Targ.exited)
%         stop(Aud);
%         
%         show(Banner, 'Stay longer at Target!');
%         play(Aud, 'sndFixBreak');
%         
%         finishTrial(Scr, 'nextAfter', 1);
%     end
     
    %% Feedback - Clock
    hide(Scr, RDKCol, Clock, Targ);
    show(Scr, ClockFeedback);

    activate(Key);
    wait(Scr, @() ClockFeedback.answered , 'for', 5 , 'sec');
    deactivate(Key);
    
    %% Feedback - Answer
    if find(Targ.did  ('enter')) == ((RDKCol.prop < 0.5) + 1); % TODO: answer
        play(Aud, 'sndCorrect');
        
    else
        play(Aud, 'sndWrong');
        
    end  
    
    %% Closing trial
    hide(Scr, 'all');
    closeLog(Scr);
    finishTrial(Scr, 'nextAfter', 1);
    
    %%
    diffOn = diff(Scr.getT('frOn'));
    disp(find(diffOn > 0.02));
end

%% Closing
Scr.close;

Aud.close;  

% profile viewer

%% Stats
subplot(4,1,1); 
plot(Scr.relSec('frOn'), [diffOn(1), 1000*diffOn]); 
ylabel('interflip interval (ms)');

%
diffSample = diff(Mouse.getT('xyPix'));

subplot(4,1,2); 
plot(Mouse.relSec('xyPix'), [diffSample(1), 1000*diffSample]);
ylabel('intersa  mple interval (ms)');  
yLim = ylim; ylim([0 yLim(2)]);

%
subplot(4,1,3); 
plot(Scr.relSec('frOn'), ...
     1000*(Scr.relSec('frOn') - Scr.relSec('finishDraw')));
ylabel('finishFlip to stimOn (ms)'); 
yLim = ylim; ylim([0 yLim(2)]); yLim = ylim;
plot(ones(1,2) * Home.relSec('enter'), yLim, 'm-', ...
     ones(1,2) * Home.relSec('exit'),  yLim, 'r-', ...
     ones(1,2) * RDKCol.relSec('on'),yLim, 'g-', ...
     ones(1,2) * RDKCol.relSec('off'),  yLim, 'g-', ...
     ones(1,2) * Targ.relSec('enter'), yLim, 'm-');
hold on;  
plot(Scr.relSec('frOn'), ...
     1000*(Scr.relSec('frOn') - Scr.relSec('finishDraw')));
hold off;
ylim(yLim);

%
subplot(4,1,4); plot(Mouse.relSec('xyPix'), Mouse.getV('xyPix')');
ylabel('pix');
yLim = ylim; ylim([0 yLim(2)]); yLim = ylim;

hold on;
plot(ones(1,2) * Home.relSec('enter'), yLim, 'm-', ...
     ones(1,2) * Home.relSec('exit'),  yLim, 'r-', ...
     ones(1,2) * RDKCol.relSec('on'),yLim, 'g-', ...
     ones(1,2) * RDKCol.relSec('off'),  yLim, 'g-', ...
     ones(1,2) * Targ.relSec('enter'), yLim, 'm-');
hold off;
xlabel('Time after trial onset (sec)');

%%
% profsave(profile('info'), 'prof_testWaitAsync');


