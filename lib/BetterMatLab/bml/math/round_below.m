function v = round_below(v, min_digit)
% Round such that all digits below 10^min_digit is 0.

factor = 10.^min_digit;
v = round(v ./ factor);
v = v .* factor;