function varargout = max_distrib1(varargin)
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
[varargout{1:nargout}] = max_distrib1(varargin{:});