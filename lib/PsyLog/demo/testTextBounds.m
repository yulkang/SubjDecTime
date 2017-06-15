txtSize = 29;
txt{1} = 'AjB';
txt{2} = 'BgC';

cWin = Screen('OpenWindow', 1, 0);
tic;
Screen('TextSize', cWin, txtSize);
toc;
rectTxt = Screen('TextBounds', cWin, txt{1}, 0, 0);
[nx ny] = Screen('DrawText', cWin, txt{1}, 0, 0, 255);
[nx2 ny2] = Screen('DrawText', cWin, txt{2}, nx, ny, 255);
Screen('FillRect', cWin, 255, [0 rectTxt(4)/2-1, nx, rectTxt(4)/2+1]);
Screen('FillRect', cWin, 255, [nx txtSize/2-1, nx2, txtSize/2+1]);
Screen('FillRect', cWin, 255, [0 0, nx2, 1]);
Screen('FrameRect', cWin, 255, [0 0 nx2, txtSize]);
Screen('FrameRect', cWin, 255, rectTxt);

Screen('Flip', cWin);
KbWait;

Screen CloseAll

rectTxt
nx
ny