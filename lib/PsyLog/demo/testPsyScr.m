% testPsyScr

clear all;

Scr = PsyScr('distCm', 50, 'refreshRate', 60);
Scr.open;

Scr.initLog(2,10);
Scr.flip;
Scr.closeLog;

Scr.close;