% testPsyDeepCopy
clear classes;

tScr  = PsyScr;
tScr2 = copy(tScr);
tScr2.visOrdLog.Scr.toLog = 3;
tScr2.visOrdLog.Scr = 1;