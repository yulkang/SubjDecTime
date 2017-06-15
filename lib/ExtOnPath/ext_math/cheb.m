function [D, x] = cheb(N)
% Compute Chebyshev grid
%
% [D, x] = cheb(N)
%
% D : differentiation matrix
% x : Chebyshev grid
%
% from Spectral Methods in MATLAB, chapter 6.

if N == 0, D = 0; x = 1; return; end
x = cos(pi * (0:N)/N)';
c = [2; ones(N-1,1); 2].*(-1).^(0:N)';
X = repmat(x,1,N+1);
dX = X-X';
D = (c*(1./c)')./(dX+(eye(N+1))); % off-diagonal entries
D = D - diag(sum(D,2));            % diagonal entries