function ix = ix_enforce(ix, siz)
% ix = ix_enforce(ix, arg)
%
% Enforce into indices regardless of ix's type - function handle, logical, numeric, or ':'.
%
% See also: data, PsyLib
%
% 2013 (c) Yul Kang. See help PsyLib for the license.

if ischar(ix) && ~isequal(ix, ':')
    ix = str2func(ix);
end

if isa(ix, 'function_handle')
    ix = ix(siz);
elseif islogical(ix)
    return;
elseif nargin >= 2 && ~isempty(siz)
    ix = ix2py(ix, siz);
end
% If none of above, return as is.
