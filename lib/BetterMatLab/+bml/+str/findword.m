function varargout = findword(varargin)
% Find a word that is surrounded by non-alphanumeric, non-underscores.
% loc = findword(text, word)
%
% word can be a cell array of strings, in which case loc is also a cell array.
%
% EXAMPLE:
% >> loc = findword('abc+def, abcd, [abc], abc abc', {'abc', 'def', 'ghi'}); loc{:}
% ans =     1    17    23    27
% ans =     5
% ans =   Empty matrix: 1-by-0
%
% See also: regexp
[varargout{1:nargout}] = findword(varargin{:});