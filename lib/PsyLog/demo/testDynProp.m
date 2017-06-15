% testDynProp

clear classes;

nRep = 1000;

d = PsyStruct;
s = struct;

props = 'a':'h';

% for ii = props
%     addprop(d, ii);
% end
   
%%
tic;
for jj = 1:nRep
    for ii = props
        s.(ii) = zeros(1,1000);
    end
end
toc;

tic;
for jj = 1:nRep
    for ii = props
        d.a.(ii) = zeros(1,1000);
    end
end
toc;

%%
tt = zeros(1,1000);

tic;
for jj = 1:nRep
    for ii = props
        tt = d.a.(ii);
    end
end
toc;

tic;
for jj = 1:nRep
    for ii = props
        tt = s.(ii);
    end
end
toc;


%%
tt = zeros(1,1000);

tic;
for jj = 1:nRep
    tt = testDynPropFun(s, props);
end
toc;

tic;
for jj = 1:nRep
    tt = testDynPropFun(d.a, props);
end
toc;



%%
tt = zeros(1,1000);

tic;
for jj = 1:nRep
    s = testDynPropWrite(s, props, tt);
end
toc;

tic;
for jj = 1:nRep
    testDynPropWrite(d.a, props, tt);
end
toc;

% Result: dynamic properties are ~10 times slower to read/write than struct fields,
%         even when it involves massive copying.
%         predefined properties, whether it's regular handle or value class's or 
%         a dynamicprops', are ~2 times slower than struct fields.
