function varargout = funFullFile(varargin)
% Same as funPrintf except that '/' is combined by fullfile.
%
% EXAMPLE:
%
% >> funFullFile('D%TT/%%', 'D', '20130725', 'T', '162105')
% ans = 20130725T162105/%
%
% >> funFullFile('D%TT/%%_%/', 'D', '20130725', 'T', '162105')
% ans = 20130725T162105/%_/
% 
% See also FUNPRINTF.
[varargout{1:nargout}] = funFullFile(varargin{:});