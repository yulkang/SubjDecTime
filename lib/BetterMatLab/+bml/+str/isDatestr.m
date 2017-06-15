function varargout = isDatestr(varargin)
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
[varargout{1:nargout}] = isDatestr(varargin{:});