function res = maxRange(v1, v2)
% MAXRANGE  Given two ranges (pairs of doubles), returns an inclusive range.
%
% res = maxRange(v1, v2)
    
    res = [min(v1(1), v2(1)), max(v1(2), v2(2))];
end