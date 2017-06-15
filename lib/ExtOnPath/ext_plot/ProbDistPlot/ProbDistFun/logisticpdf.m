function y = logisticpdf(t,U,S)
%LOGISTICPDF Logistic probability density function.
%   Y = LOGISTICPDF(t,U,S) returns the PDF of the Logistic Distribution
%   with location parameter U and scale parameter S, evaluated at the
%   values in t.  
%
%   The size of Y is the common size of the input arguments.  A scalar input
%   functions as a constant matrix of the same size as the other inputs.  Each
%   element of Y contains the probability density evaluated at the
%   corresponding elements of the inputs.
%   
%  Reference: Webb, W.M, O'Connor,A.N, Modarres, M, Mosleh, A , Probability Distribution Functions Used In Reliability
%  Engineering, Reliability Information Analysis Center, New York, 2010
%
%   See also LOGISTICCDF, LOGISTICHAZ.
%
%   Author: Andrew O'Connor, AndrewNOConnor(AT)gmail.com

if nargin<1
    error('logisticpdf:TooFewInputs','Insufficient number of parameters.');
end
if nargin < 2
    U = 0;
end
if nargin < 3
    S = 1;
end

% Return NaN for out of range parameters.
S(S <= 0) = NaN;

try
    z = (t-U)./S;
    y = exp(z)./(S.*(1+exp(z)).^2);
catch
    error('stats:logisticpdf:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
