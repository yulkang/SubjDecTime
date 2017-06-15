function dst = copy_fields_ix(dst, ix0, src, varargin)
% dst = copy_fields_ix(dst, ix0, src, ...)
%
% 'fields', {}
% 'exclude', true
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.
S = varargin2S(varargin, {
    'fields', {}
    'exclude', true
    });
if ischar(ix0) && isequal(ix0, ':')
    ix0 = 1:numel(dst);
else
    assert(isnumeric(ix0));
end
n = numel(ix0);

if S.exclude
    fs = setdiff(fieldnames(src(1)), S.fields, 'stable');
    fs = fs(:)';
else
    fs = S.fields(:)';
end

for ii = 1:n
    ix = ix0(ii);
    
    for f = fs
        dst(ix).(f{1}) = src(ii).(f{1});
    end
end
end