function varargout = isStep(varargin)
% tf = isStep(steps, incl)
% tf = isStep(incl) % assuming existence of steps or S.steps in the caller.
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.
[varargout{1:nargout}] = isStep(varargin{:});