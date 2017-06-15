function [files, nams, pth, flt] = uigetfile2(files, varargin)
% uigetfile if files is empty. Otherwise, return files.
% First output is a cell array of file names with paths, unlike uigetfile, where
% those are separate outputs and output is not always a cell array.
%
% [files, nams, pth, flt] = uigetfile2(files, varargin)

if nargin >= 1 && ~isempty(files)
    if ischar(files)
        files = {files};
    end
    [pth, nams] = filepartsAll(files);
    pth = pth{1};
    flt = [];
    return;
end

[nams, pth, flt] = uigetfile(varargin{:});

if isequal(nams, 0)
    % If Cancel is pressed,
    files = {};
    nams  = {};
    pth   = '';
    flt   = [];
    return;
end

if ischar(nams)
    nams = {nams};
end
files = fullfile(pth, nams);
if ischar(files)
    files = {files};
end