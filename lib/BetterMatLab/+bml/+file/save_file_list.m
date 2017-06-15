function files = save_file_list(filt, varargin)
% files = save_file_list(filt, varargin)
%
% 'abs_path', false
% 'outfile', 'file_list.txt'
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'abs_path', false
    'outfile', 'file_list.txt'
    });

info = rdir(filt);
files0 = {info.name};
if S.abs_path
    files = fullfile(pwd, files0);
else
    files = files0;
end
n = numel(files);

fid = fopen(S.outfile, 'w');
for ii = 1:n
    fprintf(fid, '%s\n', files{ii});
end
fclose(fid);
fprintf('List of %d files are saved to %s\n', n, S.outfile);