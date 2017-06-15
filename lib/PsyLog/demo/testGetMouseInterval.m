% testGetMouseInterval
nRep = 200;
t1 = 0; % zeros(1,nRep);
t2 = 0; % zeros(1,nRep);
dt = zeros(1,nRep);

delays = [1/800 1/400 1/200 1/60];

xMin = inf;
xMax = -inf;
GetMouse;

for jj = 1:length(delays)
    cDelay = delays(jj);
    
    for ii = 1:nRep
        t1 = GetSecs;
        GetMouse;
%         KbCheck;
        t2 = GetSecs;
        dt(ii) = t2 - t1;

        WaitSecs('UntilTime', t1+cDelay);
    end
    
    subplot(length(delays), 1, jj);
    hist(dt*1000, 20);
    title(sprintf('Querry Freq: %g Hz', round(1/cDelay)));
    
    cXLim = xlim;
    xMin = min(xMin, cXLim(1));
    xMax = max(xMax, cXLim(2));
end

for jj = 1:length(delays)
    subplot(length(delays), 1, jj);
    
    xlim([xMin xMax]);
end
