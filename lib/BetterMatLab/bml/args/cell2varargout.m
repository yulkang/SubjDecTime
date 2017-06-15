function varargout = cell2varargout(C, n_out)
% varargout = cell2varargout(C, n_out = nargout)
if ~exist('n_out', 'var')
    n_out = nargout;
end

varargout(1:n_out) = C(1:n_out);