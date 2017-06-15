% To solve: how to efficiently record and retrieve history?
% Especially, when a param is sampled from a population.
%   : Save only randomly sampled variables & the rules to trial_struct.
%     Actual instantiation is saved automatically.
%
% Save instantiation, so as to easily (1) reproduce, and (2) retrieve.
%   : Save a snapshot right after flip / play.
%     Always use '.v' as the property to save in v/a/iObjHigh.
%     Only active objects are saved.
%     

% Record:


IO = IOHigh;

IO.openScreen;
IO.openPort;

IO.addV('FP'    , [], FillOvalHigh([0 -6 3], [255 0 0]));  % Screen Function.
IO.addV('Targ'  , [], OnOffOvalHigh);                    % IOHigh Function.
IO.addV('Motion', [], MotionHigh);                    % Placeholder.


IO.addA('Cue'   , 'Beeps',     {});


IO.addI('FixAcq',   {'KeyPress', {'spacebar'}
                     'MouseIn' , {IO.V.FP} });
IO.addI('FixBreak', {'KeyPress', {'leftarrow', 'rightarrow'}
                     'MouseOut', {IO.V.FP} });
IO.addI('FixBreak', {'KeyPress', {'leftarrow', 'rightarrow'}
                     'MouseOut', {IO.V.FP} });

recIO = struct([]);
                 
for iTrial = 1:expr.maxTrialNum
    
    %% Init
    IO.hideAll;
    IO.waitFor(0); % Clear
    
    IO.hist.init(); % Hand-estimate max size of history, to optimize memory.
    IO.modV('Motion', 'Motion', {'xdir',  randsample(-1:0.2:1)
                                 'color', randsample(-1:0.2:1)}); % Initializes, too.  Takes time.
    
    
    %% waitFixAcq
    IO.msg('waitFixAcq'); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    IO.show({'FP', 'ClockAxis', 'MouseCursor'}); % Showing is cumulative.
                                                 % Latter ones are shown later.
                                                 
    ret = IO.waitFor(1, {'FixAcq'}); % Supersedes WaitMulti().
    
    switch ret.msg
        case 'TIMEOUT'
            IO.play('timeout');
            IO.hide({'FP'});
            continue;
    end
    
    
    %% waitResp
    IO.msg('waitResp'); %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    IO.show({'Motion'}, 2); % 2: draw Motion on 2nd-from-bottom layer.  -2 would have placed it 2nd-from-top layer.
    ret = IO.waitFor(1, {'TargAcq'});
    
    IO.hide({'Motion'});
    IO.waitFor(0);
            
    switch ret.msg
        case 'TIMEOUT'
            IO.play('timeout');
            continue;
            
        case 'AcqTarg'
            if ret.dir   == sign(IO.V.Motion.dir) && ...
               ret.color == sign(IO.V.Motion.color)
           
                IO.play('correct');
            else
                IO.play('wrong');
            end
    end
    
    
    %% Save
    recIO(iTrial) = IO.retrieveHist; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Return struct arrays.
    % planIO  : Planned timing. As needed in conditions in durations.
    % recIO   : Recorded timing.

end    
    
IO.closeScreen;
IO.closePort;


for iTrial  = 1:expr.maxTrialNum
    rt      = recIO(iTrial).Motion.onSec - recIO(iTrial).FixBreak.onSec;
    
    motion  = [recIO(iTrial).Motion];
    motDur  = [motion.offPlanSec] - [motion.onPlanSec];
    
    dot     = recIO(iTrial).Motion;
end
    
