nRep = 10000;

tt  = zeros(1,1000, 'int32');
tt2 = zeros(1,1000, 'double');

tic;
for ii = 1:nRep
    tt = tt + 1;
end
toc;

tic;
for ii = 1:nRep
    tt2 = tt2 + 1;
end
toc;

% Result: double is faster for 1 and 1000 elements.