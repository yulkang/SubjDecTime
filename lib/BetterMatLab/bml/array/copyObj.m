function me2 = copyObj(me)
% Copy an object (array) to a new one.
% Especially useful when copying a handle object (array).

fieldNames     = fieldnames(me(1))';
me2(numel(me)) = eval(class(me));

for ii = 1:numel(me)
    for cField = fieldNames
        me2(ii).(cField{1}) = me(ii).(cField{1});
    end
end

me2 = reshape(me2, size(me));
end