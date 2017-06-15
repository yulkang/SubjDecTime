function s = S2s(S, fields, to_excl)
% s = S2s(S, [fields, to_excl = false])

C = struct2cell(S)';
f = fieldnames(S)';

if nargin < 3 || isempty(to_excl), to_excl = false; end

if to_excl
    if nargin >= 2 && ~isempty(fields)
        [f,ix] = setdiff(f, fields, 'stable');
        C = C(ix);
    end
else
    if nargin >= 2 && ~isempty(fields)
        [f,ix] = intersect(f, fields, 'stable');
        C = C(ix);
    end
end
n = length(f);

s = '';
for ii = 1:n
    if ischar(C{ii})
        s = [s, sprintf('%s=''%s'',', f{ii}, C{ii})]; %#ok<AGROW>
    elseif isnumeric(C{ii}) || islogical(C{ii})
        s = [s, sprintf('%s=%g,', f{ii}, C{ii})]; %#ok<AGROW>
    elseif isa(C{ii}, 'function_handle')
        s = [s, sprintf('%s=%s,', f{ii}, char(C{ii}))]; %#ok<AGROW>
    else
        warning('Field %s (class = %s) cannot be converted to string!', ...
            f{ii}, class(C{ii}));
    end 
end

if ~isempty(s)
    s = s(1:(end-1));
end