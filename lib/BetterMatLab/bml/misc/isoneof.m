function tf = isoneof(obj, types)
% tf = isoneof(obj, types)
% 
% vectorized version of isa(). 
% tf = any(cellfun(@(t) isa(obj, t), types))

if ischar(types)
    types = {types};
else
    assert(iscell(types));
end
n = numel(types);
tf = false;
for ii = 1:n
    tf = tf | isa(obj, types{ii});
    if tf
        break;
    end
end