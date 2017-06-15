function f = inlineFun(name)
% f = inlineFun(name)
%
% iif   : If-elseif.
%         v = inIfEl(cond1, v1, cond2, v2, ...)
%
% inIfEl  : If-else. 
%         v = inIfEl(cond, vIfTrue, vIfFalse)
%
% isafe : Returns default value if ~isfinite(v). Useful for limits.
%         v = isafe(v, vDefault).
%         


%% inline function library
inIf   = @(varargin) varargin{2*find([varargin{1:2:end}], 1, 'first')}();
inIfEl = @(varargin) varargin{3-varargin{1}};
inFin  = @(v, vDefault) inIfEl(isfinite(v), v, vDefault);
inRe   = @(v, vDefault) inIfEl(isreal(v), v, vDefault);

%%
f = eval(name);