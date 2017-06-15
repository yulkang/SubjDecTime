% testPsyLog
clear all;

% Because everything is so capsulized, actual specification can be
% contained in this one script.


%% Experiment
% Parameters constant throughout the experiment.
% Those that define how to sample an epoch.
expr.name = [];

Scr = PsyScr;
Scr.init;

Trial(expr.nTrial) = PsyTrial; % allocates space.


%% Common visual stimuli.
Scr.Vis.FP = PsyVisPTB('FillOval', [0 0 1], [255 0 0]); % Specified in visual degrees.


%% Common epoch structure
epoch.begin.start        = {@Scr.show, {'FP', 'Targ'}
                            @Scr.Aud.Cue.play}; % N x 2 cell array. {func {args}}.
epoch.begin.wait.fun     = {{[1 0 0]}}; % A shorthand of below (1x1 cell), when Scr.Read has only one field.
%     epoch.begin.wait.fun     = {@Scr.Read.read,        {Scr.Inp(:), [1 0 0]}
%                                 @Scr.updateNDrawAll,   {}};                   % N x 2 cell array.
epoch.begin.wait.sched   = 2; % A shorthand of {inf, 1}. 3 is a shorthand of {inf, 1, 1}.
epoch.begin.wait.timeout = 0;
epoch.begin.post  = {@Scr.hide, {'FP'}}; % N x 2 cell array.
epoch.begin.next  = {'inpVerdict1', 'nextStep1', 'resVerdict1', {'@..', {}}
                     'inpVerdict2', 'nextStep2', '',            {'',    {}}}; % N x 4 cell array.
epoch.begin.finish= {[],{}}; % N x 2 cell array.

epoch.end.start = {'@..',{}};
epoch.end.wait  = {'@..',{}};
epoch.end.timeout = 0;
epoch.end.post  = {'@..',{}};
epoch.end.next  = {'inpVerdict1', 'nextStep', 'resVerdict1', {'@..', {}}};
epoch.end.finish= {'@..',{}};


%% Saving params
save(expr.fileFull, 'expr', 'Scr', 'Trial');


%% Actual run
for iTrial = 1:expr.nTrial
    %% Sampling & specifying a random/varying part of an epoch.
    epoch.begin.wait.timeout = rand_duration(expr.distrib1, expr.distrib2, expr.distrib3);
    
    %% Run & Temporary saving
    cTrial = PsyTrial.run(Scr, epoch);
    Trial(iTrial) = cTrial;
    
    save(sprintf('%s%d', expr.fileFull, iTrial), 'cTrial'); % temporary files
end


%% Save
save(expr.fileFull, 'expr', 'Scr', 'Trial');

for iTrial = 1:length(Trial)
    delete(sprintf('%s%d', expr.fileFull, iTrial), 'cTrial');
end


%% Analysis
load(fileFull, 'Trial');

ResVerdict = concNestedField(Trial, '.result.verdict');

ResCorrect = strcmp(ResVerdict, 'CORRECT');

MotionDur = concNestedField(Trial, '.Scr.Vis.FP.Motion.durSec');
