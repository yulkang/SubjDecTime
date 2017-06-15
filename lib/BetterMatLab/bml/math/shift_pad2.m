function v = shift_pad2(v, w, num)
% SHIFT_PAD2  Shift a matrix and pad with a number.
%
% v = shift_pad(v, width, [num = 0])
%
% width: [w_row, w_col]
%
% See also: shift_pad

if ~exist('num', 'var'), num = 0; end

% If no shift, just return.
if ~any(w), return; end

% Shift.
v = circshift(v, w);

% Fill with num.
siz = size(v);

if w(2) > 0
    col_incl = (1:siz(2)) <= w(2);
elseif w(2) < 0
    col_incl = (1:siz(2)) > siz(2) + w(2);
else
    col_incl = false(siz(2), 1);
end
v(:, col_incl) = num;

if w(1) > 0
    row_incl = (1:siz(1)) <= w(1);
elseif w(1) < 0
    row_incl = (1:siz(1)) > siz(1) + w(1);
else
    row_incl = false(siz(1), 1);
end
v(row_incl, ~col_incl) = num;