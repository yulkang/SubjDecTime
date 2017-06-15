function varargout = concFields(varargin)
% CONCFIELDS    Concatenate struct fields along desired dimension.
%
% dst = concFields(dim, varargin);
%
% Example: 
%
% >> size(res(1).xy)
% ans: 2 5
%
% >> length(validTrial)
% ans: 1 50
% 
% >> xyAll = concFields(3, res(validTrial).xy);
% >> size(xyAll)
% ans: 2 5 50
[varargout{1:nargout}] = concFields(varargin{:});