function ds = bin_tab(c)
% BIN_TAB - Returns a dataset of T/F with colums of unique entries in C.
%
% ds = bin_tab(c)
%
% EXAMPLE:
% >> bin_tab({'a', 'b', 'c', 'a'})
% ans = 
%     a        b        c    
%     true     false    false
%     false    true     false
%     false    false    true 
%     true     false    false

fields = unique(c);
ds     = dataset;

if iscell(c)
    for c_field = fields
        ds.(c_field{1}) = ...
            vVec(strcmp(c_field{1}, c));
    end
end