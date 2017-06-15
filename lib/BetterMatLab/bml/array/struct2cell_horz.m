function C = struct2cell_horz(S, max_col)
% struct2cell_horz  Put field names and contents in 1st & 2nd rows of a cell array.
%
% Helps displaying struct contents in less lines.
%
% EXAMPLE:
% a = struct('a', 1, 'b', 2, 'c', 3)
% a = 
%     a: 1
%     b: 2
%     c: 3
% 
% struct2cell_horz(a)
% ans = 
%     'a'    'b'    'c'
%     [1]    [2]    [3]
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.

if ~exist('max_col', 'var'), max_col = 4; end

f = fieldnames(S);
n = length(f);

C = [f, struct2cell(S)]';

if mod(n, max_col) ~= 0, 
    n = ceil(n/max_col) * max_col; 
    C{1, n} = ''; 
end

C = reshape(C, [], max_col);
