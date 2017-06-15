function S = names2enum(names)
% Returns a struct S with fields of sequential numbers: S.(name{k}) = k
%
% S = names2enum(names)

S = cell2struct(num2cell((1:numel(names))'), names(:), 1);