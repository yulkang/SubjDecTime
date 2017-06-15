%% Clearing up
dbstop if error % Useful for debugging

try    Scr.delTree; catch; end
try    delete(Mouse); catch; end
try    delete(Cursor); catch; end
clear classes;


%% Variables common to all trials.
maxSec      = 3;
nTarg       = 2;

tBeepDur    = 0.05;
tInterBeep  = 0.5;
tAllowFrom  = -0.125; % NOTE: The program doesn't deal with tAllowFrom ~= -tAllowUntil.
tAllowUntil = 0.125;
nBeep       = 5;
tRDKMaxDur  = 1;

showGuide   = true;

propRep = invLogit([-1.6:0.4:0, 0:0.4:1.6]);
rng('shuffle');


%% Construct Scr.
Scr     = PsyScr('scr', 0, 'distCm', 66, 'refreshRate', 60, ...
                 'hideCursor', true, 'maxSec', maxSec);

%% Start logging.
Scr.initSaveTimestamp; % Initialize file index to the current time.
Scr.saveDiary; % Save command line outputs.
Scr.saveDep; % Save a snapshot of the m-file itself & all dependencies.


%% Open Scr & construct other objects.
commandwindow; % Bring cursor to the MATLAB command window.
open(Scr);

Mouse           = PsyMouse(Scr, 'freq', 200, 'maxSec', 7   );
Key             = PsyKey(Scr, {'escape'});
Cursor          = PsyCursor(Scr, [255 0 0], 0.1);
RDKCol          = PsyRDKCol(Scr);
Targ            = PsyHover(Scr);
Home            = PsyHover(Scr);
Fix             = PsyPTB(Scr, 'FillOval', [200 200 200], [0 0]', [0.05 0.05]');
Clock           = PsyClock(Scr);
ClockFeedback   = PsyClockFeedback(Scr);
Banner          = PsyBanner(Scr);
Aud             = PsyAud(Scr, {'cue',  'beeps', ...
                               'nBeep', nBeep, ...
                               'durs', tBeepDur, ...
                               'delays', tInterBeep - tBeepDur}, ...
                              {'sndFaster',     'wav/click.WAV'}, ...
                              {'sndSlower',     'wav/secalert.WAV'}, ...
                              {'sndWrong',      'wav/signon.WAV'}, ...
                              {'sndCorrect',    'wav/ding.wav'});
Guide           = PsyMoving(Scr);
                   

% Link objects with Scr & open device(s).
Scr.addObj('Inp', Mouse, Key);
Scr.addObj('Vis', Guide, RDKCol, Targ, Home, ...
                  Clock, ClockFeedback, Fix, Cursor, Banner);
Scr.addObj('Aud', Aud);

Aud.open;


% Initialize visual objects.
init(RDKCol, 0, 0, 'shuffle', ...
             'dotDensity', 16.7/3, 'dotSizeDeg', 0.05  , ...
             'apInnerRDeg', 0.55, 'apRDeg', 1.5, ...
             'maxN', tRDKMaxDur * Scr.info.refreshRate);

