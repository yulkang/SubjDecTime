function tf = isStep(steps, incl)
% tf = isStep(steps, incl)
% tf = isStep(incl) % assuming existence of steps or S.steps in the caller.
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.

if nargin < 2
    incl  = steps;
    try
        steps = evalin('caller', 'steps');
    catch
        steps = evalin('caller', 'S.steps');
    end
end
if ~iscell(steps), steps = {steps}; end
if ~iscell(incl),  incl  = {incl}; end

tf = any(ismember(steps, incl));
