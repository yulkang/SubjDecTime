function testRandAlg % (alg, nRep, len)

alg = {'mcg16807', 'mlfg6331_64', 'mrg32k3a', 'mt19937ar', 'shr3cong', 'swb2712'};
nRep = 1000;
len  = [1670] * 3; % 16.7 dots/deg^2. 418: 5 deg diameter. 1670: 10 deg diameter.
toSlice = [false true];

tEl = zeros(length(alg), length(len), length(nRep), length(toSlice));

iAlg = 0;
for cAlg = alg
    iAlg = iAlg + 1;
    
    iLen = 0;
    for cLen = len
        iLen = iLen + 1;
        
        iRep = 0;
        for cNRep = nRep
            iRep = iRep + 1;
            
            iToSlice = 0;
            for cToSlice = toSlice
                
                iToSlice = iToSlice + 1;
                tEl(iAlg, iLen, iRep, iToSlice) = testCAlg;
            end
        end
    end
end

plot(squeeze(tEl(:,1,1, :)));
set(gca, 'XTickLabel', alg);


    function tEl = testCAlg
        r = RandStream(cAlg{1}, 'Seed', 'shuffle');
        fprintf('%s x %d times x %d-vector takes: ', cAlg{1}, cNRep, cLen);
        
        switch cToSlice
            case false
                tic;
                for ii = 1:cNRep
                    ta = rand(1, cLen);
                    tb = rand(1, cLen);
                    tc = rand(1, cLen);
                    td = rand(1, cLen);
                end
                tEl = toc;
                
            case true
                tic;
                for ii = 1:cNRep
                    tt = rand(4, cLen);
                    ta = tt(1,:);
                    tb = tt(2,:);
                    tc = tt(3,:);
                    td = tt(4,:);
                end
                tEl = toc;
        end
        fprintf('%d\n', tEl);
    end
end

% Result: Speed of algorithms differ less than 10%. 
% They are all very fast (<0.1 ms per ~5000 random numbers). 
%
% Calling rand 4 times was faster than calling it once and slicing.
%
% Verdict: (1) Choose algorithm on criteria other than performance.
%          (2) Don't slice.