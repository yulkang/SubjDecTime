function varargout = hsv2(varargin)
% First 60% of hsv, flipped so that it goes from blue (small) to red (big).
%
% map = hsv2(m, s, v)
% 
% m: Scalar. Number of colors.
% s, v: Scalar. Saturation and Value (brightness), in [0, 1].
%       Value is adjusted automatically so that green is not too bright.
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = hsv2(varargin{:});