function res = rep2fit_strict(src, sizRes, varargin)
% res = rep2fit_strict(src, sizRes, varargin)
%
% Equivalent to rep2fit(..., 'assert_multiple', true)
res = rep2fit(src, sizRes, 'assert_multiple', true, varargin{:});