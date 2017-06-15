function [res, n_consec, pos_head, pos_tail] = consecutive(src)
% consecutive  Number of consecutive nonzeros in a vector.
%
% [res, n_consec, pos_head, pos_tail] = consecutive(src)
%
% EXAMPLE:
% >> [res, n_consec, pos_head, pos_tail] = consecutive([1 0 1 1 1 0 0 1])
% res =
%      1     0     1     2     0     0     0     1
% n_consec =
%      1     3     1
% pos_head =
%      1     3     8
% pos_tail =
%      1     5     8

siz = size(src);

src = [0, src(:)' ~= 0, 0];

res = cumsum(src);

tf_series_head = [false, diff(src) ==  1];
tf_series_tail = [false, diff(src) == -1];

to_subtract_head = res(tf_series_head) - 1;

to_subtract = zeros(size(res));
to_subtract(tf_series_head) = to_subtract_head;
to_subtract(tf_series_tail) = -to_subtract_head; % So that the shift don't accumulate.

res = res - cumsum(to_subtract);
res = res .* src;

res = reshape(res(2:(end-1)), siz);

if nargout >= 2
    pos_head = find(tf_series_head) - 1;
    pos_tail = find(tf_series_tail) - 2;
    
    n_consec = res(pos_tail);
end