function fprintfLine(fid, char, n)
% fprintfLine(fid, char, n)

if ~exist('fid', 'var') || isempty(fid)
    fid = 1;
end
if ~exist('char', 'var'), char = '-'; end
if ~exist('n', 'var'), n = 10; end

fprintf(fid, '%s\n', repmat(char, [1 n]));