function [RDK, Scr] = test(Scr_opts, RDK_opts)

if ~exist('Scr_opts', 'var'), Scr_opts = {}; end
if ~exist('RDK_opts', 'var'), RDK_opts = {}; end

Scr_opts = varargin2C(Scr_opts, { ...
    'scr', 0, ...
    'refreshRate', 60, ...
    'skipSyncTests', true, ...
    });

Scr   = PsyScr(Scr_opts{:});

RDK_opts = varargin2C(RDK_opts, { ...
    {0.6, 0.6}, {'shuffle', 'shuffle', 'shuffle', 'shuffle'}, ...
    'maxSec', 5, 't_freq', 10, 'show_for_prop', 0.5, 'avoid_overlap_fr', 0, ... 4, ... 'nFrSet', 6, 'show_for_fr', 3, 
    'grid_type', 'concentric', ...
    'nDot', 1, 'grid_size_deg', {0, 2, pi}, ... 0.5, 8, pi/8}, ...
    'apRDeg', 0.5, 'dotSizeDeg', 0.2, 'penWidthDeg', 0.1, ...
    }, false, 2);

RDK = PsyRDK_OX(Scr, RDK_opts{:});
% RDK.set_apRDeg_for_even_nDot;

FP = PsyPTB(Scr, 'FrameCircle', [50 50 50]', [0 0]', 0.1);

Scr.addObj('Vis', RDK, FP);

%%
% logging.commit;

%%
Scr.open;
Scr.initLogTrial;

disp(RDK);

% FP.show;
RDK.show;
Scr.wait('RDK', @() false, 'for', RDK.maxSec, 'sec');
RDK.hide;
FP.hide;

Scr.closeLog;
Scr.close;

WaitSecs(1); % Wait until Screen actually closes.

%% Plots
% Shape positions
RDK.plot_gridPoint;

% Shape timeline
RDK.plot_timeline;
end