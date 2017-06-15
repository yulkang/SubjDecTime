try    Scr.delTree; catch; end
try    delete(Mouse); catch; end
try    delete(Cursor); catch; end
clear classes;

% diary('diary1.txt');
% tt = mfilename('fullpath')
% fullfile('', tt)

Scr = PsyScr;
Scr.debugMode = true;

%%
Scr.saveDiary;
% Scr.saveDep;
% saveWorkspace;

Scr.initSaveTimestamp;

Scr.saveDiary;
% Scr.saveDep;
saveWorkspace;

diary off;


%%
% [res, cIx]  = nextFile('testSave_', '.', 'mat', 'dateTime'), save(res);
% 
% [res, cIx]  = nextFile('testSave_', '.', 'mat', 'num'), save(res);
% 
% [res, cIx]  = nextFile('testSave_', '.', 'mat', 'num'), save(res);
% 
% [n, lastIx] = nextFile('testSave_', '.', 'mat', 'dateTime', true)
% 
% [n, lastIx] = nextFile('testSave_', '.', 'mat', 'num', true)
% 
