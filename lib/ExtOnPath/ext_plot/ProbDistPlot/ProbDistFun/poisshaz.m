function y = poisshaz(k,A)
%POISSHAZ Poisson hazard rate.
%   Y = POISSHAZ(k,A) returns the hazard function of the Poisson distribution
%   with shape parameter A evaluated at the values in t. 
%
%   The size of Y is the common size of the input arguments.  A scalar input
%   functions as a constant matrix of the same size as the other inputs.  Each
%   element of Y contains the probability density evaluated at the
%   corresponding elements of the inputs.
%   
%  Reference: Webb, W.M, O'Connor,A.N, Modarres, M, Mosleh, A , Probability Distribution Functions Used In Reliability
%  Engineering, Reliability Information Analysis Center, New York, 2010
%
%   See also POISSPDF, POISSCDF, POISSGAMFIT, POISSINV, POISSLIKE, POISSRND, POISSSTAT, PDF.
%
%   Author: Andrew O'Connor, occawen(AT)gmail.com

if nargin<1
    error('poisshaz:TooFewInputs','Insufficient number of parameters.');
end
if nargin < 2
    A = 1;
end
% rowv = 0;
% %if t is a row vector, we transpose it.
% if size(k,1)==1 && size(k,2) > 1
%     k = k';
%     rowv = 1;
% end

% Return NaN for out of range parameters.
A(A <= 0) = NaN;

% j = repmat(1:max(k), length(k), 1);
% mask = j > repmat(k, 1, max(k));
% j(mask) = 0;
% j_sum = A.^j./factorial(j);
% j_sum(mask) = 0;
% j_sum = sum(j_sum, 2);

try
%y = (1 + (factorial(k)./A.^k).*(exp(A)-1-j_sum)).^(-1);
y = poisspdf(k,A)./(1-poisscdf(k,A)+poisspdf(k,A));
    
catch
    error('stats:poisshaz:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
% y(k < 0) = 0;
% if rowv
%         y = y';
% end
