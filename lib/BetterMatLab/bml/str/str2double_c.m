function v = str2double_c(s)
% Convert C numeric constants (decimal, octal, or hexadecimal) in string into double.

if isdecimal(s)
    v = str2double(s);
elseif ishex(s)
    v = hex2double(s);
elseif isoctal(s)
    v = oct2double(s);
else
    error('Unknown format!');
end
end

function v = hex2double(s)
s = lower(s(3:end));
v = s - '0';
v(v > 9) = v(v > 9) + '0' - 'a' + 10;

l = length(s);

v = sum(16.^((l-1):-1:0) .* v);
end

function v = oct2double(s)
s = s(2:end);

l = length(s);
v = sum(8.^((l-1):-1:0) .* (s - '0'));
end