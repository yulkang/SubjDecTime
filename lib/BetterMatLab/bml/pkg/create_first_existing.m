function obj = create_first_existing(class_name, pkgs, create_args)
% obj = create_first_existing(class_name, pkgs, create_args)
if nargin < 3, create_args = {}; end

classes = csprintf(['%s.' class_name], pkgs);

n = numel(classes);
for ii = 1:n
    if exist(classes{ii}, 'class')
        obj = feval(classes{ii}, create_args{:});
        return;
    end
end
error(['Could not find any of:', sprintf(' %s', classes{:})]);
end