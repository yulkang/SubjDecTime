function testAudSweep(cue)
Scr = PsyScr;

%%
% Aud = PsyAud(Scr, ...
%     {'cue', 'sweeps', 'n', 3, 'delays', 0});

beeps = varargin2S({
    'nBeep',    4
    'delays',   0
    'freqs',    [500, 500, 1000, 500]
    'enfreqs',  [500, 500, 500,  500]
    'stfreqs',  [250, 250, 250,  250]
    'durs',     [0.05, 0.05, 0.05, 0.05]
    'delays',   [0.35, 0.35, 0.35, 0.355]
    'kind',     'beeps'
    });

if nargin < 1
    Aud = PsyAud(Scr, ...
        {'cue', 'beepsweeps', varargin2S({'beeps', beeps, 'sweeps', PsyAud.beep2beepsweeps(beeps)})});
else
    Aud = PsyAud(Scr, ...
        {'cue', 'beepsweeps', cue});
end
%%
Aud.open;
Aud.play('cue');

cla;
plot(Aud.wav.cue);

