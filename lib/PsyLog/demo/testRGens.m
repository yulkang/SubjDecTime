R{1} = RandStream('mt19937ar');
R{2} = RandStream('mcg16807');
R{3} = RandStream('mlfg6331_64');
R{4} = RandStream('mrg32k3a');
R{5} = RandStream('shr3cong');
R{6} = RandStream('swb2712');

nRep = 1000;
siz  = [2 50];
elT  = zeros(1,length(R));

for ii = 1:length(R)
    tic;
    for jj = 1:nRep
        tt = rand(R{ii},siz);
    end
    
    elT(ii) = toc;
    
    fprintf('%20s: %1.5fs\n', R{ii}.Type, elT(ii));
end