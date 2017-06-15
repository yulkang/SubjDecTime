c = parcluster();

% j = createMatlabPoolJob();

%%
for ii = 1:2
    j(ii) = createJob(c);
    t(ii) = createTask(j, @rand, 1, {{3, 3}, {3, 3}});
end
submit(j);
wait(j);
% waitForState(j);
taskoutput = get(t, 'OutputArguments');
disp(taskoutput{1}{1});
disp(taskoutput{2}{1});



