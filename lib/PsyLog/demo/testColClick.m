% testRDKCol: Generally follow testPsyCursor.

clearPsyLog;
rng('shuffle');

Scr = PsyScr('scr', 0, 'distCm', 66);

% Mouse   = Scr.addObj('Inp', PsyMouse);
% Cursor  = Scr.addObj('Vis', PsyCursor([255 0 0], 0.5));
RDKCol  = Scr.addObj('Vis', PsyRDKConst);

init(Scr);
pLevCol = 0.4;
pBlue = rand*pLevCol+(0.5-pLevCol/2); 
init(RDKCol, 0, pBlue, {'shuffle', 'shuffle', 'shuffle'});

open(Scr);
% initLog(Scr);

% get(Mouse);
% update(Cursor);

nRep = 180;

%% Aud
pLev  = 0.4;
pLeft = rand*pLev+(0.5-pLev/2); 
P     = 0.1; 
[s, b, t, bt] = binSnd([], [pLeft*P, (1-pLeft)*P], [0.004 0.002], 750, [2000 0], 44100); % , true, false);

Aud = PsyAud(Scr, {'clicks', s, 'rate', 44100}, ...
                  {'cue', 'beeps', 'nBeep', 3, 'amps', 0.5});
Aud.open;
Scr.addObj('Aud', Aud);

%% Key
Key = PsyKey(Scr, {'leftarrow', 'rightarrow', 'leftshift', 'leftcontrol'}, ...
             'freq', Scr.info.refreshRate, 'maxSecAtHighFreq', 5);
Scr.addObj('Inp', Key);

%%
Scr.initLogTrial;
Key.activate;
% testPsyRDKColProfile;
% Aud.play('cue');
Scr.wait('gap0', @() false, 'for', 1.5, 'sec');
Aud.play('clicks');
Scr.wait('gap1', @() false, 'for', 0.1, 'sec');
show(RDKCol);
Scr.wait('test', @() Key.n_.leftshift + Key.n_.leftcontrol ...
                   + Key.n_.leftarrow + Key.n_.rightarrow == 2, ...
                   'for', nRep, 'fr');
Aud.stop('clicks');
hide(RDKCol);
Scr.wait('gap2', @() false, 'for', 1, 'sec');

%%
Key.deactivate;
Scr.closeLog();
Scr.close();
Aud.close();

%%
diffOn = diff(Scr.t_.frOn);
disp(max(diffOn)*1000);
disp(find(diffOn > 0.02));

% clf;
% set(0, 'DefaultLineLineWidth', 0.5);
% subplot(2,1,1);
% plot(diffOn)

nFr = nRep;

% subplot(2,1,2);
% RDKCol.plotTraj;

%%
Key.relS

if pLeft > 0.5, fprintf('L %1.2f\n', pLeft); else fprintf('R %1.2f\n', 1-pLeft); end

if ~isempty(Key.relS.leftarrow)
    fprintf('L: ');
    if pLeft>0.5, fprintf('Correct LR!\n'); else fprintf('Wrong LR!\n'); end
    RT_Click = Key.relS.leftarrow - Aud.relSec('clicks_LogSt');
    
elseif ~isempty(Key.relS.rightarrow)
    fprintf('R: ');
    if pLeft<0.5, fprintf('Correct LR!\n'); else fprintf('Wrong LR!\n'); end
    RT_Click = Key.relS.rightarrow - Aud.relSec('clicks_LogSt');
    
else
    RT_Click = nan;
end
fprintf('RT_Click: %1.3fs\n\n', RT_Click);

if pBlue > 0.5, fprintf('D %1.2f\n', pBlue); else fprintf('U %1.2f\n', 1-pBlue); end
if ~isempty(Key.relS.leftshift)
    fprintf('U: ');
    if pBlue<0.5, fprintf('Correct color!\n'); else fprintf('Wrong color!\n'); end
    RT_Color = Key.relS.leftshift - RDKCol.relSec('on');
    
elseif ~isempty(Key.relS.leftcontrol)
    fprintf('D: ');
    if pBlue>0.5, fprintf('Correct color!\n'); else fprintf('Wrong color!\n'); end
    RT_Color = Key.relS.leftcontrol - RDKCol.relSec('on');
    
else
    RT_Color = nan;
end
fprintf('RT_Color: %1.3fs\n\n', RT_Color);

fprintf('RT diff : %1.3fs\n\n', RT_Color - RT_Click);

delay = RDKCol.relSec('on') - Aud.relSec('clicks_LogSt');
fprintf('Color was later than Clicks by: %1.3fs\n\n', delay);

% subplot(2,1,1);
% plot(tOnClick,  cumsum(b(1,:)-b(2,:)), 'b-'); % tOnClick: TODO
% 
% subplot(2,1,2);
% plot(tOnColor, cumsum(c(1,:)-n2), 'b-'); % tOnColor: TODO
