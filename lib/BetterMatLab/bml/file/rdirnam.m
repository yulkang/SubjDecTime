function [f, d] = rdirnam(varargin)
% [f, d] = rdirnam(varargin)
%
% f = {d.name};

d = rdir(varargin{:});

if nargout >= 1
    f = {d.name};
    f = f(:);
end