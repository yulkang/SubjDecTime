function getsetfun(obj_name, prop_names)
% Copies to clipboard the get/set functions for the property.

if ischar(prop_names)
    prop_names = {prop_names};
end 

c = '';
for ii = 1:numel(prop_names)
    prop_name = prop_names{ii};
    
    c = [c, sprintf([ ...
        'function set_%2$s(%1$s, v)\n' ...
        '    %1$s.%2$s = v;\n' ...
        'end\n' ...
        'function v = get_%2$s(%1$s)\n' ...
        '    v = %1$s.%2$s;\n' ...
        'end\n\n' ...
        ], obj_name, prop_name)];
end
clipboard('copy', c);
end