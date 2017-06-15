function [s, ic] = unique_rand_by(r, mat, Distrib)
% Random numbers that are same for identical rows of a matrix.
%
% [s, ic] = unique_rand_by(RandStream, mat, [Distrib])
%
% Distrib: a PsyDistrib object.
%
% EXAMPLE:
% >> [s, ic] = unique_rand_by([], [1 2; 1 3; 1 2])
% s =
%     0.2575
%     0.8407
%     0.2575
% ic =
%      1
%      2
%      1
%
% See also: unique

[~, ~, ic] = unique(mat, 'rows', 'stable');
n_rand     = max(ic);

if ~exist('r', 'var') || isempty(r)
    if exist('Distrib', 'var')
        r_num  = Distrib.randSamp([n_rand 1]);
    else
        r_num  = rand(n_rand, 1);
    end
else
    if exist('Distrib', 'var')
        r_num  = Distrib.randSamp(r, [n_rand 1]);
    else
        r_num  = rand(r, n_rand,1);
    end
end
s          = r_num(ic);
