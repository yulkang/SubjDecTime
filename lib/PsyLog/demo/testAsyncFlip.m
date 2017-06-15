cWin = Screen('OpenWindow', 0);
% tic;

[~, stimOn] = Screen('AsyncFlipEnd', cWin);
GetSecs;
% toc;

HideCursor;

for ii = 1:30
    [x y] = GetMouse;
    testDraw(cWin, [255 0 0], [x y x+20 y+20]+0.5);
    GetMouse;
    
    Screen('AsyncFlipBegin', cWin);
    GetMouse;
    
    completed = 0;
    tt = 0; % debug
    while completed == 0
        [completed, stimOn] = Screen('AsyncFlipCheckEnd', cWin);
        GetMouse;
        tt = tt + 1; % debug
    end
    disp(tt); % debug
%     [~, stimOn] = Screen('AsyncFlipEnd', cWin)
    
    [x y] = GetMouse;
    testDraw(cWin, [0 255 0], [x y x+20 y+20]+0.5);
    Screen('AsyncFlipBegin', cWin);
    
    completed = 0;
    while completed == 0
        [completed, stimOn] = Screen('AsyncFlipCheckEnd', cWin);
        GetMouse;
    end
%     [~, stimOn] = Screen('AsyncFlipEnd', cWin)
end

WaitSecs(1);


%%
% testAsyncFlipProfile;

%%
ShowCursor;
Screen('Close', cWin);

% plot(dt);

