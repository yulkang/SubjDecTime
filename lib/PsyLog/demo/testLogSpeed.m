% testLogSpeed

%% Separate log
clear classes;
tScr = PsyScr;

nRep = 1000;

tScr.visOrd  = num2cell('a':'j');
tScr.visible = struct('a', 1, 'b', 3, 'c', 4, 'd', 5, 'e', 6, 'f', 7);

tScr.visOrdLog = PsyLogVecPropFr(tScr, tScr, 'visOrd', 3000);
tScr.visibleLog = PsyLogScalarPropFr(tScr, tScr, 'visible', 3000);
init(tScr.visibleLog);

disp(tScr.visibleLog);

tic;
for ii = 1:nRep
    add(tScr.visibleLog);
    add(tScr.visOrdLog);
    add(tScr.visibleLog);
    add(tScr.visOrdLog);
    add(tScr.visibleLog);
    add(tScr.visOrdLog);
end
toc;

disp(tScr.visibleLog);


%% Combined log
clear all;
clear classes;
tScr = PsyScr;

nRep = 1000;

tScr.visOrd  = num2cell('a':'j');
tScr.visible = struct('a', 1, 'b', 3, 'c', 4, 'd', 5, 'e', 6, 'f', 7);

% tScr.visOrdLog = PsyLogVecPropFr(tScr, tScr, 'visOrd', 1000);
tScr.visibleLog = PsyLogPropsFr(tScr, tScr, {'visOrd', 'visible', 'visOrd', 'visible', 'visOrd', 'visible'}, 1000);
init(tScr.visibleLog);

disp(tScr.visibleLog);

tic;
for ii = 1:nRep
    add(tScr.visibleLog);
end
toc;

disp(tScr.visibleLog);


%% 
clear all;
clear classes;
tLog = PsyLogProp;

tLog.obj = 
