n = 2;

%%
parfor ii = 1:n
    tf = is_in_parallel();
    assert(tf);
end

%%
jobs = cell(n, 1);
for ii = n:-1:1
    jobs{ii} = parfeval(@is_in_parallel, 1);
end
jobs = [jobs{:}];
wait(jobs);
tf = fetchOutputs(jobs);
disp(tf);
assert(all(tf(:)));

%%
for ii = 1:n
    tf = is_in_parallel();
    disp(tf);
    assert(~tf);
end