function testCellVsOverhead
    
    nRep = 1000;
    siz = 100;

    m = nan(nRep,siz);
    
    c = cell(1,nRep);
    tic;
    for ii = 1:nRep
        c{ii} = 1:siz;
    end
    toc;
    
    tic;
    for ii = 1:nRep
        subfun;
    end
    toc;

    
    function subfun
        m(ii,:) = 1:siz;
    end
end


