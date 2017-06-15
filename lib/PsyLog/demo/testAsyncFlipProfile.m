nRep = 1;
dt = zeros(1,nRep);

for ii = 1:nRep
    Screen('AsyncFlipBegin', cWin);
    
    completed = 0;
    while ~completed
        [completed, stimOn] = Screen('AsyncFlipCheckEnd', cWin);
    end
    dt(ii) = ((GetSecs - stimOn) * 1000);
%     [~, stimOn] = Screen('AsyncFlipEnd', cWin);
end
