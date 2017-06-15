function y = wblhaz(t,A,B)
%WBLHAZ Weibull hazard rate.
%   Y = WBLHAZ(t,A,B) returns the hazard function of the Weibull distribution
%   with scale parameter A and shape parameter B, evaluated at the
%   values in t.  
%
%   The size of Y is the common size of the input arguments.  A scalar input
%   functions as a constant matrix of the same size as the other inputs.  Each
%   element of Y contains the probability density evaluated at the
%   corresponding elements of the inputs.
%
%                [B-1]
%          B /t\^
%   h(t) = -| - |
%          A \A/ 
%
%  ------------------------------------------------------
%  | VAR |       NAME          | DEFAULT |    BOUND     |
%  ------------------------------------------------------
%  |  t  | Time or Random Var  |         |   t >= 0     |
%  ------------------------------------------------------
%  |  A  | Alpha - Scale Para  |    1    |   A > 0      |
%  ------------------------------------------------------
%  |  B  | Beta - Shape Para   |    1    |   B > 0      |
%  ------------------------------------------------------
%   
%  Reference: Webb, W.M, O'Connor,A.N, Modarres, M, Mosleh, A , Probability Distribution Functions Used In Reliability
%  Engineering, Reliability Information Analysis Center, New York, 2010
%
%   See also WBLPDF, WBLCDF, WBLFIT, WBLINV, WBLLIKE, WBLRND, WBLSTAT, PDF.
%
%   Author: Andrew O'Connor, occawen(AT)gmail.com

if nargin<1
    error('wblhaz:TooFewInputs','Insufficient number of parameters.');
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
    z = t ./ A;

    % Negative data would create complex values when B < 1, potentially
    % creating spurious NaNi's in other elements of y.  Map them to the far
    % right tail, which will be forced to zero.
    z(z < 0) = Inf;
    
catch
    error('stats:wblhaz:InputSizeMismatch',...
          'Non-scalar arguments must match in size.');
end
y = z.^(B-1) .* B ./ A;

y(t < 0) = 0;
