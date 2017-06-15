function M = conv2_pad1(M, f)
% CONV2_PAD1  Same as conv2_pad but padding the first dimension.
%
% M = conv2_pad1(M, f)
%
% See also: conv2, conv2_pad

pad = size(f,1);

M = conv2([
    repmat(M(1,:), [pad, 1])
    M
    repmat(M(1,:), [pad, 1])
    ], f, 'same');

M = M((pad+1):(end-pad), :);