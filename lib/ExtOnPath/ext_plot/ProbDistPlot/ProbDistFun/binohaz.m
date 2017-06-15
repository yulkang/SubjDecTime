function y = binohaz(k,N,P)
%BINOHAZ Binomial hazard rate.
%   Y = BINOHAZ(k,N,P) returns the hazard function of the Binomial distribution
%   with N trials with probability P of success. 
%
%   The size of Y is the common size of the input arguments.  A scalar input
%   functions as a constant matrix of the same size as the other inputs.  Each
%   element of Y contains the probability density evaluated at the
%   corresponding elements of the inputs.
%   
%  Reference: Webb, W.M, O'Connor,A.N, Modarres, M, Mosleh, A , Probability Distribution Functions Used In Reliability
%  Engineering, Reliability Information Analysis Center, New York, 2010
%
%   See also BINOPDF, BINOCDF, BINOGAMFIT, BINOINV, BINOLIKE, BINORND, BINOSTAT, PDF.
%
%   Author: Andrew O'Connor, occawen(AT)gmail.com

if nargin<1
    error('binohaz:TooFewInputs','Insufficient number of parameters.');
end
if nargin < 2
    N = 10;
end

if nargin < 3
    P = 0.5;
end

% Return NaN for out of range parameters.
N(N <= 0) = NaN;
P(P<0|P>1) = NaN;
y = 0;

try
y(k<=N|k>=0) = binopdf(k(k<=N|k>=0),N,P)./(binopdf(k(k<=N|k>=0),N,P)+(1-binocdf(k(k<=N|k>=0),N,P)));
    
catch
    error('stats:binohaz:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
y(isnan(y))=0;
