% testPsyCursor
try    Scr.delTree; catch; end
try    delete(Mouse); catch; end
try    delete(Cursor); catch; end

clear classes;

maxSec  = 3;
nTarg   = 4;

tBeepDur    = 0.05;
tInterBeep  = 0.5;
tAllowFrom  = -0.1;
tAllowUntil = 0.1;
nBeep       = 4;

%%
Scr     = PsyScr('scr', 0, 'distCm', 66, 'refreshRate', 60, ...
                 'hideCursor', true, 'maxSec', maxSec);
             
%%
commandwindow;
open(Scr);

Mouse           = PsyMouse(Scr, 'freq', 200, 'maxSec', 7   );
Key             = PsyKey(Scr);
Cursor          = PsyCursor(Scr, [255 0 0], 0.1);
RDKCol          = PsyRDKCol(Scr);
Targ            = PsyHover(Scr);
Home            = PsyHover(Scr);
Banner          = PsyBanner(Scr);
Aud             = PsyAud(Scr, {'cue',  'beeps', ...
                               'nBeep', nBeep, ...
                               'durs', tBeepDur, ...
                               'delays', tInterBeep - tBeepDur}, ...
                              {'sndFaster',     'wav/click.WAV'}, ...
                              {'sndSlower',     'wav/secalert.WAV'}, ...
                              {'sndWrong',      'wav/signon.WAV'}, ...
                              {'sndCorrect',    'wav/ding.wav'});

Scr.addObj('Inp', Mouse);
Scr.addObj('Vis', RDKCol, Targ, Home, Cursor, Banner);
Scr.addObj('Aud', Aud);

Aud.open;

%
init(RDKCol, 0, 0, 'shuffle', ...
             'dotDensity', 16.7/3, 'dotSizeDeg', 0.05, ...
             'apInnerRDeg', 0.55, 'apRDeg', 1.5);

init(Targ, 'n', nTarg, 'stAngle', 3/4*pi, ...
    'colorIn',  [255 255 0; 255 255 0; 0 255 255; 0 255 255]', ...
    'colorOut', [155 155 0; 155 155 0; 0 155 155; 0 155 155]', ...
    'order',    [2 3 1 4], ...
    'holdSec', 0);

init(Home, 'n', 1, 'eccenDeg', 0, ...
           'colorIn',  [155 155 155]', ...
           'colorOut', [100 100 100]', ...
           'holdSec', 0);
       
cohRep =  [-.256, -.128, -.064, -.032, 0, 0, .032, .064, .128, .256];
propRep = invLogit([-1.6:0.4:0, 0:0.4:1.6]);
rng('shuffle');       

