% testSlicing

%%
clear all;

nRep = 200;
nDot = 2000;
nSet = 3;

[r1 r2 r3] = RandStream.create('mlfg6331_64', 'Seed', 'shuffle', 'Numstreams', 3);

temp = rand(r1, 1, 1);
temp = rand(r2, 1, 1);
temp = rand(r3, 1, 1);

tic;
tt = zeros(2,nDot,nSet);
tt = zeros(2,nDot,nSet);
tt = zeros(2,nDot,nSet);

for ii = 1:nRep
    iSet = mod(ii,3)+1;
    
    tt2 = rand(r1, 2,nDot);
    tt(:,:,iSet) = tt2;
    
    tt2 = rand(r2, 2,nDot);
    tt(:,:,iSet) = tt2;
    
    tt2 = rand(r3, 2,nDot);
    tt(:,:,iSet) = tt2;
end
toc;


%%
clear all;

nRep = 200;
nDot = 2000;

[r1 r2 r3] = RandStream.create('mlfg6331_64', 'Seed', 'shuffle', 'Numstreams', 3);

temp = rand(r1, 1, 1);
temp = rand(r2, 1, 1);
temp = rand(r3, 1, 1);

tic;
tt = zeros(2,nDot,nRep);
tt = zeros(2,nDot,nRep);
tt = zeros(2,nDot,nRep);

for ii = 1:nRep
    tt2 = rand(r1, 2,nDot);
    tt(:,:,ii) = tt2;
    
    tt2 = rand(r2, 2,nDot);
    tt(:,:,ii) = tt2;
    
    tt2 = rand(r3, 2,nDot);
    tt(:,:,ii) = tt2;
end
toc;

% %%
% clear all;
% 
% nRep = 200;
% nDot = 2000;
% 
% [r1 r2 r3] = RandStream.create('mlfg6331_64', 'Seed', 'shuffle', 'Numstreams', 3);
% 
% temp = rand(r1, 1, 1);
% temp = rand(r2, 1, 1);
% temp = rand(r3, 1, 1);
% 
% tic;
% tt = rand(r1, 2, nDot, nRep);
% tt = rand(r2, 2, nDot, nRep);
% tt = rand(r3, 2, nDot, nRep);
% for ii = 1:nRep
%     tt2 = tt(:,:,ii);
%     tt2 = tt(:,:,ii);
%     tt2 = tt(:,:,ii);
% end
% toc;

