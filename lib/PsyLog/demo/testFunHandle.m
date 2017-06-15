nRep = 10;
a = magic(100);
f = @() sin(a);

tic;
for ii = 1:nRep
    b = sin(a);
end
toc;

tic;
for ii = 1:nRep
    b = f();
end
toc;

% There's more overhead in function handle, but it doesn't scale much with
% the data size. 