function [loss, dim, thres] = dynamic_stump_uni(x, y, w)
% Finds an optimal threshold for decision stump in O(NM log N) with DP
% (dynamic programming).
% This is a variant of dynamic_stump that allows 
% only one direction of comparison (x >= thres cateogorized as y = 1)
%
% USAGE
% -----
% [loss, dim, thres, sgn] = DYNAMIC_STUMP_UNI(x, y, w)
%
% OBJECTIVE
% ---------
% Find (dim, thres, sgn) that minimizes
%     loss = w(dim) 
%          * sum(abs(y( sign1(x(:,dim) > thres) ~= sign1(y > 0) )))
% Here,
%     sign1(y(S)) is the actual category of a sample S,
%         where sign1(r) is 1 for r >= 0 and -1 otherwise;
%     sign1(x(S,dim) - thres) is the proposed category;
%     abs(y(S)) is the weight of the sample;
%     w(dim) is the weight of the dimension.
%
% INPUT
% -----
% x : An N * M matrix. x(S, D) is the value of the sample S on dimension D.
% y : An N * 1 vector. y(S) = category(S) * weight(S), where
%     category(S) is either -1 or 1, and 
%     weight(S) > 0 is the loss for sample S being miscategorized.
% w : An 1 * M vector. w(D) is the weight of the dimension D,
%     as needed in AdaBoost.
%     If omitted or empty, it is considered 1/M.
%
% OUTPUT
% ------
% loss : The minimal loss.
% dim : The dimension that achieves the minimal loss.
% thres : An optimal threshold that achieves the minimal loss.

% Note: I proposed this algorithm during a discussion time of the
% Statistical Machine Learning class in Fall 2015, and Professor
% John Cunningham helpfully formalized and implemented the algorithm in R
% in one of the homework solutions. 
%
% I implemented the algorithm in MATLAB and Python, and extended the
% algorithm to allow weighting of each samples
% (in addition to dimensions) with the absolute value of y.
% 
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

persistent x0 y0 loss1 thres1

% Check sizes and values.
assert(ismatrix(x));
n_dim = size(x, 2);
n_samp = size(x, 1);

assert(iscolumn(y) && length(y) == n_samp);

% Fill in w.
if nargin < 3 || isempty(w)
    w = ones(1, n_dim) / n_dim;
else
    assert(isrow(w));
    assert(length(w) == n_dim);
end

% Compute loss1 and thres1 only for new data.
if ~isequal(x, x0) || ~isequal(y, y0)
    x0 = x;
    y0 = y;
    
    % Loss on one side.
    y_pos = (y > 0) .* abs(y);
    y_neg = (y < 0) .* abs(y);

    % For dimensions with a constant value,
    % the loss before weighting is either sum(y_pos) or sum(y_neg).
    sum_y_pos = sum(y_pos);
    sum_y_neg = sum(y_neg);
    if sum_y_pos > sum_y_neg
        sgn_const_dim = 1;
        loss_const_dim = sum_y_neg;
    else
        sgn_const_dim = -1;
        loss_const_dim = sum_y_pos;
    end

    % Variables for results within each dimension.
    loss1 = zeros(1, n_dim);
    thres1 = zeros(1, n_dim);
    sgn1 = zeros(1, n_dim);

    % Find the best threshold for each dim.
    for dim = 1:n_dim
        % Sort: O(n_samp * log(n_samp))
        [x1, ix] = sort(x(:,dim));
        y1_pos = y_pos(ix);
        y1_neg = y_neg(ix);

        % We need to check only at the points where x1 changes.
        dx = diff(x1);
        ix_dx = find(dx);

        % If there is only one value, the optimal threshold is simply
        % below or above that value, depending on sum(y).
        if isempty(ix_dx)
            sgn1(dim) = sgn_const_dim;
            loss1(dim) = loss_const_dim;
            thres1(dim) = x1(1) - sgn_const_dim;
            continue;
        end

        % We only need four sweeps of cumsum to calculate all relevant
        % losses.
        cum_y1_pos_for = cumsum(y1_pos(1:(end-1)));
        cum_y1_neg_rev = cumsum(y1_neg(2:end), 'reverse');

        % The loss for thresholds in each direction is simply 
        % the sum of the cumsums.
        loss_neg = cum_y1_pos_for + cum_y1_neg_rev;

        % When there are duplicates in x1, we only need to consider 
        % the cumsum after all duplicates are considered. 
        % Those locations are exactly where ix_dx points to.
        loss_neg_at_dx1 = loss_neg(ix_dx);

        % Find the minimum loss.
        min_loss_neg = min(loss_neg_at_dx1);
        ix_min_loss_neg = find(loss_neg_at_dx1 == min_loss_neg, 1, 'last');

        loss1(dim) = min_loss_neg;
        ix_among_all = ix_dx(ix_min_loss_neg);
        thres1(dim) = (x1(ix_among_all) + x1(ix_among_all + 1)) / 2;
    end
end

% Weight optimal loss in each dimension and find the minimum.
[loss, dim] = min(loss1 .* w);
thres = thres1(dim);
end