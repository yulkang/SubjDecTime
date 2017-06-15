function varargout = funPrintf(varargin)
% Replaces alphabets in the format to strings, except for escaped ones.
%
% s = funPrintf(frm, formatChar1, replacingStr1, ...)
%
% frm           : String. Characters matching one of formatChar is replaced by
%                 corresponding replacingStr escept when the formatChar is 
%                 preceded by %. Use %% to have % in the result.
%                 
% formatChar    : One alphabet character, either upper or lower case.
%
% replacingStr  : Any string.
%
% *When there are duplicate formatChars, the last replacingStr takes precedance.
%
% EXAMPLE:
%
% >> funPrintf('D%TT%%', 'D', '20130725', 'T', '162105');
% ans = 20130725T162105%
%
% See also FUNFULLFILE, FUNPRINTFCONNECT.
[varargout{1:nargout}] = funPrintf(varargin{:});