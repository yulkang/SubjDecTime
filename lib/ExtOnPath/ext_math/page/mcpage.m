function[p,P] = mcpage(x,b) 
% MCPAGE     MC approximation of Page test statistic's significance
% INPUTS   : x - n*k data matrix, subjects in rows, treatments in cols
%            b - number of within-subject permutations 
% OUTPUTS  : p - value of  Page test statistic for the original layout 
%            P - b*1 matrix of statistic values in permutation samples
% EXAMPLE  : (From Hollander and Wolfe (1973), p. 147)
%            x = [7.46 7.17 7.76 8.14 7.63
%                 7.68 7.57 7.73 8.15 8.00
%                 7.21 7.80 7.74 7.87 7.93];
%            [p,P] = mcpage(x,1000);
%            mean(p <= P)  % one-sided test against H1: t(k+1) >= t(k)
%            %(Exact value reported by StatXact, p = 0.0025)
% SEE ALSO : PAGE, RANDPERG
% AUTHOR   : Dimitri Shvorob, dimitri.shvorob@vanderbilt.edu, 3/25/07

if nargin < 1
   error('Input argument "x" is undefined')
end
if nargin < 2
   error('Input argument "b" is undefined') 
end
if ~isnumeric(x)
   error('Input argument "x" must be numeric')
end
if ~isnumeric(b)
   error('Input argument "b" must be numeric')
end
if ndims(x) ~= 2
   error('Input argument "x" must be a matrix')
end
if ~isnumeric(b)
   error('Input argument "b" must be numeric')
end  
if ~isscalar(b)
   error('Input argument "b" must be a scalar')
end  
if b ~= floor(b) 
   error('Input argument "b" must be an integer')
end
if b <= 0
   error('Input argument "b" must be positive')
end
[n,k] = size(x);
if n == 1
   warning('Only one subject present in "x"')     %#ok
end
if k == 1
   warning('Only one treatment present in "x"')   %#ok
end
[n,k] = size(x);
[p,r] = page(x);
rvec = reshape(r',n*k,1);
cvec = kron((1:n)',ones(k,1));
P = nan(b,1);
for i = 1:b
   x = randperg(rvec,cvec);
   u = reshape(x',k,n)';
   P(i) = page(u);
end
