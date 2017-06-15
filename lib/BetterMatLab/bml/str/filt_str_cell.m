function [res, filtered] = filt_str_cell(str_cell, filt, filt_in)
% [res, filtered] = filt_str_cell(str_cell, filt, filt_in)
%
% str_cell : cell of strings to filter
% filt     : cell of string patterns
% filt_in  : if false (default), filters out strings containing any of filt.
% res      : filtered strings.
% filtered : logical index of filtered strings, such that res = str_cell(filtered).

if ~exist('filt_in', 'var'), filt_in = false; end

n = length(str_cell);
filtered = zeros(1,n);
for i_cell = 1:n
    filtered = any(cellfun(@(f) ~isempty(strfind(str_cell{i_cell}, f)), filt));
end

if ~filt_in
    filtered = ~filtered;
end

res = str_cell(filtered);