% testRDKCol: Generally follow testPsyCursor.

clearPsyLog;
rng('shuffle');

Scr = PsyScr('scr', 0, 'distCm', 66);

% Mouse   = Scr.addObj('Inp', PsyMouse);
% Cursor  = Scr.addObj('Vis', PsyCursor([255 0 0], 0.5));
RDKCol  = Scr.addObj('Vis', PsyRDKCol);

init(Scr);
init(RDKCol, 0.8, 0.8, 'shuffle');

open(Scr);
% initLog(Scr);

% get(Mouse);
% update(Cursor);

nRep = 12;

Scr.initLogTrial;

%%
% testPsyRDKColProfile;
show(RDKCol);
Scr.wait('test', @() false, 'for', nRep, 'fr');
hide(RDKCol);

%%

Scr.closeLog();
Scr.close();

%%
diffOn = diff(Scr.t_.frOn);
disp(max(diffOn)*1000);
disp(find(diffOn > 0.02));

clf;
set(0, 'DefaultLineLineWidth', 0.5);
% subplot(2,1,1);
% plot(diffOn)

nFr = nRep;

% subplot(2,1,2);
RDKCol.plotTraj;
