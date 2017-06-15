% testPsyKey

clear all;
clear classes;
tKey = PsyKey


%%
nRep = 1000;

tKey.tSampled.maxN = nRep;
tKey.initLog

tic;
for ii = 1:nRep
    tKey.get;
end
toc;


%%
tic;
for ii = 1:nRep
    [x y buttons] = GetMouse;
end
toc;