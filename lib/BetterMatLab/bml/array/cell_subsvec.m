function varargout = cell_subsvec(v, Cs, err_hdl)
% [cell_subsref(C1,v,err_hdl), ...] = cell_subsvec(v, {C1, C2, ...}, err_hdl)

if nargin < 3
    err_hdl = @(~,varargin) nan;
end

n_C = length(Cs);
varargout = cell(1,n_C);

for ii = 1:n_C
    
%     varargout{ii} = zeros(length(v),1);
%     
%     for jj = 1:length(v)
%         varargout{ii}(jj) = Cs{ii}{jj}(v(jj));
%     end
    
    varargout{ii} = arrayfun(@(vv,CC) double(CC{1}(vv)), ...
        v, Cs{ii}, 'ErrorHandler', err_hdl);
end

