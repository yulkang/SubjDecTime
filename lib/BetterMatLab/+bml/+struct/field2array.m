function v = field2array(S, field)
% v = field2array(S, field)
v = reshape([S.(field)], size(S));