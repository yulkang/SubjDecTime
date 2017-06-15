function tf = ishex(s)
% Tests if a string is a hexadecimal contant as in C (starts with '0x').
%
% tf = ishex(s)

tf = ~isempty(regexp(s, '^(0x)|(0X)[0-9a-fA-F]+$', 'once'));