function [p_max, p_last] = max_distrib1(d1, d2, nrm)
% Distribution of max(RV1 ~ p1, RV2 ~ p2) when the two are independent.
%
% [p_max, p_last] = max_distrib1(p1, p2, sum_equals = 'prod')
%
% p_max(t,m): Probability distribution of max(t_1 ~ p1(:,m), t_2 ~ p2(:,m))
% p_last{k}(t,m): Probability of t_k happening last at t.
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
%     sum(p_max(:)) == sum(p_last(:)) == sum(p(:))
%
% See also min_distrib.

% 2014-2016 (c) Yul Kang. hk2699 at columbia dot edu.

if nargin < 3, nrm = 'prod'; end

[p_max, p_last] = min_distrib1(flip(d1, 1), flip(d2, 1), nrm);
p_max = flip(p_max, 1);

if nargout >= 2
    for ii = 1:2
        p_last{ii} = flip(p_last{ii}, 1);
    end
end