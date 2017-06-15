function varargout = intNonuni(varargin)
% INTNONUNI   Integral with nonuniform intervals of integrand.
%
% res = intNonuni(x, y, [op='mean'])
%
% op
%   right   : take right value in each interval as height
%   left    : take left value in each interval as height
%   mean    : mean of the above two.
[varargout{1:nargout}] = intNonuni(varargin{:});