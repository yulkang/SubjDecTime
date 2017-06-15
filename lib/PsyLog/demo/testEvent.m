function testEvent
I.addEvent('inTarget', {'mouse', 'inCircle', [0 1 2 0]}); % x y r in. in==1 means outside.
end


function addEvent(me, name, devs)

me.event.(name).content = devs;
me.event.(name).check = false;

for iDev = 1:size(devs,1)
    me.(devs{iDev,1}).(devs{iDev,2}).names{iName} = name;
    me.(devs{iDev,1}).(devs{iDev,2}).contents = ...
        [me.Dev.(devs{iDev,1}).(devs{iDev,2}).contents; devs{iDev,3}];
end
end


function startCheck(me, name)
me.event.(name).check = true;
end


function checkEvent(me)
if isfield(me, 'mouse')
    
end
end