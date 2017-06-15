function S = vec2struct(v, names)
% S = vec2struct(v, names)
S = cell2struct(num2cell(v(:)), names(:), 1);
end