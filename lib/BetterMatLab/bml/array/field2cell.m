function c = field2cell(S, f)
% cell_of_fields = field2cell(cell_array_of_struct, field_name)

c = cellfun(@(s) s.(f), S, 'UniformOutput', false);