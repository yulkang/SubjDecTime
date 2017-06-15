% function [info, win] = test_win_rect(scr)

Screen('Preference', 'SkipSyncTests', 1);

% if nargin == 0
    scr = [0 1];
% end

n = length(scr);

rect = cell(1,n);
info = cell(1,n);
win  = zeros(1,n);

for ii = 1:n
    [win(ii), rect{ii}] = Screen('OpenWindow', scr(ii));
    pause(1);
    info{ii} = Screen('GetWindowInfo', win(ii));
end

Screen('CloseAll');
% end