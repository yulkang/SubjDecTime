Scr = PsyScr;

RBar = PsyRBar(Scr);

Scr.init('scr', 0);
Scr.addObj('Vis', RBar);

Scr.open;
Scr.initLogTrial;
RBar.show;
Scr.wait('dummy', @() false, 5, 'sec');
Scr.finishTrial;

Scr.close;