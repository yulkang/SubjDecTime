function varargout = wait_close(Ser, varargin)
% Wait until serial is closed.
%
% See also: serials.wait

[varargout{1:nargout}] = serials.wait(Ser, 'Status', 'closed', varargin{:});

