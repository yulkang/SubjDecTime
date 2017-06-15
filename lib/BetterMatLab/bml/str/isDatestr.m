function tf = isDatestr(str, loc, fmt)
% tf = isDatestr(str, loc, fmt)
%
% loc: 'pre', 'post', 'only', 'any' (default), depending on where the date is.
% fmt: 'yyyymmddTHHMMSS' by default.
%
% Example:
% >> isDatestr('12345678T012345')
% ans =     1
% 
% >> isDatestr('pre12345678T012345', 'only')
% ans =     0
%
% >> isDatestr('pre12345678T012345', 'post')
% ans =     1
%
% See also: PRINTLOG, REGEXP

if ~exist('loc', 'var'), loc = 'any'; end
if ~exist('fmt', 'var'), fmt = '\d{8,8}T\d{6,6}'; end

switch loc
    case 'pre'
        fmt = ['^' fmt, '.*$'];
    case 'post'
        fmt = ['^.*', fmt '$'];
    case 'only'
        fmt = ['^' fmt '$'];
    case 'any'
end

tf = ~isempty(regexp(str, fmt, 'once'));