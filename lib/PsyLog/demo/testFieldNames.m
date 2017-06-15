% testFieldNames
clear tt;

nRep = 10000;

for ii = 'a':'z'
    tt.(ii) = 1;
end

tic;
for ii = 1:nRep
    fieldNames = fieldnames(tt);
end
toc;