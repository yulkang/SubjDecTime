function varargout = wait_no_write(ser, varargin)
[varargout{1:nargout}] = serials.wait(ser, 'TransferStatus', @(v) isempty(strfind(v, 'write')), varargin{:});