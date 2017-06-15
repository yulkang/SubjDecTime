% testDatasetVsStruct

d = dataset;
s = struct;
sg = rand;
sn = rand(1,26);

vName = num2cell('a':'z');

for ii = 'a':'z'
    d.(ii) = rand;
    s.(ii) = rand;
end

%% Dynamic access
nRep = 100;

tic;
for ii = 1:nRep
    for jj = 'a':'z'
        d.(jj) = d.(jj) + 1;
    end
end
toc;

tic;
for ii = 1:nRep
    for jj = 'a':'z'
        s.(jj) = s.(jj) + 1;
    end
end
toc;

tic;
for ii = 1:nRep
    for jj = 'a':'z'
        s.(jj) = s.(jj) + 1;
    end
end
toc;

tic;
for ii = 1:nRep
    for jj = 'a':'z'
        kk = strcmp(vName, jj);
        sn(kk) = sn(kk) + 1;
    end
end
toc;

tic;
for ii = 1:nRep
    for jj = 'a':'z'
        sg = sg + 1;
    end
end
toc;

%% Static access
nRep = 100;

tic;
for ii = 1:nRep
    d.g = d.g + 1;
end
toc;

tic;
for ii = 1:nRep
    s.g = s.g + 1;
end
toc;

tic;
kk = strcmp(vName, 'g');
for ii = 1:nRep
    sn(kk) = sn(kk) + 1;
end
toc;

tic;
for ii = 1:nRep
    sg = sg + 1;
end
toc;


%% Converting to dataset
nRep = 1000;

tic;
ver(1, :) = dataset(s);
ver(nRep,:) = dataset(s);

for ii = 1:nRep
    ver(ii,:) = dataset(s);
end
toc;

tic;
verS = s;
verS(nRep) = s;

for ii = 1:nRep
    verS(ii) = s;
end
toc;


