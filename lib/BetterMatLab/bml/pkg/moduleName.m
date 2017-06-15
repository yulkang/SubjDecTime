function package = moduleName(package, postfix)
% package = moduleName(package, postfix='.*')

if nargin < 2
    postfix = '.*';
end

[~,package] = module(package);
package = [package, postfix];