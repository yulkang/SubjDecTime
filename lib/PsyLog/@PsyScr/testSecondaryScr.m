% function Scr = testSecondaryScr(opt_scr1, opt_scr2, varargin)
% % Scr = testSecondaryScr(opt_scr1, opt_scr2, varargin)
% 
% if nargin < 1, opt_scr1 = {}; end
% if nargin < 2, opt_scr2 = {}; end

opt_scr1 = {};
opt_scr2 = {};

skip_sync_test = 0;

opt_scr1 = varargin2C(opt_scr1, {'scr', 1, 'skipSyncTests', skip_sync_test, 'HideCursor', false}); % 'refreshRate', 60, 
opt_scr2 = varargin2C(opt_scr2, {'scr', 0, 'skipSyncTests', skip_sync_test, 'HideCursor', false, 'win_ord', 2}); % 'refreshRate', 60, 

%% Initialize objects
Scr = PsyScr;
Scr.init(opt_scr1{:});
Scr.init(opt_scr2{:});

%% Open devices
Scr.open(1);
Scr.open(2);

%% Add objects
FP    = PsyHover(Scr, 'n', 1, 'eccenDeg', 0, 'sizeDeg', 0.5, 'sensRDeg', 1);
Targ  = PsyHover(Scr, 'n', 1, 'eccenDeg', 5, 'angleRad', 0, 'sizeDeg', 0.5, 'sensRDeg', 1);
% Cursor= PsyCursor(Scr, [255 0 0], 0.025, 'Mouse');
Key   = PsyKey(Scr, {'Return', 'SPACE', 'ESCAPE'});
% Mouse = PsyMouse(Scr);

Scr.addObj('Inp', Key, Mouse);
Scr.addObj('Vis', FP, Targ); % , Cursor);

% Scr.addObj({'Vis', 2}, FP, Targ); % , Cursor);

ListenChar(2);

%% Loop
for i_trial = 1:3
    % Start trial
    Scr.initLogTrial;
    Key.activate;
%     Mouse.activate;
    
    % Show stim
%     FP.show;
    Targ.show;
%     Cursor.show;
    
    Scr.wait('get_input', @() Key.logged('Return') || Key.logged('ESCAPE'), 'for', 5, 'sec');
    
%     % Delay hiding stim
%     Scr.wait('delay', @() Key.logged('ESCAPE'), 'for', 1, 'sec');
%     
    % Hide stim
    Targ.hide;
    Scr.wait('hide', @() Key.logged('ESCAPE'), 'for', 1, 'sec');
    
    % Finish trial
    Scr.closeLog;
    
    % Decide if to terminate
    if Key.logged('ESCAPE'), break; end
end

%% Close devices
Scr.close;

ListenChar(0);
% end