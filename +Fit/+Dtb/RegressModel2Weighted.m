classdef RegressModel2Weighted < FitWorkspace
properties
    x = []; % (n,1)
    y = []; % (n,1)
    cov = {}; % {n,1}(2,2)
end
properties (Dependent)
    slope
    offset
end
methods
    function W = RegressModel2Weighted(varargin)
        if nargin > 0
            W.init(varargin{:});
        end
    end
end
end