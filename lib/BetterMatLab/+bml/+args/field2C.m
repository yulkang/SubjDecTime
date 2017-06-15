function varargout = field2C(varargin)
% Gives fields in a cell vector.
%
% field2C(S, fs) : {S.(fs{1}), S.(fs{2}), ...}
% field2C(S, fmt, args) : equivalent to field2C(S, csprintf(fmt, args))
[varargout{1:nargout}] = field2C(varargin{:});