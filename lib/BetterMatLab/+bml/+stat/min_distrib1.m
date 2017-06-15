function varargout = min_distrib1(varargin)
% Distribution of min(RV1 ~ p1, RV2 ~ p2) when the two are independent.
%
% [p_max, p_1st] = min_distrib1(p1, p2, sum_equals = 'prod')
%
% p_min(t,m): Probability distribution of min(t_1 ~ p1(:,m), t_2 ~ p2(:,m))
% p_last{k}(t,m): Probability of t_k happening last at t.
%
% sum_mode
% 'prod' (default)
% : assume that the events of each column can happen
%   separately from each other. 
%   The sum of returned probabilities equals
%   the *product* of the sums of the columns.
%     sum(p_min(:)) == sum(p_1st(:)) == sum(p(:,1)) * sum(p(:,2))
%
% 'sum'
% : assume that the two columns represent disjoint events.
%   The sum of returned probabilities equals 
%   the *sum* of the sums of the columns.
%     sum(p_min(:)) == sum(p_1st(:)) == sum(p(:))
%
% Formula from: http://math.stackexchange.com/questions/308230/expectation-of-the-min-of-two-independent-random-variables
% See also: max_distrib
%
% EXAMPLE:
% >> [p_min, p_1st] = min_distrib([0 1; 0.5 0.5]')
% p_min =
%     0.5000
%     0.5000
% 
% p_1st =
%          0    0.5000
%     0.3333    0.1667
%
% EXAMPLE: p_1st(t,:) follows the same ratio as p(t,:). The case of 'prod'.
% >> [p_min, p_1st] = min_distrib([0 0.2; 0.1 0.1]', 'prod')
% p_min =
%     0.0400
%     0.0400
% 
% p_1st =
%          0    0.0400
%     0.0320    0.0080
%
% EXAMPLE: p_1st(t,:) follows the same ratio as p(t,:). The case of 'sum'.
% >> [p_min, p_1st] = min_distrib([0 0.4; 0.1 0.1]', 'sum')
% p_min =
%     0.3000
%     0.3000
% 
% p_1st =
%          0    0.3000
%     0.2400    0.0600
%
% EXAMPLE: Normalizing sum to product
% >> [p_min, p_1st] = min_distrib([0 0.1; 0.1 0.1]', 'prod')
% p_min =
%     0.0100
%     0.0100
% 
% p_1st =
%          0    0.0100
%     0.0050    0.0050
%
% EXAMPLE: Normlizing sum to sum
% >> [p_min, p_1st] = min_distrib([0 0.1; 0.1 0.1]', 'sum')
% p_min =
%     0.1500
%     0.1500
% 
% p_1st =
%          0    0.1500
%     0.0750    0.0750
%
% EXAMPLE: Normalizing sum to product (with one zero column)
% >> [p_min, p_1st] = min_distrib([0 0; 0.1 0.3]', 'prod')
% p_min =
%      0
%      0
% 
% p_1st =
%      0     0
%      0     0
% 
% EXAMPLE: Normalizing sum to sum (with one zero column)
% >> [p_min, p_1st] = min_distrib([0 0; 0.1 0.3]', 'sum')
% p_min =
%     0.2500
%     0.7500
% 
% p_1st =
%          0    0.2500
%          0    0.7500
%
% EXAMPLE: Each matrix is processed separately (normalizing to product)
% >> [p_min, p_1st] = min_distrib(cat(3, [0 0.1; 0.1 0.1]', zeros(2,2)), 'prod')
% p_min(:,:,1) =
%     0.0100
%     0.0100
% 
% p_min(:,:,2) =
%      0
%      0
% 
% p_1st(:,:,1) =
%          0    0.0100
%     0.0050    0.0050
% 
% p_1st(:,:,2) =
%      0     0
%      0     0
%
% EXAMPLE: Each matrix is processed separately (normalizing to sum)
% >> [p_min, p_1st] = min_distrib(cat(3, [0 0.1; 0.1 0.1]', zeros(2,2)), 'sum')
% p_min(:,:,1) =
%     0.1500
%     0.1500
% 
% p_min(:,:,2) =
%      0
%      0
% 
% p_1st(:,:,1) =
%          0    0.1500
%     0.0750    0.0750
% 
% p_1st(:,:,2) =
%      0     0
%      0     0
[varargout{1:nargout}] = min_distrib1(varargin{:});