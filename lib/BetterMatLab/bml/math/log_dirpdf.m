function log_p = log_dirpdf(x, a)
% Natural log of Dirichlet pdf.
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

log_p = gammaln(sum(a,2)) - sum(gammaln(a), 2) + sum(bsxfun(@times, a-1, log(x)), 2);