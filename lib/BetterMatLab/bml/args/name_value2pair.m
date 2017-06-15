function pairs = name_value2pair(names, values)
% pairs = name_value2pair(names, values)

pairs = [names(:), values(:)]';
pairs = pairs(:)';