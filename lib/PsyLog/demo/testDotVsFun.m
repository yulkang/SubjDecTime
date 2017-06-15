clear classes;
nRep = 1000;

% % With 1000 elements in b & 1000 repeated computation.
% >> testDotVsFun
% Elapsed time is 0.001019 seconds. % struct
% Elapsed time is 0.004785 seconds. % direct modification of class content
% Elapsed time is 0.037778 seconds. % function form
% Elapsed time is 0.047092 seconds. % dot form
% Elapsed time is 0.048272 seconds. % dot() form

%%
tts = struct('b', [2 2]);
tic;
for ii = 1:nRep
    tts.b = tts.b + 1;
end
toc;

%%
tt0 = testClass;
tic;
for ii = 1:nRep
    tt0.b = tt0.b + 1;
end
toc;

%%
tt = testClass;
tic;
for ii = 1:nRep
    inc(tt);
end
toc;

%%
tt2 = testClass;
tic;
for ii = 1:nRep
    tt2.inc;
end
toc;

%%
tt3 = testClass;
tic;
for ii = 1:nRep
    tt3.inc();
end
toc;