for ii = 1:5
    
    coh       = cohRep(randi(length(cohRep)));
    prop      = propRep(randi(length(propRep)));
    
    TimeOutUntilHome = 10;
    
    tHome2Beep     = exprnd(0.2) + 0.3;
    Home.holdSec   = tHome2Beep;
    Mouse.freq     = 60;
    
    % 0.05 aft 2nd to 0.05 bef 3rd beep
    % (since RDK itself lasts 0.1s)
    tBeep2RDK      = 0.1 + exprndTrunc((tInterBeep - 0.2) / 3, ...
                                        tInterBeep - 0.2); 
               
    tBeep2GoFrom   = tInterBeep * (nBeep - 2) + tAllowFrom;
    tBeep2GoUntil  = tInterBeep * (nBeep - 2) + tAllowUntil;
    tBeep2TargFrom = tInterBeep * (nBeep - 1) + tAllowFrom;
	tBeep2TargUntil= tInterBeep * (nBeep - 1) + tAllowUntil;
    
	tRDKDur        = 0.1;
    
    
    %%
    init(RDKCol, coh, prop, 'shuffle');
    
    initLogTrial(Scr);

    
    %% Wait fixation  
    activate(Mouse); deactivate(Key);
    hide(Scr, 'all');
    show(Scr, Cursor, Home); 

    Home.holdSec = tHome2Beep;
    
    wait(Scr, @() Home.did('enter'), ...
        'for', TimeOutUntilHome, 'sec');

    if ~Home.did('enter')
        hide(Scr, 'all');
        show(Banner, 'Bring cursor to Home!');
        play(Aud, 'sndFaster');
        
        wait(Scr, @() false, 'for', 0.5, 'sec');
        finishTrial(Scr, 'nextAfter', 1); continue; 
    end  
    
    show(Scr, Targ);
    
    %% Start beep after desired time
    wait(Scr, @() Home.did('hold') || Home.did('exit'), ...
        'for', TimeOutUntilHome, 'sec');
    
    if Home.did('exit')
        hide(Scr, 'all');
        show(Banner, 'Stay longer at Home!');
        play(Aud, 'sndSlower');
        
        wait(Scr, @() false, 'for', 0.5, 'sec');
        finishTrial(Scr, 'nextAfter', 1); continue; 
    end  
    
    tBeep               = Home.t_.hold1 + tHome2Beep;
    RDKCol.showAtAbsSec = tBeep + tBeep2RDK;
    RDKCol.hideAtAbsSec = tBeep + tBeep2RDK + tRDKDur;
    
    play(Aud, 'cue', tBeep);
    
    Mouse.freq          = 200;
    
    %% Keep Home until desired time
    wait(Scr, @() Home.did('exit'), ...
        'until', tBeep + tBeep2GoUntil, 'sec');
    
    if ~Home.did('exit') || (Home.absSec('exit') > (tBeep + tBeep2GoUntil))
        hide(Scr, 'all');
        show(Banner, 'Leave Home earlier!');
        play(Aud, 'sndFaster');
        
        wait(Scr, @() false, 'for', 0.5, 'sec');
        finishTrial(Scr, 'nextAfter', 1); continue;
        
    elseif Home.absSec('exit') < (tBeep + tBeep2GoFrom)
        hide(Scr, 'all');
        show(Banner, 'Stay longer at Home!');
        play(Aud, 'sndSlower');
        
        wait(Scr, @() false, 'for', 0.5, 'sec');
        finishTrial(Scr, 'nextAfter', 1); continue;
    end
    
    hide(Scr, RDKCol);
    
    
    %% Reach Target until desired time
    wait(Scr, @() any(Targ.did('enter')), ...
        'until', tBeep + tBeep2TargUntil, 'sec');
    
    if ~any(Targ.did('enter'))
        hide(Scr, 'all');
        show(Banner, 'Reach Target faster!');
        play(Aud, 'sndFaster');
        
        wait(Scr, @() false, 'for', 0.5, 'sec');
        finishTrial(Scr, 'nextAfter', 1); continue;
    
    elseif Targ.absSec('enter') < tBeep + tBeep2TargFrom
        hide(Scr, 'all');
        show(Banner, 'Reach Target slower!');
        play(Aud, 'sndSlower');
        
        wait(Scr, @() false, 'for', 0.5, 'sec');
        finishTrial(Scr, 'nextAfter', 1); continue;
    end
    
    Mouse.freq = 60;    
    
    %% Feedback
    hide(Scr, Targ);
    activate(Key);
    
    subjAns = find(Targ.did('enter'));
    subjCol = (subjAns >= 3) + 1;
    subjMot = mod(subjAns,2) + 1;
    
    if RDKCol.prop == 0.5, 
        corrCol = (rand>0.5) + 1;
    else
        corrCol = (RDKCol.prop > 0.5) + 1;
    end
    if RDKCol.coh == 0
        corrMot = (rand>0.5) + 1;
    else
        corrMot = (RDKCol.coh  > 0)   + 1;
    end
    corrAns = (corrCol-1) * 2 + corrMot;
    
    if subjAns == corrAns;
        play(Aud, 'sndCorrect');
        
    else
        play(Aud, 'sndWrong');
        
    end  
    
    %% Closing trial
    hide(Scr, 'all');
    wait(Scr, @() false, 'for', 0.5, 'sec');
        
    finishTrial(Scr, 'nextAfter', 1);
    
    %%
    diffOn = diff(Scr.getT('frOn'));
    disp(find(diffOn > 0.02));
