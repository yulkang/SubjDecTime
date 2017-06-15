function varargout = choose_batch(varargin)
% [bat, ix, n] = choose_batch({{arg1_1, arg1_2, ...}, {...}}, default_ix, options)
%
% DEFAULT_IX:
%   Numeric, string expression or a function handle that gets n (number of batches).
%   Give empty (default) or ':' to choose all on empty answer.
%   Give nan to enforce nonempty answer.
%
% Enter %STRING for escape strings. 
%
% OPTIONS:
% 'querry',             ''
% 'default_to_prev',    true
% 'nvpair',             true % Infer name-value pair format from R x 2 cell arrays.
[varargout{1:nargout}] = choose_batch(varargin{:});