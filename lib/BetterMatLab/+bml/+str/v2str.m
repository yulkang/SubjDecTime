function s = v2str(v, varargin)
% Shortcut to bml.str.Serializer.convert.

s = bml.str.Serializer.convert(v, varargin{:});
end