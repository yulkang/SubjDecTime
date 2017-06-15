function S = rmfield(S, fs)
% Same as the orignial rmfield except it ignores nonexisting fields.
if ischar(fs)
    fs = {fs};
end
fs = intersect(fieldnames(S), fs(:));
S = rmfield(S, fs);
end