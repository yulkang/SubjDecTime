function M = conv2_pad(M, f)
% CONV2_PAD  Convolution after padding with the same number at the end.
%
% M = conv2_pad(M, f)

M = pad_cut(conv2(pad_same(M, length(f)), f, 'same'), length(f));