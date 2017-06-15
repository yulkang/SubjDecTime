function v = shift_padn(v, w, num)
% SHIFT_PADN  Shift a matrix and pad with a number.
%
% v = shift_pad3(v, width, [num = 0])
%
% width: [w1, w2, w2]
%
% See also: shift_pad

if nargin < 3
    num = 0; 
end

% If no shift, just return.
if ~any(w), return; end

% Shift.
v = circshift(v, w);

% Fill with num.
siz = size(v);

nd = ndims(v);
incl0 = cell(1, nd);
for ii = 1:nd
    incl0{ii} = true(1, siz(ii));
end
for ii = 1:nd
    if w(ii) > 0
        incl = (1:siz(ii)) <= w(ii);
    elseif w(ii) < 0
        incl = (1:siz(ii)) > siz(ii) + w(ii);
    else
        incl = false(1, siz(ii));
    end
    
    v(incl0{1:(ii-1)}, incl, incl0{(ii+1):end}) = num;
end
% 
% if w(2) > 0
%     col_incl = (1:siz(2)) <= w(2);
% elseif w(2) < 0
%     col_incl = (1:siz(2)) > siz(2) + w(2);
% else
%     col_incl = false(siz(2), 1);
% end
% v(:, col_incl) = num;
% 
% if w(1) > 0
%     row_incl = (1:siz(1)) <= w(1);
% elseif w(1) < 0
%     row_incl = (1:siz(1)) > siz(1) + w(1);
% else
%     row_incl = false(siz(1), 1);
% end
% v(row_incl, ~col_incl) = num;