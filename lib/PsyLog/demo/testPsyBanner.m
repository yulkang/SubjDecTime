Scr = PsyScr;
Scr.open;

Banner = PsyBanner(Scr, 'test');
Scr.addObj('Vis', Banner);

initLog(Scr);

Scr.show(Banner);
Scr.waitAsync(@() false, {}, 'for', 1, 'sec');

Scr.hide('all');
Scr.closeLog;
Scr.close;

plot(diff(Scr.Log.getT('frOn')));