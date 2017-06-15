function varargout = csprintf(varargin)
% CSPRINTF sprintf that repeats over cell array or array input.
%
% res = CSPRINTF(fmt, arg1, arg2, ...)
%
%   res: Cell array
%   arg: Either cell array or array. Single-element array will be expanded.
%
%   See also CFPRINTF, SPRINTF.
%
% 2013 (c) Yul Kang
[varargout{1:nargout}] = csprintf(varargin{:});