end

%% Closing
Scr.close;
% Aud.close;  

% profile viewer

%% Stats
subplot(4,1,1); 
diffOn = diff(Scr.relSec('frOn'));

plot(Scr.relSec('frOn'), [diffOn(1), 1000*diffOn]); 

yLim = ylim; ylim([0 yLim(2)]); yLim = ylim;
hold on;
plot(ones(1,2) * Home.relSec('enter'), yLim, 'b-', ...
     ones(1,2) * Home.relSec('exit'),  yLim, 'r-', ...
     ones(1,2) * RDKCol.relSec('on'),  yLim, 'g-', ...
     ones(1,2) * RDKCol.relSec('off'), yLim, 'g-', ...
     ones(1,2) * Targ.relSec('enter'), yLim, 'm-');

plot(Scr.relSec('frOn'), [diffOn(1), 1000*diffOn]); hold off;
ylim(yLim);

ylabel({'interflip','interval (ms)'}); hold off;

%
diffSample = diff(Mouse.getT('xyPix'));

subplot(4,1,2); 

plot(Mouse.relSec('xyPix'), [diffSample(1), 1000*diffSample]);

yLim = ylim; ylim([0 yLim(2)]); yLim = ylim;
hold on;
plot(ones(1,2) * Home.relSec('enter'), yLim, 'b-', ...
     ones(1,2) * Home.relSec('exit'),  yLim, 'r-', ...
     ones(1,2) * RDKCol.relSec('on'),  yLim, 'g-', ...
     ones(1,2) * RDKCol.relSec('off'), yLim, 'g-', ...
     ones(1,2) * Targ.relSec('enter'), yLim, 'm-');

ylabel({'intersample', 'interval (ms)'}); hold off;
yLim = ylim; ylim([0 yLim(2)]);

%
subplot(4,1,3); 
plot(Scr.getT('frOn'), ...
     1000*(Scr.relSec('frOn') - Scr.relSec('finishDraw')));

yLim = ylim; ylim([0 yLim(2)]); yLim = ylim;
plot(ones(1,2) * Home.relSec('enter'), yLim, 'b-', ...
     ones(1,2) * Home.relSec('exit'),  yLim, 'r-', ...
     ones(1,2) * RDKCol.relSec('on'),  yLim, 'g-', ...
     ones(1,2) * RDKCol.relSec('off'), yLim, 'g-', ...
     ones(1,2) * Targ.relSec('enter'), yLim, 'm-');
hold on;

plot(Scr.relSec('frOn'), ...
     1000*(Scr.relSec('frOn') - Scr.relSec('finishDraw')));

hold off;
ylim(yLim);
ylabel({'finishFlip', 'to stimOn (ms)'}); 

%
subplot(4,1,4); plot(Mouse.relSec('xyPix'), Mouse.getV('xyPix')');
ylabel('pix');

yLim = ylim; ylim([0 yLim(2)]); yLim = ylim;
hold on;
plot(ones(1,2) * Home.relSec('enter'), yLim, 'b-', ...
     ones(1,2) * Home.relSec('exit'),  yLim, 'r-', ...
     ones(1,2) * RDKCol.relSec('on'),  yLim, 'g-', ...
     ones(1,2) * RDKCol.relSec('off'), yLim, 'g-', ...
     ones(1,2) * Targ.relSec('enter'), yLim, 'm-');
hold off;
xlabel('Time after trial onset (sec)');

%%
% profsave(profile('info'), 'prof_testWaitAsync');
