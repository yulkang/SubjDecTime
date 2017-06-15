function dst = mergeStruct(dst, src)
% MERGESTRUCT   Append & overwrite the first struct's fields with the seconds'.
%
% dst = mergeStruct(dst, src)
%
% See also STRUCT2OBJ.

for cField = fieldnames(src)'
    dst.(cField{1}) = src.(cField{1});
end