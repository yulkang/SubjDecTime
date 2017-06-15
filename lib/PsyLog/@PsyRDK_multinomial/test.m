function [RDK, Scr] = test(Scr_opts, RDK_opts)

if ~exist('Scr_opts', 'var'), Scr_opts = {}; end
if ~exist('RDK_opts', 'var'), RDK_opts = {}; end

Scr_opts = varargin2C(Scr_opts, { ...
    'scr', 1, ...
    });

Scr   = PsyScr(Scr_opts{:});

RDK_opts = varargin2C(RDK_opts, { ...
    0.5, 0.7, {'shuffle', 'shuffle', 'shuffle'}, ...
    'mot_dir', pi/2, ...
    'apInnerRDeg', 0.5, ...
    'maxSec', 5, ...
    }, false, 3);

RDK = PsyRDKConst(Scr, RDK_opts{:});

Scr.addObj('Vis', RDK);
Scr.open;
Scr.initLogTrial;

RDK.show;
Scr.wait('RDK', @() false, 'for', RDK.maxSec, 'sec');
RDK.hide;

Scr.closeLog;
Scr.close;
end