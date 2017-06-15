function s = pval2marks(p, varargin)
% s = pval2marks(p, ...)
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'thres', [0.1, 0.05, 0.01, 0.001]
    'marks', {'+', '*', '**', '***'};
    });
assert(isnumeric(S.thres) && isvector(S.thres));
assert(issorted(flip(S.thres(:))));
assert(iscell(S.marks) && isvector(S.marks));
assert(all(cellfun(@ischar, S.marks(:))));
assert(numel(S.thres) == numel(S.marks));

if isempty(p)
    if iscell(p)
        s = {};
    else
        s = '';
    end
    return;
    
elseif ~isscalar(p)
    s = arrayfun(@pval2marks, p, varargin{:}, ...
        'UniformOutput', false);
    return;
end

ix = find(p < S.thres, 1, 'last');
if isempty(ix)
    s = '';
else
    s = S.marks{ix};
end