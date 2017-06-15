% Result: inc(tHandle) was way faster than others.
% Using handle does save time!

nRep = 1000;
tValue = testValue;
tHandle = testHandle;

tic;
for ii = 1:nRep
    inc(tHandle); % Fastest
end
toc;

tic;
for ii = 1:nRep
    tHandle.inc; % 4/3 * inc(tHandle)
end
toc;

tic;
for ii = 1:nRep
    tValue = inc(tValue); % 2 x Handle
end
toc;

tic;
for ii = 1:nRep
    tValue = tValue.inc; % 2 x Handle + alpha
end
toc;

