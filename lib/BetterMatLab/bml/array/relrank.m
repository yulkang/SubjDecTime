function r = relrank(varargin)
% r = relrank(varargin)
%
% r: between 0 and 1.

r = tiedrank(varargin{:}) / length(varargin{1});
