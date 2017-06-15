function y = lognhaz(t,mu,sigma)
%LOGNHAZ Lognormal hazard rate.
%   Y = LOGNHAZ(t,MU,SIGMA) returns the hazard function of the Lognormal distribution
%   with scale parameter MU and shape parameter SIGMA, evaluated at the values in t.  
%
%   The size of Y is the common size of the input arguments.  A scalar input
%   functions as a constant matrix of the same size as the other inputs.  Each
%   element of Y contains the probability density evaluated at the
%   corresponding elements of the inputs.
%
%                
%                phi(z)            where:  z = ln(t) - MU
%   h(t) = ----------------                   ----------
%          t.SIGMA[1 - Phi(z)]                  SIGMA
%                                        Phi = standard normal CDF
%                                        phi = standard normal PDF
%
%  ------------------------------------------------------
%  |  VAR  |       NAME          | DEFAULT |    BOUND     |
%  ------------------------------------------------------
%  |   t   | Time or Random Var  |         |   t >= 0     |
%  ------------------------------------------------------
%  |   MU  | Scale Para          |    0    |              |
%  ------------------------------------------------------
%  | SIGMA | Shape Para          |    1    | SIGMA > 0    |
%  ------------------------------------------------------
%   
%  Reference: Webb, W.M, O'Connor,A.N, Modarres, M, Mosleh, A , Probability Distribution Functions Used In Reliability
%  Engineering, Reliability Information Analysis Center, New York, 2010
%
%   See also LOGNPDF, LOGNCDF, LOGNFIT, LOGNINV, LOGNLIKE, LOGNRND, LOGNSTAT.
%
%   Author: Andrew O'Connor, occawen(AT)gmail.com

if nargin<1
    error('lognhaz:TooFewInputs','Insufficient number of parameters.');
end
if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;
t(t<0) = 0;

try
    z = (log(t) - mu) ./ sigma;  
    
catch
    error('stats:lognhaz:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

lnpdf = exp(-0.5 * (z).^2) ./ (t .* sqrt(2*pi) .* sigma);
lncdf = .5 .* (1 + erf(z ./ sqrt(2)));
y = lnpdf ./(1-lncdf);
