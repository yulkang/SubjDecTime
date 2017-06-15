function S = prefix_fields(S, str)
% S = prefix_fields(S, str)

fs = fieldnames(S);
fs = cellfun(@(s) [str, s], fs, 'UniformOutput', false);
S = cell2struct(struct2cell(S), fs, 1);