tt = portBeeps('init');
portBeeps('sets', 'a', 3, 1000, 0.01, 0.5);
portBeeps('ready', 'a');

%%
portBeeps('play', 'a')
PsychPortAudio('GetStatus', tt)
plT = portBeeps('play', 'a'), stT = GetSecs

stat = PsychPortAudio('GetStatus', tt)
stat.StartTime - stT
stat.StartTime - plT

%%
plT = portBeeps('play', 'a', 1, GetSecs + 1, 0), stT = GetSecs, 
stat = PsychPortAudio('GetStatus', tt); 
stat.StartTime - stT

%%
stat = PsychPortAudio('GetStatus', tt); 
stat.StartTime - stT

stat.RequestedStartTime - plT
stat.RequestedStartTime - stT
stat.RequestedStartTime - stat.StartTime

%%
stT0 = GetSecs - 1;
plT = portBeeps('play', 'a', 1, stT0, 0), stT = GetSecs, 

%%
stat = PsychPortAudio('GetStatus', tt); 
stat.StartTime - stT
stat.StartTime - stat.RequestedStartTime
stat.RequestedStartTime - stT0


%%
ticT = GetSecs; stat = PsychPortAudio('GetStatus', tt); tocT = GetSecs; disp(tocT - ticT);
ticT = GetSecs; for ii = 1:1000, stat = PsychPortAudio('GetStatus', tt); end, tocT = GetSecs; disp(tocT - ticT);
ticT = GetSecs; for ii = 1:10, stat = PsychPortAudio('GetStatus', tt); end, tocT = GetSecs; disp(tocT - ticT);