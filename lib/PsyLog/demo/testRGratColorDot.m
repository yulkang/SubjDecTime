%% Task parameters
pCol2 = 0.6;
muTh  = pi/2; % 0;
sigTh = pi/8;

%% Spatial parameters
rApIn = 1;
rApOut = 1.8;

pixPerDeg = 1/60; % for testing.

graFreq = 3; % cpd
dotSize = 1 / (graFreq*2);

xRep = [-flipdim(0:dotSize:rApOut, 2), dotSize:dotSize:rApOut];
yRep = [-flipdim((dotSize*1.5):(dotSize*3):rApOut, 2), (dotSize*1.5):(dotSize*3):rApOut];
[x y] = meshgrid(xRep, yRep);

d = sqrt(x.^2 + y.^2);
inAp = (d >= rApIn) & (d <= rApOut);

x = x(inAp);
y = y(inAp);
nDot = nnz(inAp);



%% Loop
set(gcf, 'color', 'k');
set(gca, 'color', 'k');

col = [1 0 0; 0 0.8 0];

nFr = 12;
for ii = 1:nFr
    %%
%     tic;
    if ii<=nFr-1
        cla;
    end
    
    if ii == nFr-1
        col2 = mod(randperm(nDot),2)==1
        
        th = 0;
    elseif ii == nFr
        th = pi/2;
    else
        col2 = rand(1,nDot) < pCol2;
        th = normrnd(muTh, sigTh);
    end
    
    rotMat = [cos(th), -sin(th); sin(th), cos(th)];

    xy = (rotMat * [x(:), y(:)]')';
    
    viscircles(xy(col2,:), zeros(nnz(col2),1)+dotSize/2.2, ...
        'FaceColor', col(2,:), 'EdgeColor', 'none'); 
    viscircles(xy(~col2,:), zeros(nnz(~col2),1)+dotSize/2.2, ...
        'FaceColor', col(1,:), 'EdgeColor', 'none'); 
%     axis equal; axis square; %  axis off;
    if ii ~= nFr-1
        drawnow;
    end
    
    fprintf('th: %+1.2f, pCol2: %1.2f\n', th/pi, nnz(col2)/length(col2));
%     toc;
end
cla;
fprintf('\n');

%%

%% Temporal parameters
T = 3;

%%
win = Screen('OpenWindow', 0);
Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

refreshRate  = Screen('FrameRate', win);
nFr = T * refreshRate;

freqGrating = 10;
nFrGrating  = round(refreshRate / freqGrating);
presGrating = mod(1:nFr, nFrGrating) == 1;
nGrating    = sum(presGrating);
thGrating   = normrnd(muTh, sigTh, 1, nFr);


%%

iGrating    = 0;
for iFr = 1:nFr
    if presGrating(iFr)
        iGrating = iGrating + 1;

        
    end
    
    Screen('Flip', win);
end