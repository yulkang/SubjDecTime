function M = cell_subsref(C, subs, uniform_output, err_hdl)
% M = cell_subsref(C, {subs1, ...}, [uniform_output = true, @(err,varargin) nan])

if nargin < 3, uniform_output = true; end
if nargin < 4, err_hdl = @(~,varargin) nan; end

M = cellfun(@(c) c(subs{:}), C, 'UniformOutput', uniform_output, ...
    'ErrorHandler', err_hdl);
