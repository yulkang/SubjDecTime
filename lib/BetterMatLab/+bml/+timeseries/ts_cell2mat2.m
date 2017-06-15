function mat = ts_cell2mat2(c, varargin)
% mat = ts_cell2mat2(c, varargin)
%
% mat(tr, fr) = c{tr}(fr) % NaN if shorter than fr.
%
% OPTIONS
% -------
% 'truncate_st_fr', 0 % beginning before flip
% 'truncate_en_fr', 0 % end before flip
% 'flip', false

% 2017 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'truncate_st_fr', 0 % beginning before flip
    'truncate_en_fr', 0 % end before flip
    'flip', false
    'length', nan % give non-NaN to set to a particular length
    'pad_with', nan
    });

assert(iscell(c));
assert(iscolumn(c));
% assert(all(cellfun(@isrow, c)));

n = length(c);

if isscalar(S.truncate_st_fr)
    S.truncate_st_fr = zeros(n, 1) + S.truncate_st_fr;
end
if isscalar(S.truncate_en_fr)
    S.truncate_en_fr = zeros(n, 1) + S.truncate_en_fr;
end
c = arrayfun( ...
    @(v, st, en) v{1}(min(st+1, end):max(end - en, 1)), ...
    c, ...
    S.truncate_st_fr, ...
    S.truncate_en_fr, ...
    'UniformOutput', false);

if S.flip
    c = cellfun(@fliplr, c, 'UniformOutput', false);
end

mat = cell2mat2(c, S.pad_with);
if ~isnan(S.length)
    assert(isscalar(S.length));
    mat = bml.array.pad(mat, S.length);
end