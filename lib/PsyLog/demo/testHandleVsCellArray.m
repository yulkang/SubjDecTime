% Verdict: CellArray log takes less time, and is easier to manage.

clear classes;

nName  = 1;
nRep   = 1000;

cSrcs  = repmat({'val'}, [1 nName]);

names = num2cell('a':char('a'+nName-1));
maxNs  = 1000 * ones(1, nName);
appendDims = 3 * ones(1, nName);

for ii = nName:-1:1;
    vs{ii} = magic(ii*5);
end

ca = testCellArray;
ha(nName) = testHandleArray;

init(ca, names, maxNs, cSrcs, vs, appendDims);
init(ha, names, maxNs, cSrcs, vs, appendDims);

ca2 = copy(ca);

% 
% %%
% tic;
% for ii = 1:nRep
%     add(ha, names, vs, GetSecs);
% end
% toc;


%%
tic;
for ii = 1:nRep
    addDirect(ca2, 1:nName, vs, GetSecs);
end
toc;


%%
% profile on -nohistory
tic;
for ii = 1:nRep
    add(ca, names, vs, GetSecs);
end
toc;
% profile viewer









