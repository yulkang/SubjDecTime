function migrate_to_pkg(varargin)

%%
S = bml.args.varargin2S(varargin, {
    'src', 'PsyLib'
    'dst', '+bml'
    'include', 'setdiff'
    });

info_src = rdir(fullfile(S.src, '**/*.m'));
info_dst = rdir(fullfile(S.dst, '**/*.m'));

files_src = {info_src.name};
files_dst = {info_dst.name};
files_root = dirfiles('*.m');

%%
names_src = cellfun(@(v) output(@() fileparts(v), 2), files_src, ...
    'UniformOutput', false);
names_dst = cellfun(@(v) output(@() fileparts(v), 2), files_dst, ...
    'UniformOutput', false);

switch S.include
    case 'intersect'
        [names_incl, ~, ix] = intersect(names_src, names_dst);
    case 'setdiff'
        [names_incl, ix] = setdiff(names_src, names_dst);
end
names_incl = setdiff(names_incl, files_root);

n = numel(names_incl);

fprintf('Found %d files that do not have aliases.\n', n);

%%
for ii = 1:n
%     ia1 = ia(ii);
%     file_src = files_src{ia1};
%     [pth_src, name_src, ext_src] = fileparts(file_src);
%     movefile(file_src, file_src2);
%     fprintf('Renamed %s to %s\n', file_src, file_src2);
  
    switch S.include
        case 'intersect'
            ix1 = ix(ii);
            file_dst = files_dst{ix1};

            bml.pkg.pkg2alias('mfiles', file_dst);
            
        case 'setdiff'
            ix1 = ix(ii);
            
            file_src = files_src{ix1};
            file_src_sep = strsplit(file_src, filesep);
            file_dst_sep = [{S.dst}, file_src_sep(2:end)];
            file_dst_sep(2:(end-1)) = cellfun(@(s) ['+' s], ...
                file_dst_sep(2:(end-1)), 'UniformOutput', false);
            file_dst = fullfile(file_dst_sep{:});
            
            mkdir2(fileparts(file_dst));
            copyfile(file_src, file_dst);

            bml.pkg.pkg2alias('mfiles', file_dst);
    end
end
end