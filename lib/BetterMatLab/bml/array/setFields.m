function res = setFields(src, fields1, fields2, v)
% res = setFields(src, fields1, fields2, v)
%
% src: nested struct
%
% Will first copy src to res, and then repeat 
%   res.(field1).(field2) = v
% for all combination of elements of fields1 and fields2.
%
% fields1 & 2 can be either row cell vector of strings or just a string.

res = src;

if ~iscell(fields1), cFields1 = {fields1}; else cFields1 = fields1; end
if ~iscell(fields2), cFields2 = {fields2}; else cFields2 = fields2; end

for ccField1 = cFields1
    cField1 = ccField1{1};
    
    for ccField2 = cFields2
        res.(cField1).(ccField2{1}) = v;
    end
end