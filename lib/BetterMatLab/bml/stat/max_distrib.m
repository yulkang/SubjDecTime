function [p_max, p_last] = max_distrib(d, nrm)
% Distribution of max of p(:,1) and p(:,2) when the two are independent.
% When ndims(p) > 2, each pair of p(:,1,m) and p(:,2,m) is processed
% separately.
%
% [p_max, p_1st] = max_distrib(p, sum_equals = 'prod')
%
% p_max(t,1,:): Probability distribution of max(t_1 ~ p(:,1), t_2 ~ p(:,2))
% p_last(t,k,:): Probability of t_k happening last at t.
%
% sum_mode
% 'prod' (default)
% : assume that the events of each column can happen
%   separately from each other. 
%   The sum of returned probabilities equals
%   the *product* of the sums of the columns.
%     sum(p_max(:)) == sum(p_1st(:)) == sum(p(:,1)) * sum(p(:,2))
%
% 'sum'
% : assume that the two columns represent disjoint events.
%   The sum of returned probabilities equals 
%   the *sum* of the sums of the columns.
%     sum(p_max(:)) == sum(p_1st(:)) == sum(p(:))
%
% See also min_distrib.

% 2014-2016 (c) Yul Kang. hk2699 at columbia dot edu.

if nargin < 2, nrm = 'prod'; end

[p_max, p_last] = min_distrib(flip(d, 1), nrm);
p_max = flip(p_max, 1);
p_last = flip(p_last, 1);