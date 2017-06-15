function [ws, col] = eqLumStill(col, win)

if exist('win', 'var')
    dontCloseWin = true;
else
    dontCloseWin = false;
    win = Screen('OpenWindow', 0, 0);
end

loc = [300 525; 1100 525];
siz = [200 200];
if ~exist('col', 'var')
    col = [50 255 255; 169 255 50]/255;
    lum = [255 255];
end

rect = [bsxfun(@minus,loc,siz), bsxfun(@plus,loc,siz)];

FlushEvents;
ListenChar(2);
decided = false;
while ~decided
    Screen('FillOval', win, col(1,:)*lum(1), rect(1,:));
    Screen('FillOval', win, col(2,:)*lum(2), rect(2,:));
    Screen('Flip', win);
    
    c = GetChar;
    
    switch c
        case 'q'
            decided = true;
        case 'u'
            lum(1) = min(lum(1) + 1, 255);
        case 'i'
            lum(2) = min(lum(2) + 1, 255);
        case 'j'
            lum(1) = max(lum(1) - 1, 0);
        case 'k'
            lum(2) = max(lum(2) - 1, 0);
    end
end
ListenChar(0);

disp(col);
disp(lum);

if ~dontCloseWin
    Screen CloseAll;
end

ws = ws2s;