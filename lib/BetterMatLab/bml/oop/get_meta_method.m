function method_ = get_meta_method(mc, method_name)
% method_ = get_meta_method(mc, method_name)
methods = mc.MethodList;
method_names = {methods.Name};
tf = strcmp(method_name, method_names);
assert(any(tf), 'No property named %s in class %s!', method_name, mc.Name);
method_ = methods(tf);
end