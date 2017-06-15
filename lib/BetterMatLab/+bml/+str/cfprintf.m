function varargout = cfprintf(varargin)
% CFPRINTF fprintf that repeats over cell array or array input.
%
%   res = CFPRINTF(fmt, arg1, arg2, ...)
%   res = CFPRINTF(fid, fmt, arg1, arg2, ...)
% 
%   res: Cell array
%   fid: (Optional) File handle, as from fopen().
%   arg: Either cell array or array. Single-element array will be expanded.
%
%   See also CSPRINTF, FPRINTF.
[varargout{1:nargout}] = cfprintf(varargin{:});