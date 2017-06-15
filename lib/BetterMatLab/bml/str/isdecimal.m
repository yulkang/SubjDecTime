function tf = isdecimal(s)
% Tests if a string is a decimal contant as in C (rather than octal or hexadecimal).
%
% tf = isdecimal(s)

tf = isequal(s, '0') || ~isempty(regexp(s, '^[1-9]+[0-9]*$', 'once'));