clear all;
nRep = 10000;

a = {};
tt = 0;
jj = 0;
ii = 0;

tic;
for jj = 1:nRep
    for ii = 1:length(a)
        tt = 2;
    end
end
toc;

tic;
for jj = 1:nRep
    if isempty(a), continue; end
    for ii = 1:length(a)
        tt = 2;
    end
end
toc;

tic;
for jj = 1:nRep
    if ~isempty(a)
        for ii = 1:length(a)
            tt = 2;
        end
    end
end
toc;


