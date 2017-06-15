function [paths, files] = dep2paths(src, varargin)
% [paths, files] = dep2paths(function_name, ...)
%
% Wrapper for DEP2TXT that returns unique paths that the given function depends on.
%
% See also: DEP2TXT

[~, paths, files] = dep2txt(src, varargin{:});
end