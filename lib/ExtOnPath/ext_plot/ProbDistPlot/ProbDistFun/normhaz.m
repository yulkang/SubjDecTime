function y = normhaz(t,mu,sigma)
%NORMHAZ Normal hazard rate.
%   Y = NORMHAZ(t,MU,SIGMA) returns the hazard function of the Normal distribution
%   with scale parameter MU and shape parameter SIGMA, evaluated at the values in t.  
%
%   The size of Y is the common size of the input arguments.  A scalar input
%   functions as a constant matrix of the same size as the other inputs.  Each
%   element of Y contains the probability density evaluated at the
%   corresponding elements of the inputs.
%   
%  Reference: Webb, W.M, O'Connor,A.N, Modarres, M, Mosleh, A , Probability Distribution Functions Used In Reliability
%  Engineering, Reliability Information Analysis Center, New York, 2010
%
%   See also NORMPDF, NORMCDF, NORMFIT, NORMINV, NORMLIKE, NORMRND, NORMSTAT.
%
%   Author: Andrew O'Connor, occawen(AT)gmail.com

if nargin<1
    error('normhaz:TooFewInputs','Insufficient number of parameters.');
end
if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

%lnpdf = normpdf(t,mu,sigma);
%lncdf = normcdf(t,mu,sigma);
z = (t - mu) ./ sigma; 

lnpdf = exp(-0.5 * (z).^2) ./ (sqrt(2*pi) .* sigma);
lncdf = .5 .* (1 + erf(z ./ sqrt(2)));

try
    y = lnpdf ./(1-lncdf); 
    
catch
    error('stats:normhaz:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

