function varargout = wait_no_transfer(ser, varargin)
[varargout{1:nargout}] = serials.wait(ser, 'TransferStatus', @(v) strcmp(v, 'idle'), varargin{:});