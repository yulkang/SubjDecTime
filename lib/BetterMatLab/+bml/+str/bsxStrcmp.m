function varargout = bsxStrcmp(varargin)
% Many-to-many comparison of strings.
% Performance is better when ptn contains fewer strings.
%
% tf = bsxStrcmp(c, ptn)
%
% c, ptn  : a cell vector of strings.
% tf(k,m) = strcmp(c{k}, ptn{m})
% op = 'raw' (default), 'any', 'all'
%
% See also bsxStrcmp
[varargout{1:nargout}] = bsxStrcmp(varargin{:});