function d = testDynPropWrite(d, props, tt)
    for ii = props
        d.(ii) = tt;
    end
end