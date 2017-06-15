function varargout = reshape2vec(varargin)
% RESHAPE2VEC   Reshape an array into a vector on the given dimension.
%
% Example: 
%   reshape2vec(zeros(2,2), 2)
% ans =
%   [0 0 0 0]
%
% See also RESHAPE, DIMVEC, VECONDIM.

[varargout{1:nargout}] = reshape2vec(varargin{:});