function y=stderr(x,dim)
%  y=stderr(x,dim)
% calculates standard error of a vector or matrix along a dimension 
% (default  dim=1)

if nargin < 2 ,
    dim = 1;
end

if isvector(x)
    x=shiftdim(x);
end

y=nanstd(x,0,dim)./sqrt(sum(~isnan(x),dim));

