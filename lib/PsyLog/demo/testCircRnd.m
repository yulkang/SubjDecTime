function testCircRnd
dbstop if error

nRep = 10000;
nDot = 7; % 23
rAp  = 1;
rng('shuffle');

rt   = zeros(2,nDot); % nRep*10);
out  = false(1,nDot);
xy   = zeros(2,nDot); % nRep*10);

tDir = repeat(@() circRnd(nDot, rAp));
% tDir = repeat(@direct);

subplot(3,1,1);
cla; hold on;
plot(xy(1,:), xy(2,:), 'b.'); 

tRej = repeat(@rejection);

plot(xy(1,:), xy(2,:), 'r.'); 
axis equal; xlim([-2 2]); ylim([-2 2]); 
hold off;

subplot(3,1,2);
plot((1:nRep)*10, log(tRej./tDir));

subplot(3,1,3);
hist(log(tRej./tDir));

    function tElap = repeat(fun)
        tElap = zeros(1,nRep);
        
        for iii = 1:nRep
            tic;
            fun(); 
            tElap(iii) = toc;
        end
        
        fprintf('%30s: %1.10f sec +- %1.10f sec\n', ...
            func2str(fun), mean(tElap), std(tElap));
    end

    function rejection
        xy = rand(2,nDot);
        out = sum(xy.^2,1) > (rAp^2);
        
        while any(out)
            xy(:,out)  = (rand(2, nnz(out))-0.5) * (rAp*2);
            out = sum(xy.^2, 1) > (rAp^2);
        end
    end

    function direct
        
        rt  = rand(2,nDot);
        
        % Avoiding intermediate variable is as fast (or faster)
        % because it dispenses with allocation.
        
%         out = rt(2,:) > rt(1,:);
%         rt(:,out) = 1-rt(:,out);
%         
        rt(:,rt(2,:) > rt(1,:)) = 1-rt(:,rt(2,:) > rt(1,:));
        
        rt(2,:)   = rt(2,:) ./ rt(1,:) * 2*pi;
        rt(1,:)   = rt(1,:) .* rAp;
        
        xy(1,:)   = rt(1,:) .* cos(rt(2,:));
        xy(2,:)   = rt(1,:) .* sin(rt(2,:));
        
%         dia = 2*pi*rAp;
%         
%         rt  = bsxfun(@times, rand(2,nDot), [rAp; dia]);
%         out = rt(2,:) > rt(1,:) * (2*pi);
%         
%         rt(:,out) = bsxfun(@minus, [rAp; dia], rt(:,out));
%         rt(2,:)   = rt(2,:) ./ rt(1,:);
%         
%         xy(1,:)   = rt(1,:) .* cos(rt(2,:));
%         xy(2,:)   = rt(1,:) .* sin(rt(2,:));
    end

save;
end