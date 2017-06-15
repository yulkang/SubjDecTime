function v = force_range(v, r)
% FORCE_RANGE  Force values into [r(1), r(2)].
%
% v = force_range(v, r)

v = max(min(v, r(2)), r(1));