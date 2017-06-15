function filewrite(file, text)
% filewrite(file, text)
%
% If text is a cell array, each cell becomes a line.
%
% See also: fileread
if iscell(text)
    text = sprintf('%s\n', text{:});
end
assert(ischar(text));

fid = fopen(file, 'w');
fprintf(fid, '%s', text);
fclose(fid);
end