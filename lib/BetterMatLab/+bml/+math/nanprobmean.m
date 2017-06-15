function m = nanprobmean(v, p, varargin)
% m = nanwmean(v, p, ...)
%
% EXAMPLE:
% >> m = bml.math.nanwmean([ 1 2 nan; nan 1 2], [2 1 1; 1 1 1])
% m =
%     1.0000    1.5000    2.0000
% 
% >> m = bml.math.nanwmean([ 1 2 nan; nan 1 2], [2 1 1; 1 1 1], 2)
% m =
%     1.3333
%     1.5000
%
% >> m = bml.math.nanwmean([ 1 2 nan; nan 1 2], [2 1 1], 2)
% m =
%     1.3333
%     1.5000
% 
% >> m = bml.math.nanwmean([ 1 2 nan; nan 1 2], [2 1 1])
% m =
%     1.0000    1.5000    2.0000

incl = ~isnan(v);
v(~incl) = 0;

p = rep2fit(p, size(v));
w = binornd(1, p);

m = nansum( ...
        bsxfun(@rdivide, ...
            v .* w .* incl, ...
            sum(w .* incl, varargin{:})) ...
        , varargin{:});
end