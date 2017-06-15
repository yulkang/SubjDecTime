function movefile(src, dst)

if iscell(src) && all(cellfun(@ischar, src))
    if ischar(dst) && (bml.file.exist_dir(dst) || ~exist(dst, 'file'))
        dst_dir = dst;
        
        mkdir2(dst_dir);
        n = numel(src);
        
        for ii = 1:n
            src_file = src{ii};
            [~, src_name, src_ext] = fileparts(src_file);
            dst_file = fullfile(dst_dir, [src_name, src_ext]);
            
            movefile(src_file, dst_file);
            fprintf('Moved %s => %s\n', src_file, dst_file);
        end
    else
        error('Not implemented yet!');
    end
else
    error('Not implemented yet!');
end