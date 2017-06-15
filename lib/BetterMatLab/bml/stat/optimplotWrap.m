function [stop, varargout] = optimplotWrap(x, v, s, f, varargin)
% [stop, varargout] = optimplotWrap(x, v, s, f, varargin)

stop = false;

if strcmp(s, 'init') || ~isappdata(gca, nam)
    setappdata(gca, 'optimplotWrap', varargin);
else
    varargin = getappdata(gca, 'optimplotWrap');
end

[varargout{1:(nargout-1)}] = f(x, v, s, varargin{:});