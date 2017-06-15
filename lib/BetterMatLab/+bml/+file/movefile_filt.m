function [file_dst, file_src, info] = movefile_filt(filt, dst)
info = rdir(filt);
file_src = {info.name};
n = length(file_src);

mkdir2(dst);
file_dst = cell(size(file_src));
for ii = 1:n
    [~, nam, ext] = fileparts(file_src{ii});
    file_dst{ii} = fullfile(dst, [nam, ext]);
    movefile(file_src{ii}, file_dst{ii});
    
    if mod(ii, 100) == 0
        fprintf('.');
    end
    if mod(ii, 1000) == 0
        fprintf('%d\n', ii);
    end
end
fprintf('Done.\n');
end