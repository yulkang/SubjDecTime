function varargout = dealDef(varargin)
% Same as deal() but gives defaults if the cell array is shorter than the number of outputs.
%
% [out1, out2, ...] = dealDef({in1, in2, ...}, {default1, default2, ...}, ...
%                             [empty_if_no_default = false])
%
% If number of default is less than the number of outputs, the output gets [].
% If empty2d is true, empty inputs are replcaed with the default.
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = dealDef(varargin{:});