function in = isInCircle(xy1, xy2, r)
    % in = isInCircle(xy1, xy2, r)
    %
    % Returns in(k), which is true when xy1(:,k) is within r(k) from xy2(:,k).
    %
    % xy1: 2 x (N or 1) matrix.
    % xy2: 2 x (N or 1) matrix.
    % r  : 1 x (N or 1) vector.
    % in : N x 1 matrix.

    in = bsxfun(@lt, sum(bsxfun(@minus, xy1, xy2) .^ 2, 1), r.^2);
end