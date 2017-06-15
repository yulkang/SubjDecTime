function [any_tf, tf] = in_range(v, r)
% [any_tf, tf] = in_range(v, r)
%
% v         : either a scalar or a vector.
% r         : pairs of [lb, ub]. 
% any_tf    : true if for any lb and ub pair, lb <= v < ub holds.
% tf(k)     : true if lb(k) <= v < ub(k) holds.
%
% EXAMPLE:
% >> in_range(1, [0 3])
% ans =
%      1
% 
% >> in_range(1, [0 0.5])
% ans =
%      0
% 
% >> in_range(1, [0 0.5 1 2])
% ans =
%      1
% 
% >> in_range(1, [0 inf])
% ans =
%      1
% 
% >> in_range(1, [-inf 0])
% ans =
%      0
%      
% >> in_range(1, [0 nan])
% ans =
%      0
%
% >> in_range(1, [])
% ans = 
%      0
%
% >> in_range(1:10, [2 4 6 9])
% ans =
%      0     1     1     0     0     1     1     1     0     0
% 
% >> find(in_range(1:10, [2 4 6 9]))
% ans =
%      2     3     6     7     8
% 
% >> find(in_range(1:10, [2 4 6 inf]))
% ans =
%      2     3     6     7     8     9    10
     
if ~isscalar(v)
    any_tf = arrayfun(@(vv) in_range(vv, r), v);
    tf = any_tf;
else
    tf = (v == r(1:2:end)) | (sign((v - r(1:2:end)) .* (v - r(2:2:end))) == -1);
    any_tf = any(tf);
end