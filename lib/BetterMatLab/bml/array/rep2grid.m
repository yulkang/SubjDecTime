function varargout = rep2grid(varargin)
% Give all combinations of inputs.
%
% [xs, ys, ..] = rep2grid(x, y, ...)
    
n = cellfun(@numel, varargin);

ndim = length(n);
ns   = arrayfun(@(c) 1:c, n, 'UniformOutput', false);

[ix{1:ndim}] = ndgrid(ns{:});

varargout = cell(1,nargout);
for ii = 1:nargout
    varargout{ii} = vVec(varargin{ii}(ix{ii}(:)));
end