function m = cell2mat2(c, varargin)
% CELL2MAT2  cell2mat with padding. Return original if non-cell. Enforces each element to be a horizontal vector.
%
% m = cell2mat2(c, ...)
%
% OPTIONS:
% 'pad_with', nan
% 'enforce_double', true
% 'min_width', 0
%
% EXAMPLE:
% >> cell2mat2({[1 2 3], [ 1 3], 1, [], [ 1 2 3 4]})
% ans =
%      1     2     3   NaN
%      1     3   NaN   NaN
%      1   NaN   NaN   NaN
%    NaN   NaN   NaN   NaN
%      1     2     3     4

% 2016 Yul Kang. hk2699 at columbia dot edu.

if ~iscell(c), m = c; return; end

S = varargin2S(varargin, {
    'pad_with', nan
    'enforce_double', true
    'min_width', 0
    });

l = cellfun(@length, c);
max_l = max(max(l), S.min_width);

if S.enforce_double
    c2 = cellfun(@(cc) ...
        [double(cc(:)'), zeros(1, max_l - length(cc)) + S.pad_with], ...
        c, ...
        'UniformOutput', false);
else
    c2 = cellfun(@(cc) ...
        [cc(:)', zeros(1, max_l - length(cc)) + S.pad_with], ...
        c, ...
        'UniformOutput', false);
end
m  = cell2mat(c2(:));