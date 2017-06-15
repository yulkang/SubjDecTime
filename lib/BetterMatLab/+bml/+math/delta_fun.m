function varargout = delta_fun(varargin)
% delta function, linearly interpolated if necessary.
%
% tf = delta_fun(v, vec, [min_val = 0, normalize = false])
%
% v   should be a numeric scalar or array within the range of vec.
% vec should be a monotonically increasing vector.
% 
% If v is an array, tf is the sum of the delta functions.
%
% Multiplying the step size (e.g., dt or dx) can be more accurate than 
% normalizing by sum.
[varargout{1:nargout}] = delta_fun(varargin{:});