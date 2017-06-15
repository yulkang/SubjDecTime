function varargout = cmd2link(varargin)
% Convert MATLAB command to link.
%
% l = cmd2link(cmd, [msg = cmd])
%
% Example:
% >> disp(cmd2link('magic(7)', 'click to see magic(7)'));
% <a href="matlab: magic(7)">click to see magic(7)</a>
%
% See also msg2link, disp2copy, str, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.
[varargout{1:nargout}] = cmd2link(varargin{:});