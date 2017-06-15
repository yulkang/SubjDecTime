function [c, x, b_incl] = sep2cell(v, b, max_b)
% SEP2CELL - Separate data into cells, according to category number.
%
% [c, x] = sep2cell(v, b)
%
% v : A vector of data to separate.
% b : Either:
%     (1) Category vector. Contains positive integers.
%     (2) max_b-by-p matrix. Unique rows of b defines categories.
% max_b : Optional.
%
% c : A cell array with max_b (if missing, max(b)) cells.
%     c{k} = v(b==k).
% x : A cell array with max_b (if missing, max(b)) cells.
%     x{k} = find(b==k).
% b_incl : Only defined when b is a matrix. 
%          Matrix containing unique rows of b.
%
% EXAMPLE:
% >> [c, x] = sep2cell([10 20 30 40 50], [1 2 1 3 2]);
% >> c{:}
% ans =      10    30
% ans =      20    50
% ans =      40
% >> x{:}
% ans =      1     3
% ans =      2     5
% ans =      4
%
% 2013 (c) Yul Kang, hk2699 at columbia dot edu.

if ~isvector(b) && ismatrix(b)
    [b_incl, ~, b] = unique(b, 'rows');
end

if nargin < 3, max_b = max(b); end

c = arrayfun(@(k) v(b==k), 1:max_b, 'UniformOutput', false);

if nargout >= 2
    x = arrayfun(@(k) find(b==k), 1:max_b, 'UniformOutput', false);
end