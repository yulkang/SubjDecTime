function M = Map_add(M, keySet, valueSet)
% M = Map_add(M, keySet, valueSet)
%
% M        : containers.Map object
% keySet   : cell array of strings or a numeric vector
% valueSet : any array

M = [M; containers.Map(keySet, valueSet)];