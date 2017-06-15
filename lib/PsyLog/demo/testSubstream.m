% testSubstream

nDot = 1670;
nRep = 1000;    

[r1 r2 r3] = RandStream.create('mlfg6331_64', 'Seed', 'shuffle', ...
                                              'NumStreams', 3);
tic;
for ii = 1:nRep
    rand(r1, 2, nDot);
    rand(r2, 2, nDot);
    rand(r3, 2, nDot);
end
toc;


[rs1 rs2 rs3] = RandStream.create('mlfg6331_64', 'Seed', 'shuffle', ...
                                          'NumStreams', 3);

tic;
for ii = 1:nRep
    rs1.Substream = ii;
    rand(rs1, 2, nDot);
    
    rs2.Substream = ii;
    rand(rs2, 2, nDot);
    
    rs3.Substream = ii;
    rand(rs3, 2, nDot);
    
end
toc;
