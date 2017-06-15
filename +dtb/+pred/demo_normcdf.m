%%
nd = 81;
mu = linspace(-1, 1, nd);

ny = 2^9;
nt = 376;

y = linspace(-ny/2, ny/2, ny)';

mu_rep = repmat(mu, [ny, 1]);
y_rep = repmat(y, [1, nd]);

%% This is faster. (0.22s)
tic;
for ii = 1:nt
    p = normcdf(y_rep, mu_rep, 1);
end
toc;

%% This is significantly slower. (2.1s)
tic;
for ii = 1:nt
    for jj = 1:nd
        p(:,jj) = normcdf(y, mu(jj), 1);
    end
end
toc;