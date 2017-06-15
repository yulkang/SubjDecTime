function strrep_rdir(src0, dst, varargin)
% strrep_rdir(src0, dst, ...)
%
% OPTIONS
% -------
% 'pth', '' % './**/*.m'
% 'rdir_args', {} % {@(d) ~is_git_path(d.name)};
% 'whole_word', true
% 'case_sensitive', true
% 'confirm', true
% 'lines_bef', 2
% 'lines_aft', 2

%% Inputs
S = varargin2S(varargin, {
    'pth', '' % './**/*.m'
    'rdir_args', {} % {@(d) ~is_git_path(d.name)}
    'whole_word', true
    'case_sensitive', true
    'confirm', true
    'lines_bef', 2
    'lines_aft', 2
    'files', []
    });

%% Get files
if isequal(S.files, [])
    if isempty(S.pth)
        S.pth = './**/*.m';
    elseif bml.file.exist_dir(S.pth)
        S.pth = fullfile(S.pth, '**/*.m');
    end
    if isempty(S.rdir_args) || isempty(S.rdir_args{1})
        S.rdir_args{1} = @(d) ~is_git_path(d.name);
    end
    d = rdir(S.pth, S.rdir_args{:});
    files = {d.name};
else
    files = S.files;
    if ischar(files)
        files = {files};
    end
end
n = numel(files);

%% Check src and dst
if S.case_sensitive
    src = src0;
else
    src = lower(src0);
end
len_src = length(src);

%% File-by-file
for i_file = 1:n
    % Read text
    file = files{i_file};
%     fprintf('===== Opening %s ... ', file);
    orig0 = fileread(file);
    res   = orig0;
    if S.case_sensitive
        orig = orig0;
    else
        orig = lower(orig0);
    end
    
    % Find occurrences of src
    if S.whole_word
        occ = strfind_whole(orig, src);
    else
        occ = strfind(orig, src);
    end
    at_lines = which_line(orig, occ);
    n_occ = numel(occ);
    if n_occ == 0, continue; end
    
    fprintf('\n');
    fprintf('===== In %s : found %d occurrences\n', ...
        link2edit(file), n_occ);
    n_changed = 0;
    
    for i_occ = 1:n_occ
        c_occ = occ(i_occ);
        c_src = res(c_occ + (1:len_src) - 1);
        at_line = at_lines(i_occ);
        
%         disp(occ); % DEBUG
        
        if ~strcmp_case(c_src, src0, S.case_sensitive)
            % May not match after replacing previous occurrences.
            % e.g., when replacing 'aa' with 'bb' in 'aaa', 
            % the second occurrence of 'aa' will disappear after replacing
            % the first.
            continue;
        end
        
        if S.confirm
            [bef, aft] = get_context(res, c_occ, len_src, S.lines_bef, S.lines_aft);
            
            src_disp = pad_quotes(c_src);
            dst_disp = pad_quotes(dst);
            
            fprintf('----- At line %d:\n', at_line);
            cprintf('text', '%s', bef);
            cprintf('red',  '%s', src_disp);
            cprintf('text', '%s', '=>');
            cprintf('blue', '%s', dst_disp);
            cprintf('text', '%s', aft);
            fprintf('\n');
            fprintf('----- Replace %s with %s (y/n)? ', src_disp, dst_disp);
            if ~inputYN
                continue;
            end
        end
        
        st_occ = c_occ;
        en_occ = c_occ + len_src - 1;
        % str_replace_at(res, c_occ, len_src, dst, occ);
        [res, occ] = strrep_st_en(res, st_occ, en_occ, dst, occ); 
        n_changed = n_changed + 1;
    end
    
    % Save
    if n_changed > 0
        if S.confirm
            fprintf('===== Save %s (y/n)? ', file);
            if ~inputYN
                continue;
            end
        end
        str_write(res, file);
    end
end
fprintf('\n');
end

function res = strcmp_case(str1, str2, case_sensitive)
if case_sensitive
    res = strcmp(str1, str2);
else
    res = strcmpi(str1, str2);
end
end

function at_lines = which_line(str, pos)
n = numel(pos);
at_lines = zeros(size(pos));
pos_linebreaks = find(str == sprintf('\n'));
for ii = 1:n
    at_lines(ii) = nnz(pos_linebreaks < pos(ii)) + 1;
end
end

function str_write(str, file)
fprintf('Writing to %s ... ', file);
fid = fopen(file, 'w');
fprintf(fid, '%s', str);
fclose(fid);
fprintf('Done.\n');
end

function str = pad_quotes(str)
str = ['"', str, '"'];
end

function [bef, aft] = get_context(str, pos, len, lines_bef, lines_aft)
pos_linebreaks = [0, find(str == sprintf('\n')), (numel(str)+1)];
pos_linebreaks_bef = pos_linebreaks(find(pos_linebreaks < pos, lines_bef + 1, 'last'));
pos_linebreaks_aft = pos_linebreaks(find(pos_linebreaks > pos, lines_aft + 1, 'first'));

if isempty(pos_linebreaks_bef)
    bef = str(1:(pos - 1));
else
    % After the linebreak to the character before pos
    bef = str((pos_linebreaks_bef(1) + 1):(pos - 1));
end
if isempty(pos_linebreaks_aft)
    aft = str((pos + len):end);
else
    % From pos + len to the character before the linebreak
    aft = str((pos + len):(pos_linebreaks_aft(end) - 1));
end
end