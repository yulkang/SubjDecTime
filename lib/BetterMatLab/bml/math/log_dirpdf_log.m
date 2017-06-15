function p = log_dirpdf_log(x, a)
% Natural log of Dirichlet pdf, given log(x).
% 
% log_p = log_dirpdf(x, a);
%
% x : N x K matrix.
% a : N x K matrix. Alpha.
% log_p : N x 1 vector.
%
% See also: dir_xmat, dirpdf
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

p = gammaln(sum(a,2)) - sum(gammaln(a), 2) + sum(bsxfun(@times, a-1, x), 2);