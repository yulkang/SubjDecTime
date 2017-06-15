% testPsyMouse
clear classes;

Scr = PsyScr('scr', 0, 'refreshRate', 60, 'distCm', 66);
Scr.open;

Mouse = Scr.addObj('Inp', PsyMouse);

Scr.initLog();

%%

nRep = 100;
tic;
for ii = 1:nRep
    get(Mouse);
end
toc;


Scr.closeLog();
Scr.close();
