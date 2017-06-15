function info = what_fixed_for_packages(directory)
if nargin < 1, directory = pwd; end
info = what(directory);

n_file = length(info.m);
for i_file = 1:n_file
    file = info.m{i_file};
    class_full = file2pkg(fullfile(info.path, file));
    if exist(class_full, 'class')
        info.classes{end + 1} = class_full;
    end
end