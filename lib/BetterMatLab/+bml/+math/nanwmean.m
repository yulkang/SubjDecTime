function m = nanwmean(v, w, varargin)
% m = nanwmean(v, w, ...)
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
m = nansum( ...
        bsxfun(@rdivide, ...
            bsxfun(@times, v, w) .* incl, ...
            sum(bsxfun(@times, w, incl), varargin{:})) ...
        , varargin{:});
end