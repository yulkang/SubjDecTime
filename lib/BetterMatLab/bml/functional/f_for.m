function out = f_for(ix, f, argin, varargin)
% out = f_for(ix, f, argin)
if nargin < 3, argin = {}; end


for ii = ix
    if nargout > 0
        out(ii) = f(ix);
    else
        f(ix);
    end
end