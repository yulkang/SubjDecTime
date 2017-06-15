%%
Nt = 376; % 30;
Na = 2^8; % 1000;
Nb = 2^8; % 1000;

%%
tcnv = 0;
tmtx = 0;

for kj = 1:Nt
    a = randn(Na,1);
    b = randn(Nb,1);

    tic
    n = conv(a,b);
    tcnv = tcnv+toc;

    tic
    c = convmtx(b,Na);
    d = c*a;
    tmtx = tmtx+toc;
end

t1col = [tcnv tmtx]/Nt
t1rat = tcnv\tmtx

%% conv is now faster than fconv!!
Nchan = 1;
Nt = 100;

tfcnv = 0;
tcnv = 0;
tmtx = 0;

n = zeros(Na+Nb-1,Nchan);
clear c

b = randn(Nb,Nchan);

for kj = 1:Nt
    a = randn(Na,Nchan);

    tic
    for k = 1:Nchan
        n(:,k) = fconv(a(:,k),b(:,k));
    end
    tfcnv = tfcnv+toc;

    tic
    for k = 1:Nchan
        n(:,k) = conv(a(:,k),b(:,k));
    end
    tcnv = tcnv+toc;

%     tic
%     if kj == 1
%         for k = Nchan:-1:1
%             c{k} = convmtx(b(:,k),Na);
%         end
%     end
%     for k = Nchan:-1:1
%         d = c{k}*a;
%     end
%     tmtx = tmtx+toc;
end

tmcol = [tfcnv tcnv tmtx] % /Nt
% tmrat = tcnv/tmtx