function [files, nam] = dirfiles(d)
% Full path to files (not folders) within the given folder.
%
% [F, N] = dirfiles(D)
%
% D: Path to a folder.
% F: Cell array of full paths.
% N: Cell array of file names.

if nargin < 1, d = pwd; end
info = dir(d);
if ~exist(d, 'dir')
    % extract path part
    d = fileparts(d);
end
nam    = {info.name};
nam    = nam(~[info.isdir] & ~strcmps({'.DS_Store'}, nam));
files  = fullfile(d, nam(:));