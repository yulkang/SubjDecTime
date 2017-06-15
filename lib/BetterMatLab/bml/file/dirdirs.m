function [f, n] = dirdirs(d)
% Directories within the given folder.
%
% [F, N] = dirfiles(D)
%
% D: Path to a folder.
% F: Cell array of full paths.
% N: Cell array of directory names.

if nargin < 1, d = pwd; end
info = dir(d);
n    = {info.name};
[n,ia] = setdiff(n, {'.', '..'}, 'stable');
info = info(ia);
n    = n([info.isdir]);
try
    f = fullfile(d, n(:));
catch
    f = cellfun(@(s) fullfile(d, s), n(:), ...
        'UniformOutput', false);
end