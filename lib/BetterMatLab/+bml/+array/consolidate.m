function varargout = consolidate(varargin)
% Same as consolidator except xcon can be given.
%
% [xcon, ycon, ind, arr] = consolidate(x, y, fun, tol, xcon, def=nan)
%
% After running consolidator for the whole set, 
% run consolidate for the subset with xcon,
% so that when the subset lacks some elements of xcon in the whole set,
% the resulting ycon is still in the same order.
%
% See also: consolidator
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.
[varargout{1:nargout}] = consolidate(varargin{:});