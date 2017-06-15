function [r, m] = resid_sep(v, sep)
% [r, m] = resid_sep(v, sep)

[~,~,sep] = unique(sep);

for col = size(v, 2):-1:1
    cv = v(:, col);
    
    ms = accumarray(sep, cv, [], @nanmean);
    m(:, col) = ms(sep);
end

r = v - m;