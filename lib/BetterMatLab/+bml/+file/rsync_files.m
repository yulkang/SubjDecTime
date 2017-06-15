function rsync_files(op, files)
% rsync_files(op, files)
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

if ischar(files)
    files = {files};
end
assert(iscell(files));
assert(all(cellfun(@ischar, files(:))));

n = numel(files);

if n == 0
    fprintf('No file is selected.\n');
    return;
end

for ii = 1:n
    file = files{ii};
    Localog.rsync(op, file, 'confirm', false, 'filt_mode', true);
end
end