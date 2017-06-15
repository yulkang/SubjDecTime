Screen('Preference', 'SkipSyncTests', 1);

win0 = Screen('OpenWindow', 0);
win1 = Screen('OpenWindow', 1);

tf0s = Screen('AsyncFlipBegin', win0)
tf0e = Screen('AsyncFlipEnd', win0)

tf1e = Screen('AsyncFlipCheckEnd', win1)
tf2s = Screen('AsyncFlipBegin', win1)

[tf2e, t2e] = Screen('AsyncFlipCheckEnd', win1)
WaitSecs(0.02);
[tf3e, t3e] = Screen('AsyncFlipCheckEnd', win1)

[tf4e, t4e] = Screen('AsyncFlipCheckEnd', win1)

tf5s = Screen('AsyncFlipBegin', win1)
[tf5e, t5e] = Screen('AsyncFlipCheckEnd', win1)

tf6s = Screen('Flip', win1)
[tf6e, t6e] = Screen('AsyncFlipCheckEnd', win1)

Screen('CloseAll');