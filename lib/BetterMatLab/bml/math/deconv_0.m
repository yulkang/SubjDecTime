function [q, r, a2] = deconv_0(b, a)
% [q, r, a2] = deconv_0(b, a)

ix = find(a, 1, 'first');
a2 = a(ix:end);

[q, r] = deconv(b, a2);
% q  = [zeros(ix,1); q(:)];
