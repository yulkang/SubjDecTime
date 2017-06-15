function varargout = glaxes(varargin)
% Global title and labels for an array of axes.
%
% hs:   an array of axes handles.
% op:   'title', 'xlabel', 'ylabel', or 'set'
% ht:   Handle of the text object.
% hgl:  Handle of the global axis object.
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = glaxes(varargin{:});