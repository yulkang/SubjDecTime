function dst = concFields(dim, varargin)
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

reshapeCell = cell(1, max(2, dim));
reshapeCell(setdiff(1:max(2,dim), dim)) = {1};

dst = cell2mat(reshape(varargin, reshapeCell{:}));
