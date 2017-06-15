% testPsyCursor
try
    Scr.delTree;
catch
end

clear classes;

Scr = PsyScr('scr', 0, 'distCm', 66, 'refreshRate', 60, 'HideCursor', false);

Mouse   = Scr.addObj('Inp', PsyMouse);
Cursor  = Scr.addObj('Vis', PsyCursor([255 0 0], 0.5));

open(Scr);
initLog(Scr);

get(Mouse);
update(Cursor);

%%
testPsyCursorProfile;

%%
Scr.closeLog();
Scr.close();

%%
diffOn = diff(Scr.frOnAbsSec);
plot(diffOn)

disp(find(diffOn > 0.02));