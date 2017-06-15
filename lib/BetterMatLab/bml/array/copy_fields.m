function dst = copy_fields(dst, src, op, fields, catch_error)
% copy_fields  Copy fields of a struct or a dataset.
%
% dst = copy_fields(dst, src, 'all_recursive') (default)
% dst = copy_fields(dst, src, 'all', [fields])
% dst = copy_fields(dst, src, 'except_existing', [fields])
% dst = copy_fields(dst, src, 'existing_only', [fields])
% ... = copy_fields(..., [catch_error = false])
%
% 2013 (c) Yul Kang. hk2699 at columbia dot edu.

if ~exist('op', 'var'), op = 'all_recursive'; end
if ~exist('catch_error', 'var'), catch_error = false; end

recursive = strcmp(op, 'all_recursive');

if recursive || ~exist('fields', 'var')
    fields = fieldnames(src);
end

switch op
    case 'except_existing'
        fields = setdiff(fields, fieldnames(dst));
        
    case 'existing_only'
        fields = intersect(fields, fieldnames(dst));
end
if isa(src, 'dataset')
    fields = setdiff(fields, 'Properties');
end

for f = fields'
    if recursive && isfield(dst, f{1}) && isstruct(src.(f{1}))
        % Copy within the struct
        if catch_error
            try
                dst.(f{1}) = copy_fields(dst.(f{1}), src.(f{1}), op);
            catch err_copy
                warning(err_msg(err_copy));
            end
        else
            dst.(f{1}) = copy_fields(dst.(f{1}), src.(f{1}), op);
        end
    else
        % Just copy
        if catch_error
            try
                dst.(f{1}) = src.(f{1});
            catch err_copy
                warning(err_msg(err_copy));
            end
        else
            dst.(f{1}) = src.(f{1});
        end
    end
end