function v2 = deep_copy_safe(v)
% Polymorphic function for value classes (for DeepCopyable.deep_copy)
% 
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.

if isa(v, 'DeepCopyable')
    v2 = v.deep_copy;
elseif isa(v, 'matlab.mixin.Copyable')
    warning('Define deep copying for %s! Shallow copying.', class(v));
    v2 = v.copy;
elseif isa(v, 'handle')
    error('Handle that are not matlab.mixin.Copyable cannot be copied!');
else % Value class
    v2 = v;
end
end