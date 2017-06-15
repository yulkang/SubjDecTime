clear classes

Scr = PsyScr;
Scr.init('scr', 0, 'skipSyncTests', true, 'refreshRate', 60);
Scr.open;

BarGraph = PsyBarGraph(Scr, 'history_n_current');
Scr.addObj('Vis', BarGraph);

Scr.initLogTrial;
BarGraph.show;
Scr.wait('dummy', @() false, 'for', 3, 'sec');
Scr.finishTrial;

Scr.close;