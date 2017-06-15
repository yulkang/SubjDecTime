function p = pval_from_stat(stat, tail)
% p = pval_from_stat(stat, tail='L'|'R'|{'B'})
% stat
% : compared to 0. Give stat - stat_criterion if necessary.
%   For multidimensional stat, operates on the first dimension.
% L : left-tailed
% R : right_tailed
% B : two-tailed

if nargin < 2, tail = 'B'; end

switch tail
    case 'L'
        p = mean(stat <= 0);
        
    case 'R'
        p = mean(stat >= 0);
        
    case 'B'
        p1 = mean(stat <= 0);
        p2 = mean(stat >= 0);
        p = 2 * min(p1, p2);
end
end