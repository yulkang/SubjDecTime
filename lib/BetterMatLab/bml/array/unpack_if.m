function varargout = unpack_if(to_unpack, S, varargin)
% UNPACK_IF - Conditional assignment from struct field or default value.
%
% v             = unpack_if(tf, S, field_name, val)
% [v1, v2, ...] = unpack_if(tf, S, field_name1, val1, [field_name2, val2, ...])
%
% If tf is true and S.(field_name) exists, v = S.(field_name).
% Otherwise, v = val.
%
% See also: unpackStruct

varargout = cell(1,nargout);

for ii = 1:nargout
    if to_unpack && isfield(S, varargin{ii*2-1})
        varargout{ii} = S.(varargin{ii*2-1});
    else
        varargout{ii} = varargin{ii*2};
    end
end