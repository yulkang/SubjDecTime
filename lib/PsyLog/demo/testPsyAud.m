% testPsyAud

clear classes
Aud = PsyAud([], {'a', 'beeps'}, ...
                 {'sndTimeOut',    'wav/click.WAV'}, ...
                 {'sndFixBreak',   'wav/secalert.WAV', 'amps', 0.5}, ...
                 {'sndWrong',      'wav/signon.WAV'}, ...
                 {'sndCorrect',    'wav/ding.wav'});

%
Aud.open
Aud.initLogTrial;

%%

Aud.play('sndTimeOut');

WaitSecs(1);
Aud.play('sndFixBreak');

WaitSecs(1);


%%
Aud.closeLog;
Aud.close