function testWs2Base
dbstop if error
bb = 3;
testNest;

function testNest
    aa = 2;

    error('a');
end
end