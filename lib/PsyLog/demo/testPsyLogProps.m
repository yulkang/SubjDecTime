clear all;
clear classes;

tScr = PsyScr('refreshRate', 60);
tScr.initTree;

nObj = 20;
lenName = 5;
nRep = 1000;

tScr.visOrd = cellstr(repmat(('a':char('a'+nObj-1))', [1 lenName]))';
tScr.visible = false(1, nObj);
tScr.log.init(tScr, {'visOrd', 'visible'}, nRep, [], 'fr', 1);

%%

tic;
for ii = 1:nRep
    add(tScr.log);
end
toc;