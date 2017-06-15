function v = conv(a, b, varargin)
% v = conv(a, b, varargin)
siz = size(a);
n_col = prod(siz(2:end));
a = reshape(a, siz(1), n_col);
for ii = n_col:-1:1
    v(:,ii) = conv(a(:,ii), b, varargin{:});
end
v = reshape(v, siz);