function dst = unpackCopy(dst, src, prefix, varargin)
% dst = unpackCopy(dst, src, prefix='', ...)
%
% Give NaN to prefix to force using inputname(src).
% 
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

if nargin < 3 || any(isnan(prefix)), prefix = inputname(2); end
S = varargin2S(varargin, {
    'fields', nan
    'excl'    false
    });

if isequal_nan(S.fields, nan)
    fields = fieldnames(src)';
elseif S.excl
    fields = setdiff(fieldnames(src)', S.fields, 'stable');
else
    fields = intersect(fieldnames(src)', S.fields, 'stable');
end

for ii = 1:length(fields)
    f = fields{ii};
    dst.(str_con(prefix, f)) = src.(f);
end
    