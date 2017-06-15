% testCellVsStruct
% : which is a faster way to reorder objects?
clear all;

nRep = 1000;
nRep2 = 10;
nField = 10;

a(nField) = PsyPTB;
ca    = num2cell(a);

f = num2cell('a':char('a'+nField-1));
s = cell2struct(ca, f, 2);

%% Struct
tic;
for ii = 1:nRep
    f = [f(2:end) f(1)];
    
    for cf = f
        
        for jj = 1:nRep2
            tt = s.(cf{1});
        end
    end
end
toc;

%% Cell
tic;
for ii = 1:nRep
    ca = [ca(2:end) ca(1)];
    
    for cca = ca
        for jj = 1:nRep2
            tt = cca{1};
        end
    end
end
toc;

