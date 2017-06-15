function tt = testDynPropFun(d, props)
    for ii = props
        tt = d.(ii);
    end
end