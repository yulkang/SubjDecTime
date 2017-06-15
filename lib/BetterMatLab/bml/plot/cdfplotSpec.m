function varargout = cdfplotSpec(x, varargin)
% CDFPLOTSPEC   Same as cdfplot() but can specify properties.

[h argout{1:max(nargout-1, 0)}] = cdfplot(x);

if ~isempty(varargin)
    [isSpec propCell] = isLineSpec(varargin{1});

    if isSpec
        set(h, propCell{:}, varargin{2:end});
    else
        set(h, varargin{:});
    end
end

varargout = [{h} argout];
end