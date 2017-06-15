commandwindow;

for ii = 1:10
    [~, ~, keycode] = KbCheck;
    KbName(keycode)
    WaitSecs(0.1);
end