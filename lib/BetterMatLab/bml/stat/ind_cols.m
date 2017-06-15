function tf = ind_cols(v, ix_base)
% tf = ind_cols(v, ix_base)
%
% EXAMPLE:
% 
% >> ind_cols([1 2 3 2 1])
% ans =
%      0     0
%      1     0
%      0     1
%      1     0
%      0     0
%
% See also: glmfit

v_incl = unique(v(:));

if nargin >= 2
    v_incl = setdiff(v_incl, ix_base);
else
    v_incl = v_incl(2:end);
end

tf = bsxfun(@eq, v(:), v_incl(:)');