init(Targ, 'n', nTarg, 'stAngle', pi, ...
    'colorIn',  [0   255 255; 255 255 0]', ...
    'colorOut', [0   155 155; 155 155 0]');

init(Home, 'n', 1, 'stAngle', 1/2*pi, 'sizeDeg', 0.15, ...
           'colorIn',  [220 220 220]', ...
           'colorOut', [100 100 100]');

       
%% Repeat trials.
for ii = 1:10
    
    %% Initialize file index to the current time.
    Scr.initSaveTimestamp; 
    
    %% Variables constant through the given trial.
    prop    = propRep(randi(length(propRep)));
    
    TimeOutUntilHome = 10;
    
    tHome2Beep     = exprnd(0.2) + 0.5;
    Home.holdSec   = tHome2Beep;
    
    % 0.05 aft 2nd to 0.05 bef 3rd beep
    % (since RDK itself lasts 0.1s)
    tBeep2RDK      = 0.1 + exprndTrunc((tInterBeep - 0.1) / 3, ...
                                        tInterBeep - 0.1); 
               
    tBeep2GoFrom   = tInterBeep * (nBeep - 2) + tAllowFrom;
    tBeep2GoUntil  = tInterBeep * (nBeep - 2) + tAllowUntil;
    tBeep2TargFrom = tInterBeep * (nBeep - 1) + tAllowFrom;
	tBeep2TargUntil= tInterBeep * (nBeep - 1) + tAllowUntil;
    
	tRDKDur        = 1 - tBeep2RDK;
    
    
    %% Initialize visual objects for the trial.
    init(RDKCol, 0, prop, 'shuffle');
    init(Clock, 'shuffle', 'eccenDeg', 0.5);
    init(ClockFeedback, Clock);         
    
    % No need for high frequency sampling until entering Home. Save space.
    Mouse.freq     = 60;
    
    
    %% Visual guide
    allowDeg = abs(Targ.xyDeg(2) - Home.xyDeg(2)) ...
             / tInterBeep * (tAllowUntil - tAllowFrom);
    
    if showGuide
        init(Guide, 'FillRect', [20 20 20]', ...
                    Home.xyDeg, ...
                    [Scr.info.halfSizeDeg(1); allowDeg/2]);
    end
	
	initLogTrial(Scr);
    Scr.saveDiary;

    
    %% Wait fixation  
    activate(Mouse); deactivate(Key);
    hide(Scr, 'all');
    show(Scr, Cursor, Home); 

    Home.holdSec = tHome2Beep;
    
    Scr.wait('enterHome', @() Home.did('enter'), ...
             'for', TimeOutUntilHome, 'sec');

    if ~Home.did('enter')
        hide(Scr, 'all');
        show(Banner, 'Bring cursor to Home!');
        play(Aud, 'sndFaster');
        
        Scr.wait('fb_comeHome', @() false, 'for', 0.5, 'sec');
        finishTrial(Scr, 'nextAfter', 1); saveWorkspace; continue;
    end  
    
    show(Scr, Fix);
    
    %% Start beep after desired time
    Scr.wait('holdHome', @() Home.did('hold') || Home.did('exit'), ...
        'for', TimeOutUntilHome, 'sec');
    
    if Home.did('exit')
        hide(Scr, 'all');
        show(Banner, 'Stay longer at Home!');
        play(Aud, 'sndSlower');
        
        Scr.wait('fb_holdHome', @() false, 'for', 0.5, 'sec');
        finishTrial(Scr, 'nextAfter', 1); saveWorkspace; continue; 
    end  
    
    show(Scr, Targ);
    
    tBeep               = Home.t_.hold1 + tHome2Beep;
    RDKCol.showAtAbsSec = tBeep + tBeep2RDK;
    RDKCol.hideAtAbsSec = tBeep + tBeep2RDK + tRDKDur;
    Clock.showAtAbsSec  = tBeep + tBeep2RDK;
    
    if showGuide
        initMove(Guide, tBeep + (tBeep2GoFrom + tBeep2GoUntil)/2, ...
                        tBeep + (tBeep2TargFrom + tBeep2TargUntil)/2, ...
                        [Home.xyDeg(1); Targ.xyDeg(2)]);

        Guide.showAtAbsSec  = tBeep + tBeep2GoFrom;
        Guide.hideAtAbsSec  = tBeep + tBeep2TargUntil;
    end
    
    play(Aud, 'cue', tBeep);
    
    Mouse.freq          = 200;
    
    
    %% Keep Home until desired time
    Scr.wait('go', @() Home.did('exit'), ...
        'until', tBeep + tBeep2GoUntil, 'sec');
    
    if ~Home.did('exit') || (Home.absSec('exit') > (tBeep + tBeep2GoUntil))
        hide(Scr, 'all'); Guide.showAtAbsSec = nan;
        show(Banner, 'Leave Home earlier!');
        play(Aud, 'sndFaster');
        
        Scr.wait('fb_leaveEarlier', @() false, 'for', 0.5, 'sec');
        finishTrial(Scr, 'nextAfter', 1); saveWorkspace; continue;
        
    elseif Home.absSec('exit') < (tBeep + tBeep2GoFrom)
        hide(Scr, 'all'); Guide.showAtAbsSec = nan;
        show(Banner, 'Stay longer at Home!');
        play(Aud, 'sndSlower');
        
        Scr.wait('fb_leaveLater', @() false, 'for', 0.5, 'sec');
        finishTrial(Scr, 'nextAfter', 1); saveWorkspace; continue;
    end  
    
    hide(Scr, RDKCol);
    
    
    %% Reach Target until desired time
    Scr.wait('enterTarget', @() any(Targ.did('enter')), ...
        'until', tBeep + tBeep2TargUntil, 'sec');
    
    if ~any(Targ.did('enter'))
        hide(Scr, 'all');
        show(Banner, 'Reach Target faster!');
        play(Aud, 'sndFaster');
        
        Scr.wait('fb_reachFaster', @() false, 'for', 0.5, 'sec');
        finishTrial(Scr, 'nextAfter', 1); saveWorkspace; continue;
    
    elseif Targ.absSec('enter') < tBeep + tBeep2TargFrom
        hide(Scr, 'all');
        show(Banner, 'Reach Target slower!');
        play(Aud, 'sndSlower');
        
        Scr.wait('fb_reachSlower', @() false, 'for', 0.5, 'sec');
        finishTrial(Scr, 'nextAfter', 1); saveWorkspace; continue;
    end
    
    
    %% Clock Feedback
    hide(Scr, Clock, Targ, Guide);
    show(Scr, ClockFeedback);
    Mouse.freq = 60;    
    
    activate(Key);
    Scr.wait('clockFeedback', @() ClockFeedback.answered , 'for', 10 , 'sec');
    deactivate(Key);
    
    if ~ClockFeedback.answered
        hide(Scr, 'all');
        show(Banner, 'Drag cursor and press space bar to answer!');
        play(Aud, 'sndFaster');
        
        Scr.wait('fb_clockUnanswered', @() false, 'for', 0.5, 'sec');
        finishTrial(Scr, 'nextAfter', 1); saveWorkspace; continue;
    end
    
    
    %% Feedback
    hide(Scr, ClockFeedback);
    activate(Key);
    
    subjCol = find(Targ.did('enter'));
    
    if RDKCol.prop == 0.5, 
        corrCol = (rand>0.5) + 1;
    else
        corrCol = (RDKCol.prop < 0.5) + 1;
    end
    
    if subjCol == corrCol;
        play(Aud, 'sndCorrect');
        
    else
        play(Aud, 'sndWrong');
        
    end  
    
    
    %% Closing trial
    hide(Scr, 'all');
    Scr.wait('fb_closeTrial', @() false, 'for', 0.5, 'sec');
    
    
    %% Escape
    if Key.n_.escape
        disp('User chose to stop!'); saveWorkspace;
        break; 
    end
    
    
    %% Stats
    fprintf('Home entered  (relSec): %1.3f\n', Home.relSec('enter'));
    fprintf('Home exited   (relSec): %1.3f\n', Home.relSec('exit'));
    fprintf('RDK  onset    (relSec): %1.3f\n', RDKCol.relSec('on'));
    fprintf('RDK  offset   (relSec): %1.3f\n', RDKCol.relSec('off'));
    fprintf('Targ entered  (relSec): %1.3f\n', Targ.relSec('enter'));
    
    %%
    finishTrial(Scr, 'nextAfter', 1); saveWorkspace; 
end


%% Closing
Scr.close;
Aud.close;  

% profile viewer


%% Stats
diffOn = diff(Scr.tTrim('frOn'));
disp(find(diffOn > 0.02));

subplot(4,1,1); 
plot(Scr.relSec('frOn'), [diffOn(1), 1000*diffOn]); 
yLim = ylim; ylim([0 yLim(2)]);

hold on;  
plot(ones(1,2) * Home.relSec('enter'), yLim, 'm-', ...
     ones(1,2) * Home.relSec('exit'),  yLim, 'r-', ...
     ones(1,2) * RDKCol.relSec('on'),  yLim, 'g-', ...
     ones(1,2) * RDKCol.relSec('off'), yLim, 'g-', ...
     ones(1,2) * Targ.relSec('enter'), yLim, 'm-');
ylim(yLim);

plot(Scr.relSec('frOn'), [diffOn(1), 1000*diffOn]); 
hold off;
ylabel('interflip interval (ms)');

%
diffSample = diff(Mouse.tTrim('xyPix'));

subplot(4,1,2); 
plot(Mouse.relSec('xyPix'), [diffSample(1), 1000*diffSample]);
yLim = ylim; ylim([0 yLim(2)]);

hold on;  
plot(ones(1,2) * Home.relSec('enter'), yLim, 'm-', ...
     ones(1,2) * Home.relSec('exit'),  yLim, 'r-', ...
     ones(1,2) * RDKCol.relSec('on'),  yLim, 'g-', ...
     ones(1,2) * RDKCol.relSec('off'), yLim, 'g-', ...
     ones(1,2) * Targ.relSec('enter'), yLim, 'm-');
ylim(yLim);

plot(Mouse.relSec('xyPix'), [diffSample(1), 1000*diffSample]);
hold off;
ylabel({'intersample', 'interval (ms)'});  

%
subplot(4,1,3); 
plot(Scr.relSec('frOn'), ...
     1000*(Scr.relSec('frOn') - Scr.relSec('finishDraw')));
yLim = ylim; ylim([0 yLim(2)]); yLim = ylim;
plot(ones(1,2) * Home.relSec('enter'), yLim, 'm-', ...
     ones(1,2) * Home.relSec('exit'),  yLim, 'r-', ...
     ones(1,2) * RDKCol.relSec('on'),  yLim, 'g-', ...
     ones(1,2) * RDKCol.relSec('off'), yLim, 'g-', ...
     ones(1,2) * Targ.relSec('enter'), yLim, 'm-');
hold on;  
plot(Scr.relSec('frOn'), ...
     1000*(Scr.relSec('frOn') - Scr.relSec('finishDraw')));
ylim(yLim);
hold off;
ylabel({'finishFlip to', 'stimOn (ms)'}); 

%
subplot(4,1,4); plot(Mouse.relSec('xyPix'), Mouse.vTrim('xyPix')');
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


diary off;
testPlotV;


