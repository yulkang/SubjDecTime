global ptb_kbcheck_enabledKeys
ptb_kbcheck_enabledKeys = []; % ones(1,256);
ptb_kbcheck_enabledKeys(KbName('space')) = 1;

%%
tic;
for ii = 1:1000
    [tt, secs, keyCode] = PsychHID('KbCheck', [], ptb_kbcheck_enabledKeys); % KbCheck;
end  
toc; 