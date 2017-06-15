function varargout = wait_open(Ser, varargin)
% Wait until serial is opened.
%
% See also: serials.wait

[varargout{1:nargout}] = serials.wait(Ser, 'Status', 'open', varargin{:});

