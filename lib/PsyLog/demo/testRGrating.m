%% Task parameters
pCol2Rep = [0.3 0.4 0.6 0.7];
muThRep  = [0 15 30 45];

nCol  = 40;
pCol2 = pCol2Rep(randi(length(pCol2Rep)))
muTh  = muThRep(randi(length(muThRep)))  % pi/2; % 0;
sigTh = 20; % pi/8;
ph      = -90;

%% Spatial parameters
rApIn = 1;
rApOut = 1.8;

pixPerDeg = 60; % for testing.
graFreq = 3; % cpd

spFreq  = graFreq / pixPerDeg;
spSig   = rApOut/2*pixPerDeg;
contrast = 200;
aspectRatio = 1;

%% Temporal parameters
T = 1; % total durationn
freqGrating = 10;

%%
[win winRect] = Screen('OpenWindow', 0, 0);
Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

refreshRate  = 60; % Screen('FrameRate', win);
nFr = T * refreshRate;

nFrGrating  = round(refreshRate / freqGrating);
presGrating = mod(1:nFr, nFrGrating) == 1;
nGrating    = sum(presGrating);
thGrating   = normrnd(muTh, sigTh, 1, nFr);

[gabor gaborRect] = CreateProceduralGabor(win, ...
    round(rApOut*2*pixPerDeg), round(rApOut*2*pixPerDeg));

%%
iGrating    = 0;
nSkip       = round(refreshRate/freqGrating);

FPCol = [100 100 100 255]';
mCol  = [127 127 255 127]';
winCenter = winRect(3:4)'/2;

rectAround = @(center, siz) repmat(center(:), [2 1]) + [-siz, siz]' * pixPerDeg;

FPrect = rectAround(winCenter, [0.05 0.05]);
gaborRect = rectAround(winCenter, gaborRect(3:4)/2/pixPerDeg);

%%
Screen('Flip', win);
WaitSecs(1);

Screen('DrawTextures', win, gabor, [], repmat(gaborRect,[1,4]), ...
        [0 45 90 135]', [], [], ...
        FPCol, [], kPsychDontDoRotation, ...
        [ph, spFreq, spSig, contrast, aspectRatio, 0, 0, 0]');
Screen('Flip', win);
WaitSecs(0.5/freqGrating);

for iFr     = 1:round(nFr/nSkip)
    th      = normrnd(muTh, sigTh);
    col2    = round(binornd(nCol,pCol2)/nCol*255);
    
    cCol    = [254-col2, col2, 254, 127]; % 255];
    
%     Screen('DrawTexture', win, gabor, [], [], ...
%         [th], [], [], ...
%         cCol, [], kPsychDontDoRotation, ...
%         [ph, spFreq, spSig, contrast, aspectRatio, 0, 0, 0]);
    
    cTh = [th]; % ; th+90];

    Screen('DrawTextures', win, gabor, [], repmat(gaborRect, [1 length(cTh)]), ...
        cTh, ...
        [], [], ...
        cCol, [], kPsychDontDoRotation, ...
        [ph, spFreq, spSig, contrast, aspectRatio, 0, 0, 0]');
    
    Screen('FillOval', win, FPCol, FPrect);
    
    for jj = 1:floor(nSkip/2)
        Screen('Flip', win, [], 1);
    end
    
    for jj = 1:(nSkip - floor(nSkip/2))
        Screen('Flip', win, [], 0);
    end
end

Screen('DrawTextures', win, gabor, [], repmat(gaborRect,[1,4]), ...
        [0 45 90 135]', [], [], ...
        FPCol, [], kPsychDontDoRotation, ...
        [ph, spFreq, spSig, contrast, aspectRatio, 0, 0, 0]');
Screen('Flip', win);
WaitSecs(0.5/freqGrating);
Screen('Flip', win);

WaitSecs(1);
Screen('Flip', win);
Screen('CloseAll');