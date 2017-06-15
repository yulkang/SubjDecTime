function varargout = dimVec(varargin)
% DIMVEC    Make a vector useful for REPMAT or RESHAPE.
%
% vec = dimVec(cDim, [v = 1, nDim = max(cDim,2), vOthers = 0])
% 
% Example:
%   dimVec(1)
% ans =
%   [1 0]
%
% Example:
%   dimVec(3)
% ans =
%   [0 0 1]
%
% Example:
%   dimVec(2, 7, 5, 1)
% ans =
%   [1 7 1 1 1]
%
%
% vec = dimVec(cDim, v, nDim, vOthers, true)
% 
% Example:
%   dimVec(2, 7, 5, [], true)
% ans =
%   {[], 7, [], [], []}
%
%
% See also REPMAT, RESHAPE, VECONDIM.
[varargout{1:nargout}] = dimVec(varargin{:});