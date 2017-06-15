function y = modwblhaz(t,A,B,L)
%MODWBLHAZ Modified Weibull Distribution hazard rate function.
%   Y = MODWBLHAZ(t,A,B,L) returns the hazard rate of the Modified Weibull Distribution
%   (Bathtub Curve) with scale parameter A and L and shape parameter B, evaluated at the
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
%   See also MODWBLPDF, MODWBLCDF.
%
%   Author: Andrew O'Connor, AndrewNOConnor(AT)gmail.com

if nargin<1
    error('modwblhaz:TooFewInputs','Insufficient number of parameters.');
end
if nargin < 2
    A = 1;
end
if nargin < 3
    B = 0.5;
end
if nargin < 4
    L = 1;
end

% Return NaN for out of range parameters.
A(A <= 0) = NaN;
B(B < 0) = NaN;
L(L <= 0) = NaN;

try
    y = A.*(B+L.*t).*t.^(B-1).*exp(L.*t);
catch
    error('stats:modwblhaz:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

y(t < 0) = 0;
