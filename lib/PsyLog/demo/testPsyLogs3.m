clear classes;

tt = PsyLogs('valCell', num2cell('a':'c'), 'absSec', ones(2,1000), 1000);

tt.initLogTrial;

%%
GetSecs;

aa = zeros(2,1000);

tic;
for ii = 1:1000
    
    addValCell(tt, 'b', GetSecs, aa);
%     addCell(tt, 'c', GetSecs, aa);
%     addLog(tt, {'b', 'c'}, GetSecs, {aa, aa});
end
toc;

% Surprisingly, addCell was as fast as addMark, and was faster than addVal3,
% although it consumes more .
%
% addLog was faster than before, adding only 0.02-0.05 ms per entry.

%%
clear classes;

tt = PsyLogs('propCell', {'n_'}, 'absSec', 1, 1000);

tt.initLogTrial;

%%
GetSecs;

aa = zeros(2,1000);

tic;
for ii = 1:1000
    
    addPropCell(tt, 'n_', GetSecs);
%     addCell(tt, 'c', GetSecs, aa);
%     addLog(tt, {'b', 'c'}, GetSecs, {aa, aa});
end
toc;
