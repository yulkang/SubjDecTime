function varargout = batch_fun(varargin)
% [out, succ, errs] = batch_fun(fun, {{inp1_1, inp1_2, ...}, {inp2_1, ...}, ...}, varargin)
%
% OPTIONS
% -------
% 'use_parfor',   false
% 'out_names',    {}
% 'nargout',      1
% 'catch',        false
[varargout{1:nargout}] = batch_fun(varargin{:});