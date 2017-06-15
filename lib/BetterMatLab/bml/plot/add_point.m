function add_point(h, x, y)
% add_point(h, x, y)

n_dim = numel(h);
n_samp = max(size(x,1), size(y,1));
x = rep2fit(x, [n_samp, n_dim]);
y = rep2fit(y, [n_samp, n_dim]);

for ii = 1:n_dim
    ch = h(ii);
    
    cx = [get(ch, 'XData'), x(:,ii)'];
    cy = [get(ch, 'YData'), y(:,ii)'];
    set(ch, 'XData', cx, 'YData', cy);
end
end