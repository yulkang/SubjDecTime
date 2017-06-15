function testOverhead
    
    t1 = rand<0.5;
    tt1 = testOverheadClass;
    tt = GetSecs;
    tt1.tt2(t1); % second longest. ~0.1ms
    disp(GetSecs - tt);
    
    t1 = rand<0.5;
    tt = GetSecs;
    testOverheadClass.tt2(t1); % longest. 0.15-0.2ms. 
    disp(GetSecs - tt);
    
    t1 = rand<0.5;
    tt = GetSecs;
    sub(t1); % shortest. ~0.04ms
    disp(GetSecs - tt);
    
    t1 = rand<0.5;
    tt = GetSecs;
    nested(t1); % 0.05ms
    disp(GetSecs - tt);
    
    
    function nested(tf)
        if tf, return; end
    end
end


function sub(tf)
    if tf, return; end
end