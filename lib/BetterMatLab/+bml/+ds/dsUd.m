function varargout = dsUd(varargin)
% Set/get dataset's userdata.
%
% Get mode
% --------
% ud = dsUd(ds)         % get the whole UserData
% v  = dsUd(ds, field)  % get a field
%
% Set mode
% --------
% ds = dsUd(ds, [], v)      % replace the whole UserData
% ds = dsUd(ds, field, v)   % replace a field
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = dsUd(varargin{:});