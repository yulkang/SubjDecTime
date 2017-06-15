function varargout = err_msg(varargin)
% err_msg  Gives error message with links without rethrowing it.
%
% err_msg(err)
% : Displays error message with links.
%   err is an error structure caught by try..catch statements.
%
% msg = err_msg(err)
% : Returns error string with links without displaying it.
%   You can display it by disp(msg).
%
% EXAMPLE:
% >> try arrayfun(@(v) min(v, 2, []), 1:3); catch err, err_msg(err); end
% MIN with two matrices to compare and a working dimension is not supported.
% > In @(v)min(v,2,[]) at 0
%
% See also cmd2link
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu
[varargout{1:nargout}] = err_msg(varargin{:});