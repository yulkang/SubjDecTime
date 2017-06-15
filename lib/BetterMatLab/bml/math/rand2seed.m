function s = rand2seed(r)
% Converts double r in (0,1) to integer seed s in [1, 4e9 + 1] (4e9 approx 2^32-1)
%
% s = rand2seed(r)
%
% s = floor(r .* 4e9);
s = floor(r .* 4e9) + 1;