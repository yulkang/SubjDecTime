n = 1000;

Map2 = PsyMap2({[], [], []}, [1000, 1000, 1000])
r = randi(1000, [n, 3]);
r2 = randi(1000, [n, 1]);
tic; Map2(r) = r2; toc;

Map = PsyMap({[], [], []}, [1000, 1000, 1000])
r = randi(1000, [n, 3]);
r2 = randi(1000, [n, 1]);
tic; Map(r) = r2; toc;




