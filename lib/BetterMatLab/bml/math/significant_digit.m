function sc = significant_digit(v, max_digit)
% sc = significant_digit(v, max_digit=6)
%
% v: a scalar numeric.

if v == 0, sc = 1; return; end
if nargin < 2, max_digit = 6; end
    
s = sprintf(sprintf('%%1.%de', max_digit), abs(v));

loc_e = find(s=='e', 1, 'first');
s(loc_e) = '0';

loc_zero_1st = find(s(1:loc_e) == '0', 1, 'first');

ex = floor(log10(v));

sc = 10^(-loc_zero_1st+3 + ex);