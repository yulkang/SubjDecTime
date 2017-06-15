function varargout = wait_no_read(ser, varargin)
[varargout{1:nargout}] = serials.wait(ser, 'TransferStatus', @(v) isempty(strfind(v, 'read')), varargin{:});