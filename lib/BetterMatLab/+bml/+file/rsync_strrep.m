function [files_dst, files_src] = rsync_strrep(varargin)
% [files_dst, files_src] = rsync_strrep(varargin)
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'filt', ''
    'files', []
    'src', '.png'
    'dst', '.mat'
    'confirm', true
    'op', 'pull'
    });
if isequal(S.files, [])
    S.files = uigetfileCell(S.filt);
else
    assert(iscell(S.files));
    assert(all(vVec(cellfun(@ischar, S.files))));
end
n = numel(S.files);

if n == 0
    fprintf('No file is selected.\n');
    return;
end

files_src = S.files;
files_dst = cell(size(files_src));
for ii = 1:n
    files_dst{ii} = strrep(files_src{ii}, S.src, S.dst);
end

if S.confirm
    fprintf('%s\n', files_dst{:});
    fprintf('%d files are selected.\n', n);
    fprintf('Do you want to %s the files ', S.op);
    if ~inputYN_def('', true)
        return;
    end
end

bml.file.rsync_files(S.op, files_dst);
end