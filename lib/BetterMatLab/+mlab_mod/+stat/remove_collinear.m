function X = remove_collinear(X)
% Using a part of MATLAB's regress().
% Warning is removed.

[n,ncolX] = size(X);

% Use the rank-revealing QR to remove dependent columns of X.
[Q,R] = qr(X,0);
if isempty(R)
    p = 0;
elseif isvector(R)
    p = double(abs(R(1))>0);
else
    p = sum(abs(diag(R)) > max(n,ncolX)*eps(R(1)));
end
if p < ncolX
    R = R(1:p,1:p);
    Q = Q(:,1:p);
end

X = Q*R;