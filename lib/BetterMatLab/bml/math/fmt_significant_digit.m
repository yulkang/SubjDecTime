function fmt = fmt_significant_digit(sc)
% fmt = fmt_significant_digit(sc)
%
% EXAMPLE:
% >> fmt_significant_digit(10)
% ans =
% %1.0f
% 
% >> fmt_significant_digit(0.01)
% ans =
% %1.2f

if sc == 0
    fmt = '%1.0f';
else
    fmt = sprintf('%%1.%df', max(-floor(log10(abs(sc))), 0));
end