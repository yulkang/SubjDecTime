function t = continTab(a, b)
% t = continTab(a, b)
% 
% a, b: logical vectors (0 or 1)
% t   : 2 x 2 matrix where t(I,J) is the count of (a==(I-1)) & (b==(J-1)).
%
% See alo CHISQUARECONT, FEXACT

t = zeros(2,2);

for ii = 0:1
    for jj = 0:1
        t(ii+1,jj+1) = nnz((a==ii) & (b==jj));
    end
end
