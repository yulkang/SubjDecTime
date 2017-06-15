function v = subsample_from_last(v, n)
% v = subsample_from_last(v, n)

v = fliplr(v(:)');
v = fliplr(v(1:n:end));