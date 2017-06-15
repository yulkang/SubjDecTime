function prop = get_meta_property(mc, prop_name)
% prop = get_meta_property(mc, prop_name)
props = mc.PropertyList;
prop_names = {props.Name};
tf = strcmp(prop_name, prop_names);
assert(any(tf), 'No property named %s in class %s!', prop_name, mc.Name);
prop = props(tf);
end