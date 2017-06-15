function str = cell2m(c)
str = sprintf('{\n');
str = [str, sprintf('''%s''\n', c{:}), '}'];
end