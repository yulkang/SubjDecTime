function res = upPath(pth, n)
% pth: One of
%      path/subfolder1/subfolder2
%      path/subfolder1/subfolder2/
%      path/subfolder1/subfolder2/file.ext
%
% res: path/subfolder1  (when n=1 or unspecified)
%
% n  : Number of subfolders to omit.

if ~exist('n', 'var')
    n = 1;
end

[pth, nm, ex] = fileparts(pth);

if isempty(ex) % a/b or a/b/
    pth = fullfile(pth, nm); % enforce 'a/b'
end

res = pth;

for ii = 1:n
    res = fileparts(res); % take off the last folder.
end