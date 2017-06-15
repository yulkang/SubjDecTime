function y = bspdf(t,A,B)
%BSPDF Birnbaum-Saunders (Fatigue Life) probability density function.
%   Y = BSPDF(t,A,B) returns the PDF of the Birnbaum-Saunders Distribution
%   with shape parameter A and scale parameter B, evaluated at the
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
%   See also BSPDF, BSHAZ.
%
%   Author: Andrew O'Connor, AndrewNOConnor(AT)gmail.com

if nargin<1
    error('bspdf:TooFewInputs','Insufficient number of parameters.');
end
if nargin < 2
    A = 1;
end
if nargin < 3
    B = 1;
end

% Return NaN for out of range parameters.
A(A <= 0) = NaN;
B(B <= 0) = NaN;

try
    z = (sqrt(t./B)- sqrt(B./t))./A;
    y = normpdf(z).*(sqrt(t./B)+ sqrt(B./t))./(2.*t.*A);
catch
    error('stats:bspdf:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end

y(t < 0) = 0;
