n = 1e6;
tic;
r = truncgamrnd_ms(0.4, 0.2, 0.2, inf, [n, 1]);
toc;

disp(size(r));
subplot(2,1,1);
ecdf(r);
subplot(2,1,2);
hist(r, 100);
xlim([0 1]);