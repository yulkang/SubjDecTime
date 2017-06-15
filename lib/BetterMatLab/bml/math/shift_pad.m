function v = shift_pad(v, w, num)
% SHIFT_PAD  Shift a vector and pad with a number.
%
% v = shift_pad(v, width, [num = 0])
%
% See also: shift_pad2

if ~exist('num', 'var'), num = 0; end

siz = size(v);
v   = v(:);

w   = max(min(length(v), w), -length(v));

if w > 0
    v = [zeros(w, 1) + num; v(1:(end - w))];
    
elseif w < 0
    v = [v((-w+1):end); zeros(-w, 1) + num];
end

v = reshape(v, siz);