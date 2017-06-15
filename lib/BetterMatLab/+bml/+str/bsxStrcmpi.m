function varargout = bsxStrcmpi(varargin)
% Many-to-many comparison of strings.
% Performance is better when ptn contains fewer strings.
%
% tf = bsxStrcmpi(c, ptn, [op])
%
% c, ptn  : a cell vector of strings.
% tf(k,m) = strcmpi(c{k}, ptn{m})
% op = 'raw' (default), 'any', 'all'
%
% See also bsxStrcmp
[varargout{1:nargout}] = bsxStrcmpi(varargin{:});