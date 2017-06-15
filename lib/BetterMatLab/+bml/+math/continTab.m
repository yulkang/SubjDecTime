function varargout = continTab(varargin)
% t = continTab(a, b)
% 
% a, b: logical vectors (0 or 1)
% t   : 2 x 2 matrix where t(I,J) is the count of (a==(I-1)) & (b==(J-1)).
%
% See alo CHISQUARECONT, FEXACT
[varargout{1:nargout}] = continTab(varargin{:});