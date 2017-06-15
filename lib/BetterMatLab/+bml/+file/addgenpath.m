function varargout = addgenpath(varargin)
% Add paths recursively
%
% addgenpath(d=pwd,addopt={},verbose = true)
%
% addopt: '-begin' (default), '-end', '-frozen'
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = addgenpath(varargin{:});