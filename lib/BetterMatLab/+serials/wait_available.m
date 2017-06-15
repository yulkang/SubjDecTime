function varargout = wait_available(ser, varargin)
% Wait until BytesAvailable > 0.
%
% varargout = wait_available(ser, varargin)
%
% See also: serials.wait
[varargout{1:nargout}] = serials.wait(ser, 'BytesAvailable', @(v) v > 0, varargin{:});