function [a,b,c,d] = estSpline(y) % , updateN)
% function [a,b,c,d] = estSpline(y) % , updateN)
%
% See also: valSpline

persistent N N1 spMat % Dy Dy1 D D1 D2

if isempty(N) || N1~=size(y,1) 
    % ~2% speedup with the following. But less convenient.
    %   if isempty(N) || (nargin>1 && updateN) 
    
    N1  = size(y,1);
    N   = N1 - 1;
    
    % Construct equation matrix, which can be reused.
    % ref: http://mathworld.wolfram.com/CubicSpline.html, eq. (18)
    spMat = spdiags([ones(N1,1), zeros(N1,1)+4, ones(N1,1)], -1:1, N1,N1);
    spMat(1,1) = 2;
    spMat(N1,N1) = 2;
    spMat = spMat ./ 3;
end

Dy = [y(2)-y(1); y(3:N1)-y(1:(N-1)); y(N1)-y(N)];
D  = spMat \ Dy;

D1 = D(1:N);
D2 = D(2:N1);
Dy1 = diff(y);

a = y(1:N);
b = D1;
c = 3*Dy1 - 2*D1 - D2;
d = -2*Dy1 + D1 + D2;

