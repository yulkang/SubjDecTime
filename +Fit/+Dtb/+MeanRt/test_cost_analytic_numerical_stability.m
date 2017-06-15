clear costs grads hesss

coh0s = (-100:100)'.*1e-9; n = length(coh0s);

for ii = n:-1:1
    W.th.bias_cond = coh0s(ii);
    [costs(ii,1), grads(ii,:), hesss(:,:,ii)] = W.get_cost; 
end

figure(1);
plot(coh0s, standardize(costs))
ylabel('cost (standardized)'); xlabel('coh0');

figure(2);
plot(coh0s, standardize(grads))
ylabel('grad (standardized)'); xlabel('coh0');

figure(3);
plot(coh0s, standardize(reshape(permute(hesss, [3,1,2]), n, [])));
ylabel('hess (standardized)'); xlabel('coh0');
