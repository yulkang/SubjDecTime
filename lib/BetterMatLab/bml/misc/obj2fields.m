function S = obj2fields(varargin)
% S = obj2fields(obj1, obj2, ...)
%
% S.(obj1) = struct(obj1);

n = nargin;

for ii = 1:n
    f = inputname(ii);
    
    S.(f) = struct(varargin{ii});
end