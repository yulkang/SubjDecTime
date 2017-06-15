classdef CommonWsFiltCond < Fit.Common.CommonWorkspace
properties (Dependent)
    ad_cond_incl
end
methods
    function W = CommonWsFiltcond(varargin)
        if nargin > 0
            W.init(varargin{:});
        end
    end
    function v = get.ad_cond_incl(W)
        v = W.Data.ad_cond_incl;
    end
    function set.ad_cond_incl(W, v)
        W.Data.ad_cond_incl = v;
    end
    function fs = get_file_fields(W)
        fs = [
            W.get_file_fields@Fit.Common.CommonWorkspace
            {
            'ad_cond_incl', 'dif'            
            }
            ];
    end
end
end