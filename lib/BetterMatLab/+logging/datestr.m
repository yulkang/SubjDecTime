function s = datestr(v)
% DATESTR in a format common to the logging package.
%
% s = datestr;        % current time
% s = datestr(V);     % uses datevec V.
% s = datestr('fmt'); % returns the format string.

fmt = 'yyyymmddTHHMMSS.FFF';

if nargin < 1, v = now; end
if isequal(v, 'fmt')
    s = fmt; 
else
    s = datestr(v, fmt);
end