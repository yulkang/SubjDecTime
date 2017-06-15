function mlstripcommentsdir(src, dst)
d    = rdir(fullfile(src, '**/*.m'));
fsrc = {d.name};
n    = length(fsrc);

if nargin < 2
    dst = [src '_scmt'];
end

if exist(dst, 'dir')
    warning('Cannot write into an existing folder %s!', dst);
    return;
end

for ii = 1:n
    [dsrc, file, ext] = fileparts(fsrc{ii});
    ddst = strrep(dsrc, src, dst);
    if ~exist(ddst, 'dir')
        mkdir(ddst); 
    end
    fdst = fullfile(ddst, [file, ext]);
    
    mlstripcommentsfile(fsrc{ii}, fdst);
    fprintf(' %35s -> %35s\n', fsrc{ii}, fdst);
end
