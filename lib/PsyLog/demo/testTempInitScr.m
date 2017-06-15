% Occurs only once per task.

%% Trial: only define parameters for random distributions & functions.
Trial = PsyTrialSDT; % defines methods that draw random numbers from 
                     % parameters.

Trial.r.postFixAvg = 3;
Trial.r.postFixMin = 3;
Trial.r.postFixMax = 5;

% Inline functions are defined as fields of Trial.f.
% Trial.f.postFixInterval = @(Trial) randInterval(Trial.r.postFixAvg, ...
%                                                 Trial.r.postFixMin, ...
%                                                 Trial.r.postFixMax);

%% Visual objects
FP      = PsyCircle([0 0 1]);    
Home    = PsyCircleHover([0 -5 1], [100 0 0], [200 0 0]);
Targ    = PsyCircleHover([0 1 1; 0 -1 1], [100 0 0], [200 0 0]);
RandDot = PsyRandomDot(0, 0, 5, 0.1);
Clock   = PsyRotDot(0, 0, 7, 1);

Scr.addVis(FP, Targ, RandDot); % tagging happens here, using workspace names.
                               % link children back to Scr, too.


%% Input objects
Key     = PsyKey('freq', 300, 'diffOnly', true);
Mouse   = PsyMouse('freq', 300, 'diffOnly', true);

Scr.addInp(Key, Mouse);


%% Readout objects
Fix2Targ  = PsyFix2Targ(Key,   {'space', {'leftarrow', 'rightarrow'}, 'esc'}, ...
                        Eye,   {FP, num2cell(Targ)}, ...
                        Mouse, {Home, num2cell(Targ)});
SDTbyDrag = PsySDTbyDrag;

Scr.addRead(Fix2Targ, SDTbyDrag);


%% Epoch objects


Fix         = PsyEpoch('hide', {'all'}, ...
                       'show', {FP, Home, num2cell(Targ)}, ...
                       'read', Fix2Targ, ...
                       'waitFor', 5, ...
                       'verdict', {'timeout',   'Feedback'
                                   'fixAcq',    'PostFixWait'});
                               
PostFixWait = PsyEpoch('read', Fix2Targ, ...
                       'waitFor', @Trial.postFixInterval, ...
                       'verdict', {'timeout',   'Motion'});

Motion      = PsyEpoch('show', {RandDot, Clock}, ...
                       'read', Fix2Targ, ...
                       'waitFor', 3, ...
                       'verdict', {'fixBreak',  'Response'
                                   'timeout',   'Feedback'});
                               
Response    = PsyEpoch('onEpochEnter', {Clock.hideAfter(@Trial.clockPersistInterval)}, ...
                       'hide', {RandDot}, ...
                       'read', Fix2Targ, ...
                       'waitFor', 1, ...
                       'verdict', {'targAcq',   'ReportSDT'
                                   'timeout',   'Feedback'});
                               
ReportSDT   = PsyEpoch('
                               
Scr.addEpoch(Fix, PostFixWait, Motion, Response);
                   