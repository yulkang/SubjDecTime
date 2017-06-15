%% Params
clear;
rng('shuffle');

Screen('Preference', 'SkipSyncTests', 2);

if true
    %% Task params
    diffBar = 0.2;
    diffCol = 0.2;
    
    pBar2 = rand*diffBar + 0.5-diffBar/2
    pCol2 = rand*diffCol + 0.5-diffCol/2
    pShow = 0.4;

    T      = 1;
    Tskip  = 0.1;
    
    %% Aperture params
    apROutDeg = 1.6;
    apRInDeg  = 0.5;

    %% Grid params
    gridSizDeg = 0.4;
    
    if true, % derived params
        nGrid = floor(apROutDeg/gridSizDeg);
        
        gridDegRep = [-flipdim(gridSizDeg:gridSizDeg:apROutDeg, 2), ...
                      0:gridSizDeg:apROutDeg];
        [gridXDeg, gridYDeg] = meshgrid(gridDegRep, gridDegRep);
        gridXDeg = gridXDeg(:)';
        gridYDeg = gridYDeg(:)';

        gridDDeg = sqrt(gridXDeg.^2+gridYDeg.^2);
        
        xyIn     = mod([-flipdim(1:nGrid,2), 0:nGrid], 2) == 0;
        gridIn   = (gridDDeg>=apRInDeg) & (gridDDeg<=apROutDeg);
        gridIn   = gridIn & hVec(bsxfun(@xor, xyIn, xyIn'));
        
        gridXDeg = gridXDeg(gridIn);
        gridYDeg = gridYDeg(gridIn);
        
        subplot(1,3,1);
        plot(gridXDeg,gridYDeg,'.');
        axis equal; axis square;
    end
    
    %% Bar params
    barLenDeg   = gridSizDeg*0.5;
    barWidthDeg = 0.075;
    
    if true,
        nBar = length(gridXDeg);
        
        barHorzStXYDeg = [gridXDeg-barLenDeg/2
                          gridYDeg];
        barHorzEnXYDeg = [gridXDeg+barLenDeg/2
                          gridYDeg];
                     
        barVertStXYDeg = [gridXDeg
                          gridYDeg-barLenDeg/2];
        barVertEnXYDeg = [gridXDeg
                          gridYDeg+barLenDeg/2];
    
        barXYDeg(1:2,1:2:(nBar*2),1) = barHorzStXYDeg;
        barXYDeg(1:2,2:2:(nBar*2),1) = barHorzEnXYDeg;
        
        barXYDeg(1:2,1:2:(nBar*2),2) = barVertStXYDeg;
        barXYDeg(1:2,2:2:(nBar*2),2) = barVertEnXYDeg;
        
        bar2    = zeros(1,nBar);
        
        dupl    = @(v) reshape([v;v],1,[]);
        qupl    = @(v) repmat(dupl(v), [2 1]);
    end
    
    %% Color params
    col = [200 255 0; 0 255 255]';
    col2 = zeros(1,nBar);
    
    col2col = @(c2) col(:,dupl(c2)+1);
    
    %% FP params
    colFP = 70;
    FPRDeg = 0.05;
    
    %% Device params
    scr = 0;
    refreshRate = 60;
    pixPerDeg   = 60; % arbitrary
    
    rect = Screen('rect', scr);
    
    centerPix   = (rect(3:4)/2 + rect(1:2))';
    
    if true,
        frSkip = round(Tskip * refreshRate);
        nFr = T*refreshRate/frSkip;
        
        barXYPix = bsxfun(@plus, barXYDeg * pixPerDeg, centerPix);
        bar2bar = @(b2) barXYPix(:,:,1).*qupl(~b2) + barXYPix(:,:,2).*qupl(b2);
        
        barWidthPix = barWidthDeg * pixPerDeg;
        
        FPRPix  = FPRDeg * pixPerDeg;
        rectFP = [centerPix - FPRPix, centerPix + FPRPix];
    end
end


%%
win = Screen('OpenWindow', scr, 0);
HideCursor;
Screen('FillOval', win, colFP, rectFP);
Screen('Flip', win);
WaitSecs(1);

nBar2 = zeros(1,nFr);
nCol2 = zeros(1,nFr);
nBarShow = round(nBar*pShow);

for ii = 1:nFr
    col2 = rand(1,nBar)<pCol2;
    bar2 = rand(1,nBar)<pBar2;
    
    toShow = randperm(nBar)<=nBarShow;
    
    nBar2(ii) = sum(bar2(toShow));
    nCol2(ii) = sum(col2(toShow));
    
    barShow = bar2bar(bar2);
    colShow = col2col(col2);
    
    Screen('DrawLines', win, barShow(:,dupl(toShow)), ...
                barWidthPix, colShow(:,dupl(toShow)));
            
    for jj = 1:frSkip
        Screen('FillOval', win, colFP, rectFP);
        Screen('Flip', win);
    end
end
WaitSecs(1);
ShowCursor;
Screen('CloseAll');

%%
subplot(1,3,2);
plot(1:nFr,(nBar2)/nBarShow,'ko-',1:nFr,(nCol2)/nBarShow,'bx-');
crossLine('h', pBar2, 'k-', pCol2, 'b-');
ylim([0, 1]);

subplot(1,3,3);
plot(1:nFr,cumsum(nBar2),'ko-',1:nFr,cumsum(nCol2),'bx-');
crossLine('h', pBar2*nBarShow*nFr, 'k-', pCol2*nBarShow*nFr, 'b-');
ylim([0, nBarShow*nFr]);