function res = attach_ones(src)
% ATTACH_ONES - Attach a column of ones to the left.
%
% See also regress

res = [ones(size(src,1),1), src];