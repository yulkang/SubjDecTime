function varargout = catVecs(varargin)
% mat = catVecs(cellVec, fillWith = nan)
%
% Concatenate cell array of vectors of different lengths
[varargout{1:nargout}] = catVecs(varargin{:});