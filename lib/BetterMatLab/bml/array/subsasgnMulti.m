function res = subsasgnMulti(res, C, v)
% res = subsasgnMulti(res, C, v)
%
% res(sub2ind(size(res), C{:})) = v(:);

ind = sub2ind(size(res), C{:});
res(ind(:)) = v(:);