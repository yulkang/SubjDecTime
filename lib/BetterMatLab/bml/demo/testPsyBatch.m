
f = @(a, b) a + b;
 
Batch = PsyBatch(f);
 
for ii = 1:3
    for jj = 1:5
        Batch.add({ii, jj}, {'()', {ii, jj}});
    end
end
s = Batch.run;
 
disp(s);
