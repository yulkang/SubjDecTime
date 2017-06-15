%%
tic;
c = 0;
for ii = 1:1000
    c = flow.cost(flow.th_vec);
end
toc;

