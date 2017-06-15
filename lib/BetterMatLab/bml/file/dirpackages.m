function packages = dirpackages(directory)
% packages = dirpackages(directory)
if nargin < 1, directory = pwd; end
[~, names] = dirdirs(directory);
tf_package_subdirs = strcmpStart('+', names);
packages = cellfun(@(s) s(2:end), names(tf_package_subdirs), ...
    'UniformOutput', false);
end