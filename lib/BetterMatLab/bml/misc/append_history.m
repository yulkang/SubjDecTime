function append_history(txt)
% append_history(txt)
%
% txt: cell or char.

error('Doesn''t work currently.');

if ischar(txt), txt = cellstr(txt); end

file = fullfile(prefdir, 'history.m');

[fid, msg] = fopen(file, 'at');
if ~isempty(msg), disp(msg); end

fprintf(fid, '%s\n', txt{:});
fclose(fid);