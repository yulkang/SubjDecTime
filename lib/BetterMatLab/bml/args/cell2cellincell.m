function c = cell2cellincell(c)
% Make {e11, e12, ...; ...} into {{e11, e12, ...}, {...}, ...} format.
%
% c = cell2cellincell(c)

try
    c = mat2cell(c, ones(size(c,1)));
catch
    c = arrayfun(@(ii) c(ii,:), 1:size(c,1), 'UniformOutput', false);
    c = c(:);
end