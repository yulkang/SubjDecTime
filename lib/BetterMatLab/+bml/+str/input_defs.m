function varargout = input_defs(varargin)
% [ch, chIx] = input_defs(querry, choices, varargin)
%
% querry : a string.
% choices: a cell vector of strings.
%
% OPTIONS
% -------
% 'maxN', inf
% 'def', nan
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = input_defs(varargin{:});