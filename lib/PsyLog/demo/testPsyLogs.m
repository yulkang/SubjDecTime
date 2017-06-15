% testPsyLogs
clear classes;

nRep = 1000;
tt   = magic(30);

Log = PsyLogs;

Log.init('val', {'a', 'b'}, 'absSec', 3, {tt}, nRep);
Log.init('mark', {'c', 'd'}, 'absSec');
Log.initLog;

%%
tic;
for ii = 1:nRep
    add(Log, {'a'}, GetSecs, {tt});
end
toc;

%%
tic;
for ii = 1:nRep
    add(Log, {'c'}, GetSecs);
end
toc;

%%
tic;
% profile on;
for ii = 1:nRep
    add(Log, {'b', 'd'}, GetSecs, {tt});
end
% profile viewer;
toc;

%%
% tic;
% for ii = 1:nRep
%     Log.ns(2) = Log.ns(2) + 1;
%     Log.ts{2}(Log.ns(2)) = GetSecs;
%     Log.vs{2}(:,:,ii) = tt;
% end
% toc;