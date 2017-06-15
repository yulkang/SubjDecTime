function [p_min, p_1st] = min_distrib(p, sum_equals)
% Distribution of min of p(:,1) and p(:,2) when the two are independent.
% When ndims(p) > 2, each pair of p(:,1,m) and p(:,2,m) is processed
% separately.
%
% [p_min, p_1st] = min_distrib(p, sum_equals = 'prod')
%
% p_min(t,1,:): Probability distribution of min(t_1 ~ p(:,1), t_2 ~ p(:,2))
% p_1st(t,k,:): Probability of t_k happening first at t.
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

% 2014-2016 (c) Yul Kang. hk2699 at columbia dot edu.

% Sizes for recovery
siz = size(p);
n = siz(1);
siz_p_min_orig = siz;
siz_p_min_orig(2) = 1;

% Check input
assert(siz(2) == 2, 'size(p, 2) must be 2!');
assert(all(p(:)) >= 0, 'p must be non-negative!');
if ~exist('sum_equals', 'var')
    sum_equals = 'prod'; 
else
    assert(ismember(sum_equals, {'prod', 'sum'}), ...
        'Unsupported sum_equals=%s\n', sum_equals);
end

% Flatten dim >= 3 for now.
p = reshape(p, siz(1), siz(2), []);

% Flattened sizes for preallocation
siz_p_min_flat = size(p);
siz_p_min_flat(1:2) = 1;

% Sum for normalization
p_ch = sum(p, 1);

% Normalize each column (will later revert)
p0 = p;
p = bml.math.nan0(bsxfun(@rdivide, p, p_ch));

% cumulative probability
c = cumsum(p, 1);

% cum_min(k) = cum(k,1) + cum(k,2) - cum(k,1) * cum(k,2)
p_min = sum(c, 2) - prod(c, 2);

% p_min = diff([0; cum_min], 1, 1)
p_min = max(diff([zeros(siz_p_min_flat); p_min], 1, 1), 0);

% p_1st(k,1) = p_min(k,1) * p0(k,1) / (p0(k,1) + p0(k,2))
p_1st = bsxfun(@times, p_min, nan0(bsxfun(@rdivide, p0, sum(p0, 2))));

% No p_1st if neither p(:,1) nor p(:,2).
any_p = any(p, 2);
p_1st = bsxfun(@times, p_1st, any_p);
% p_1st(any(isnan(p_1st),2) & ~any(isnan(p),2), :) = 0; % pre-vectorization

% DEBUG - to see what p_1st was like before normalization.
% p_1st_0 = p_1st; 
        
% Match the sum
switch sum_equals
    case 'sum'
        p_sum = p_ch(1,1,:) + p_ch(1,2,:);

        p_min = bsxfun(@times, ...
                    nan0(bsxfun(@rdivide, p_min, sum(p_min))), ...
                    p_sum);
    case 'prod'
        p_sum = p_ch(1,1,:) .* p_ch(1,2,:);

        p_min = bsxfun(@times, ...
                    nan0(bsxfun(@rdivide, p_min, sum(p_min))), ...
                    p_sum);
end

% Then conditionalize on p_sum
p_1st = bsxfun(@times, ...
            nan0(bsxfun(@rdivide, p_1st, sums(p_1st, [1, 2]))), ...
            p_sum);

% Special cases: columns that are all zeros.
ch10 = squeeze(~any(p(:,1,:),1));
ch20 = squeeze(~any(p(:,2,:),1));
ch120 = ch10 & ch20;

switch sum_equals
    case 'sum'
        p_min(:, 1, ch120) = 0;
        p_1st(:, :, ch120) = 0;

        p_min(:, 1, ch10 & ~ch120) = p(:,2,ch10 & ~ch120);
        p_1st(:, 1, ch10 & ~ch120) = 0;
        p_1st(:, 2, ch10 & ~ch120) = p(:,2,ch10 & ~ch120);

        p_min(:, 1, ch20 & ~ch120) = p(:,1,ch20 & ~ch120);
        p_1st(:, 1, ch20 & ~ch120) = p(:,1,ch20 & ~ch120);
        p_1st(:, 2, ch20 & ~ch120) = 0;
        
    case 'prod'
        p_min(:, 1, ch10 | ch20) = 0;
        p_1st(:, :, ch10 | ch20) = 0;
end

% DEBUG: p_1st should sum to p_min.
try
    assert_isequal_within(sum(p_1st,2), p_min, 1e-2, 'relative_tol', false);
catch err
    warning(err_msg(err));
    keyboard;
end

% Recover original size
p_min = reshape(p_min, siz_p_min_orig);