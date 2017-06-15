function c = exclude_empty(c)
% c = exclude_empty(c)
%
% c: cell array.
c = c(~cellfun(@isempty, c));