function res = semBino(n1, n)
% res = semBino(n1, n)
% 
% n1    : number of 1's.
% n     : number of 0's plus 1's.
% res   : SEM of a trial resulting in 1.
%
% n1 and n can be a scalar or an array. size(res) will match size(n1+n).
%
% See also: SEM

res = (n1 .* (1-n1./n).^2 + (n-n1) .* (n1./n).^2) ./ (n-1) ./ sqrt(n);

end