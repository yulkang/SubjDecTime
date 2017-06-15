function v = circshiftpad(pad, v, sh, varargin)
% v = circshiftpad(pad, v, sh, varargin)

assert(iscolumn(v)); % for now
len = length(v);
v = circshift(v, sh, varargin{:});

if sh < 0
    v((len - sh + 1):len) = pad;
elseif sh > 0
    v(1:sh) = pad;
end