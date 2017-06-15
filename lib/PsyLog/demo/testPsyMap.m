% testPsyMap
clear classes; 
Map = PsyMap({'AHV', [], [], [], []}, [5 10 10 1000]);

a = [repmat(['A', 5, 5, 5], [1000,1]), (1:1000)'];
b = (1:1000)';
tic; Map(a) = b; toc;
tic; jj = Map(a); toc;
