function varargout = alignTS(varargin)
% ALIGNTS Zero and resample using regular interval.
%
% ts = alignTS(ts, alignTo, dt)
[varargout{1:nargout}] = alignTS(varargin{:});