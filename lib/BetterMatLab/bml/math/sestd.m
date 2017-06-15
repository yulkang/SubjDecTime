function s = sestd(v)
% After Ahn & Fessler 2003
% at http://ai.eecs.umich.edu/~fessler/papers/files/tr/stderr.pdf
%
% 2015 Yul Kang wrote the initial version

if isvector(v)
    n = length(v);
else
    n = size(v,1);
end

s = std(v) / sqrt(2 * (n - 1));
