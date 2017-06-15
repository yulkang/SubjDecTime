function r = exprndTrunc(mu, arg1, arg2)
% EXPRNDTRUNC   Truncated exponential distribution.
%
% r = exprndTrunc(mu, maxR)
% : r is sampled from exponential distribution with mean mu, truncated at maxR.
% 
% r = exprndTrunc(mu, minR, maxR)
% : r0 is sampled from exponential distribution with mean mu, 
%   truncated at maxR - minR. r is r0 + minR.
%   In summary, r has minimum minR, maximum maxR, and approximate mean minR + mu.

if nargin == 2    
    minR = 0;
    maxR = arg1;
else
    minR = arg1;
    maxR = arg2;
end

r = nan;

while ~(r <= maxR)
    % Generate uniform random values, and apply the exponential inverse CDF.
    r = -mu .* log(rand) + minR; % == expinv(U(0,1), mu) + minR
end