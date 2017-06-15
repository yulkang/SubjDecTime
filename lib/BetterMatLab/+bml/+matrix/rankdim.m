function rnk = rankdim(mat, dim)
% rnk = rankdim(mat, dim)
%
% EXAMPLE:
% >> magic(3)
% ans =
% 
%      8     1     6
%      3     5     7
%      4     9     2
% 
% >> bml.matrix.rankdim(magic(3),1)
% ans =
%      3     1     2
%      1     2     3
%      2     3     1
% 
% >> bml.matrix.rankdim(magic(3),2)
% ans =
%      3     1     2
%      1     2     3
%      2     3     1
%
% 2016 Yul Kang. hk2699 at columbia dot edu.
     
[~, ix] = sort(mat, dim);

if dim == 1
    n = size(mat, 1);
    for ii = size(mat, 2):-1:1
        rnk(ix(:,ii),ii) = (1:n)';
    end
    
elseif dim == 2
    n = size(mat, 2);
    for ii = size(mat, 1):-1:1
        rnk(ii,ix(ii,:)) = (1:n);
    end    
    
else
    error('dim=%d not implemented yet!', dim);
end
