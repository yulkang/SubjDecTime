function tf = isoctal(s)
% Tests if a string is an octal contant as in C (starts with '0').
%
% tf = isoctal(s)

tf = ~isempty(regexp(s, '^0[0-7]+$', 'once'));