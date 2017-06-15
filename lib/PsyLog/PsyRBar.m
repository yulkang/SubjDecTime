classdef PsyRBar < PsyPTB & PsyRStream
    properties
        %% Aperture
        apCenterDeg   = [0 0];
        apRDeg        = 2.5;
        apInnerRDeg   = 0;
        
        apCenterPix   = [];
        apRPix        = [];
        apInnerRPix   = [];
        apDiaPix      = [];
        apRect        = [];
        
        %% Grid
        % Gridspacing == width == height of a square grid, whose every other
        % knot will have a bar.
        %
        %     s
        %   +---B---+ ...
        % s |   |   |
        %   B---+---B ...
        %   :   :   :
        %
        % s: spacing.
        % B: bar.
       
        gridSpacingDeg = [];
        gridSpacingPix = [];
        
        %% Bar
        barLenDeg   = 0.3;
        barLenPix   = [];
        barWidthDeg = 0.1;
        barWidthPix = [];
        
        bar2isHorz  = true;
        barCenterDeg = zeros(2,0);
        barCenterPix = zeros(2,0);
        
        % barXY: (x,y) x (2N) x (horz, vert).
        barXY       = zeros(2,0,2);
        
        nDot        = nan;
%         nBar        = nan; % Calculated from apRDeg and gridSpacingDeg.
        
        %% Frames, Evidence strength
        nFrSet      = 2; % Number of frames to alternate through.
        cFr         = 0;
        
        showOnFr    = []; % Each frame will show exactly the same number of bars.
        
        pBar2       = 0.5;
        pCol2       = 0.5;
        
        %% Color, etc.
        colors      = [255 255 0; 0 255 255]';
        
        info        = [];
        
        %% Things that are updated every frame.
        
        cFrSet      = 0;  % Cycles through 1:nFrSet
        
        % xyPix     : defined in superclass PsyPTB.
        
        % Color. Either 0 or 1. 0 means cols(1,:), 1 means cols(2,:)
        col2        = []; 
        toShow      = [];
        
        % Bar orientation. Either 0 or 1. 0 means bar1, 1 means bar2.
        bar2        = [];
        
        n           = 0;  % Number of frames shown
        maxN        = []; % Maxmimum number of frames to show
        
        %% RandStream & Replay-related
        % replayLevel
        % 'none'    : Sample anew.
        % 'contents': Use orientations/colors in the log. Overwrite timestamps.
        % 'all'     : Leave log untouched.
        replayLevel = 'none';
        
        toReplay    = 0;
        
        rO = PsyRStream; % For bar orientation
        rC = PsyRStream; % For bar color
        
        %% Analysis
        % momentary and cumulative evidence, and sum.
        % p is the actual moment-by-moment proportion,
        % n is the number of bars. (Scalar -- same across all frames.)
        
        ev = struct('O', struct('mom', [], 'cum', [], 'sum', nan, 'p', [], 'n', nan), ...
                    'C', struct('mom', [], 'cum', [], 'sum', nan, 'p', [], 'n', nan));
    end
    
    
    methods
        %% Before experiment
        function me = PsyRBar(cScr, varargin)
            me = me@PsyPTB;
            me.updateOn = {'befDraw'};
            
            me.tag = 'RBar';
            
            if nargin > 0, me.Scr = cScr; end
            
            if nargin > 1
                init(me, varargin{:});
            end
        end
        
        
        function init(me, pBar2, pCol2, rSeed, varargin)
            % init(me, pBar2, pCol2, rSeed, varargin)
            %
            % rSeed: 'shuffle', 'reset', or specific number.
            %
            % init() without arguments will reset rStream, and do 
            % other necessary initialization without changing 
            % parameters, so as to generate the same dot pattern again.
            
            %% Arguments
            try me.pBar2 = pBar2; catch, end
            try me.pCol2 = pCol2; catch, end
            
            varargin2fields(me, varargin);

            %% RandStreams
            initRStream(me, rSeed);
            
            % Because first call of rand() for the randstream takes ~0.1 second, 
            % use it once, whether it is reset or created.
            update(me, 'init');
        end
        
        
        function initLogEntries(me, varargin)
            if nargin > 2
                me.initLogEntries@PsyPTB(varargin{:});
            else
                switch me.replayLevel
                case 'none'
                    me.initLogEntries@PsyLogs('propCell', {'bar2', 'col2', 'toShow'}, ...
                                             'fr', {}, me.maxN); 
                case 'contents'
                    me.initTimeEntries({'bar2', 'col2', 'toShow'}, ...
                                             me.maxN); 
                end
            end
        end
        
        
        function initLogTrial(me) 
            me.initTrial;
            me.initLogEntries;
            me.initLogTrial@PsyLogs;
        end
        

        %% Before experiment - Subfunctions
        function n = getNDot(me)
            n = round(me.dotDensity * (me.apRDeg * 2)^2 / me.Scr.info.refreshRate);
        end
        
        
        function initTrial(me)
            % Initializes for a trial.
            %
            % Now that me.Scr is there, 
            % we can do unit tansformation & allocate memory.
            
            me.n = 0;
            if isempty(me.maxN)
                me.maxN = ceil(me.Scr.info.maxSec * me.Scr.info.refreshRate);
            end
            
            me.win = me.Scr.info.win;
            
            %% Unit transformation
            me.nDot = me.getNDot;
            
            me.apRPix       = me.apRDeg * me.Scr.info.pixPerDeg;
            me.apInnerRPix  = me.apInnerRDeg * me.Scr.info.pixPerDeg;
            me.apDiaPix     = me.apRPix * 2;
            me.apCenterPix  = deg2pix(me.Scr, me.apCenterDeg')'; %  - me.apRPix;
            me.apRect       = [me.apCenterPix - me.apRPix, ...
                               me.apCenterPix + me.apRPix];
            
            me.dotSizePix   = me.dotSizeDeg * me.Scr.info.pixPerDeg;
            
            me.dXYPixPerFr  = me.dXYDegPerSec / me.Scr.info.refreshRate ...
                                              * me.Scr.info.pixPerDeg;
            
            %% Allocate memory
            me.xyPix    = zeros(2, me.nDot);
            me.bar2     = false(1, me.nDot);
            me.col2     = false(1, me.nDot);
            
            % toShow: in square sampling, will be updated. 
            %         in circle sampling, will remain unchanged.
            me.toShow   = true(1, me.nDot);
        end
        
        
        %% During experiment
        function update(me, from) 
            % Sample from square and show only those in circular aperture.

            if ~any(strcmp(from, 'befDraw')) || ~me.visible, return; end
            
            me.n       = me.n + 1;

            switch me.replayLevel
                case 'none'
                    updateXY(me);
                    updateCol(me);
                    updateLog(me);
                    
                case 'contents'
                    loadXY(me);
                    loadCol(me);
                    updateLog(me);
                    
                case 'replayO'
                    loadXY(me);
                    updateCol(me);
                    updateLog(me);
                    
                case 'replayC'
                    updateXY(me);
                    loadCol(me);
                    updateLog(me);
                    
                case 'all' % Leave log untouched.
                    loadXY(me);
                    loadCol(me);
            end     
        end
        
        
        function res = draw(me, win)
            if nargin < 2, win = me.win; end
            
            if any(me.toShow)
                Screen('DrawLines', ...
                    win, ...
                    me.xyPix, ...
                    me.penWidthPix, ...
                    me.colors(:, me.col2 + 1), ...
                    me.apCenterPix);
            end
            
            res = 1;
        end
        
        
        %% During experiment - Subfunctions
        function xy = sampleXY(me, nJump, r)
            % xy = sampleXY(me, nJump, r)
            
            if nargin < 3
                xy = (rand(me.rStream, 2, nJump) - 0.5) * me.apDiaPix;
            else
                xy = (r - 0.5) * me.apDiaPix;
            end
        end
        
        
        function updateXY(me)
            % Jumps
            toJump = rand(me.rStream, 1, me.nDot) > abs(me.coh);

            % Keep routines that run on the first and following calls 
            % as similar as possible.
            r  = me.randXY;

            me.xyPix(:, toJump) = me.sampleXY(nnz(toJump), r(:, toJump));

            if me.n <= me.nFrSet
                me.xyPix = me.firstPix(:,:,me.n); 

            else 
                % Constrain movement to x direction.
                me.xyPix(:,~toJump) = me.v_.xyPix{me.n - me.nFrSet}(: ,~toJump);
                me.xyPix(1,~toJump) = me.xyPix(1,~toJump) ...
                                    + abs(me.dXYPixPerFr(1)) * sign(me.coh);

                me.wrapXY(r);
            end
            
            me.maskXY;
        end
        
        
        function updateCol(me)
            % Colors are updated every frame.
            me.col2(1,:) = (rand(me.rStream, 1, me.nDot) < me.prop);
        end
        
        
        function updateLog(me)
            % Log
            addLog(me, {'xyPix', 'col2', 'toShow'}, me.Scr.cFr);
        end
        
        
        %% After experiment
        function closeLog(me)
            % CLOSELOG  Convert pixel coordinates to degrees.
            
            closeLog@PsyPTB(me, 'pix2deg');
        end
        
        
        %% Replay related functions % Unused for now.
%         function loadXY(me)
%             me.xyPix  = me.v_.xyPix{me.n};
%             me.toShow = me.v_.toShow{me.n};
%         end
%         
%         
%         function loadCol(me)
%             me.col2   = me.v_.col2{me.n};
%         end
        
        
        %% Analysis functions
        function [eMot, eMotVec, cME, tf] = roughEnMot(me)
            % [eMot, eMotVec, cME, tf] = roughEnMot(me)
            %
            % Rough motion energy, given by the number of dots moving coherently.
            
            xyPix   = cell2mat3(me, 'xyPix');
            xyPix   = xyPix(:,:,2);
            xyPix(~cell2mat3(me, 'toShow')) = nan;
            
            tf      = PsyRDKCol.findSame(xyPix, me.nFrSet) .* sign(me.coh);
            eMotVec = hVec(sum(tf, 2));
            cME     = cumsum(eMotVec);
            eMot    = sum(eMotVec);
        end
        
        
        function [CEsum, mCE, cCE, tf] = roughEnCol(me, LLR, propRep)
            % [CEsum, mCE, cCE, tf] = roughEnCol(me, LLR)
            % [eCol, eColVec, tf] = roughEnCol(me, [], propRep)
            %
            % On average, exact for a given frame. But over multiple frames,
            % sluggishness of screen and the subject's color perception
            % can increase a dot's effective lifetime and change the energy.
            %
            % LLR: LLR vector pre-computed with PsyRDKCol.LLRCol().
            %
            % See also: LLRCOL ROUGHENMOT CELL2MAT3
            
            toShowMat = cell2mat3(me, 'toShow');
            tf        = cell2mat3(me, 'col2') & toShowMat;
            
            if isempty(toShowMat) || isempty(tf)
                mCE = [];
                cCE = [];
                CEsum = nan;
            end
            
            if isempty(LLR)
                LLR     = LLRCol(me.nDot, propRep);
            end
            
            % Calculate frame-by-frame LLR to account for
            %       variation in the number of shown dots.
            mCE     = hVec(subsMulti(LLR, sum(tf, 2)+1, sum(toShowMat, 2)+1));
            cCE     = cumsum(mCE);
            CEsum   = cCE(end);
            
            me.ev.C.mom = mCE;
            me.ev.C.cum = cCE;
            me.ev.C.sum = CEsum;
        end
        
        
        function getCPix(me, useGPU)
            % getCPix(me)
            %
            % Clear cPix after ENMOT -- it takes huge memory!
            %
            % See also: ENMOT, CLEARCPIX
            
            if ~exist('useGPU', 'var'), useGPU = false; end
            
            mat3    = me.cell2mat3('xyPix');
            
            if isempty(mat3), me.cPix = []; me.bwPix = []; return; end
            
            pixDot  = (0:max(round(me.dotSizePix)-1, 0)) - floor(me.dotSizePix/2);
            
            xyLen   = round(me.apRPix(1))*2+1 + abs(pixDot(1))+abs(pixDot(end)) + 2; % Give enough space
            tLen    = size(mat3, 1);
            
            ccPixOrig = zeros(xyLen, xyLen, tLen, 2);
            ccPix   = ccPixOrig;
            
            xVec    = round(hVec(mat3(:,:,1)) + me.apRPix) + 1 + abs(pixDot(1));
            yVec    = round(hVec(mat3(:,:,2)) + me.apRPix) + 1 + abs(pixDot(1));
            tVec    = rep2fit(1:tLen, size(xVec));
            cVec    = hVec(me.cell2mat3('col2')) + 1;
            
            sVec    = (xVec >= 0) & (xVec <= me.apDiaPix) ...
                    & hVec(me.cell2mat3('toShow'));
                
            xVec    = xVec(sVec);
            yVec    = yVec(sVec);
            tVec    = tVec(sVec);
            cVec    = cVec(sVec);
                
%             xVecOrig    = xVec(sVec);
%             yVecOrig    = yVec(sVec);
%             
%             xVec = zeros(1, length(xVecOrig) * (length(pixDot)^2));
%             yVec = xVec;
%             
%             tVec = repmat(tVec(sVec), [1, length(pixDot)^2]);
%             cVec = repmat(cVec(sVec), [1, length(pixDot)^2]);
            
%             cSt = 1;
%             cEn = length(xVecOrig);
%             
%             for xPixDot = pixDot
%                 for yPixDot = pixDot
%                     
%                     xVec(cSt:cEn) = xVecOrig + xPixDot;
%                     yVec(cSt:cEn) = yVecOrig + yPixDot;
%                     
%                     cSt = cSt + length(xVecOrig);
%                     cEn = cEn + length(xVecOrig);
%                 end
%             end
            
            ix      = sub2ind([xyLen, xyLen, tLen, 2], yVec, xVec, tVec, cVec);
            
            ccPixOrig(ix) = 1;
            
            for xPixDot = pixDot
                for yPixDot = pixDot
                    
                    ccPix = ccPix | circshift(ccPixOrig, ...
                        [yPixDot, xPixDot, 0, 0]);
                end
            end
            
            if useGPU
                try
                    me.cPix  = gpuArray(ccPix);
                catch 
                    me.cPix  = ccPix;
                end
            else
                me.cPix = ccPix;
            end
%             me.cPix(ix) = 1;
%             me.cPix  = reshape(me.cPix, [xyLen, xyLen, tLen, 2]);
            me.bwPix = min(squeeze(sum(me.cPix, 4)), 1);
        end
        
        
        function [h cMat] = plotCPix(me, col, fr)
            if nargin < 2, col = 'bw'; end
            if nargin < 3, fr = 1; end
            
            if isempty(me.cPix), me.getCPix; end
            
            switch col
                case 'c'
                    cMat = me.cPix(:,:,fr,1) ...
                         + me.cPix(:,:,fr+me.nFrSet,1) * 2 ...
                         + me.cPix(:,:,fr,2) * 3 ...
                         + me.cPix(:,:,fr+me.nFrSet,2) * 4;
                    
                case 'bw'
                    cMat = me.bwPix(:,:,fr) ...
                         + me.bwPix(:,:,fr + me.nFrSet)*2;
            end
            
            h = imagesc(cMat);
            title(sprintf('coh %1.3f, prop %1.3f', me.coh, me.prop));
        end
        
        
        function clearCPix(me)
            % clearCPix(me)
            %
            % Clear cPix after ENMOT -- it takes huge memory!
            %
            % See also GETCPIX, ENMOT
            
            me.cPix = [];
            me.bwPix = [];
        end
        
        
        function [MEsum, mME, cME, MFilt] = EnMot(me, MFilt, varargin)
            % [MEsum, mME, cME, MFilt] = EnMot(me, MFilt, addSec)
            %
            % Clear cPix after ENMOT -- it takes huge memory!
            %
            % See also CLEARCPIX, 
            %   PsyMotionFilter.apply, PsyMotionFilter.PsyMotionFilter
            
            if ~exist('MFilt', 'var') || isempty(MFilt)
                MFilt = PsyMotionFilter(me); 
            end
            
            if isempty(me.cPix) || isempty(me.bwPix)
                me.getCPix;
            end
            
            if ~isempty(me.cPix)
                mME = MFilt.apply(me, varargin{:});
                cME = cumsum(mME);
                MEsum = cME(end);
            else
                mME = [];
                cME = [];
                MEsum = 0;
            end
            
            me.ev.M.mom = mME;
            me.ev.M.cum = cME;
            me.ev.M.sum = MEsum;
        end
        
        
        function S = EnMot2S(me, varargin)
            % S = EnMot2S(me, varargin)
            %
            % S: a struct with fields MEsum, mME, and cME.
            %
            % See also PsyRDKCol.EnMot.
            
            [c{1:3}] = EnMot(me, varargin{:});
            S = cell2struct(c, {'MEsum', 'mME', 'cME'}, 2);
        end
        
        
        function [CEsum, mCE, cCE] = EnCol(me, varargin)
            % [CEsum, mCE, cCE] =  EnCol(me, varargin)
            
        end
        
        
        function res = cell2mat3(me, name)
            % CELL2MAT3  Convert into T x nDot x (x,y) matrix,
            %            from 1 x T cells of (x,y) x nDot.
            %
            % res = cell2mat3(me, name)
            
            res = permute(cell2mat(reshape2vec(me.vTrim(name), 3)), [3 2 1]);
        end
        
        
        function h = plotTraj(me)
            hold on;
            
            th = 0:0.1:(2.1*pi);
            [x y] = pol2cart(th, me.apRPix);
            plot(x, y,'b-', 'LineWidth', 0.5); box off;
            hold on;
            h = crossLine('h', [0, -me.apRPix, me.apRPix], 'k-');
            h = crossLine('v', [0, -me.apRPix, me.apRPix], 'k-');

            axis equal; axis square;
            xlim([-me.apRPix, me.apRPix]*1.2);
            ylim([-me.apRPix, me.apRPix]*1.2);

            xyPix = me.cell2mat3('xyPix');
            xPix = squeeze(xyPix(:,:,1));
            yPix = squeeze(xyPix(:,:,2));
            for jj = 1:me.nFrSet
                c = zeros(1,3);
                c(mod(jj,3)+1) = 1; % jj = rand(1,3); %  .* (0.5 + 0.5.*round(rand(1,3)));
                disp(c);
                for ii = 1:me.nDot
                
                    h = gradLine(xPix(jj:me.nFrSet:end,ii),yPix(jj:me.nFrSet:end,ii),...
                        c, 'LineWidth', 2);
                end
            end

            hold on;
            plot(me.xyPix(1,:), me.xyPix(2,:), 'b.');
            plot(me.xyPix(1,me.toShow), me.xyPix(2,me.toShow), 'r.');
            hold off;
            
            h = gca;
        end
    end
    
    
    methods (Static)
        function tf = findSame(mat, step)
            % tf = findSame(mat, step)
            
            tf = false(size(mat));

            for cStep = 1:step
                tf((cStep+step):step:end,:) = ...
                    (mat(cStep:step:(end-step),:) == mat((cStep+step):step:end,:));
            end
        end
        
        
        function LLRNcol2 = LLRCol(nDot, propRep, considerAp)
            % LLRCol    Log likelihood ratio of the answer being color 2 over 1.
            %
            % LLRNcol2 = LLRCol(nDot, propRep, considerAp = false)
            %
            % LLRNcol2(NColor2+1)
            %       = Exact log likelihood of the answer being color 2 over 1,
            %         given a frame with NColor2 dots having color 2.
            %
            % considerAp
            %     : If true (default) calculates mean effective number of dots,
            %       based on the proportion of dots in a circle filling a 
            %       sqrare.
            %
            % Give nDot as a vector to get LLRNcol2 of size (NColor2+1, nDot+1).
            
            if ~exist('considerAp', 'var'), considerAp = false; end
            
            if considerAp
                nDotEffec = round(nDot .* pi./4);
            else
                nDotEffec = nDot;
            end
            
            if numel(nDotEffec) > 1
                
                LLRNcol2 = zeros(max(nDotEffec)+1, max(nDotEffec)+1);
                
                for cNDot = hVec(nDotEffec)
                    LLRNcol2(1:(cNDot+1), cNDot+1) = ...
                        PsyRDKCol.LLRCol(cNDot, propRep, false);
                end
                
            elseif nDotEffec == 0
                LLRNcol2 = 0;
                
            else
                nPropRep  = length(propRep);

                pNCol2 = zeros(nPropRep, nDotEffec+1);

                for iProp = 1:nPropRep
                    cProp = propRep(iProp);

                    pNCol2(iProp,:) = binopdf(0:nDotEffec, nDotEffec, cProp);
                end
                
                pPropGivenNCol2 = bsxfun(@rdivide, pNCol2, sum(pNCol2,1));
                p2GivenNCol2    = sum(pPropGivenNCol2((propRep>0.5), :), 1);
                p1GivenNCol2    = sum(pPropGivenNCol2((propRep<0.5), :), 1);
                LLRNcol2        = log(p2GivenNCol2) - log(p1GivenNCol2);
            end
        end
        
        
        function [x y] = gridPoint(rOut, rIn, gridSize, toPlot)
            % [x y] = gridPoint(rOut, rIn, gridSize, [toPlot = false])
            
            if ~exist('toPlot', 'var'), toPlot = false; end
            
            rO2 = floor(rOut / gridSize) * gridSize;
            
            xRep = [-rO2:gridSize:-gridSize, 0:gridSize:rO2];
            yRep = xRep;
            
            [x y] = meshgrid(xRep, yRep);
            
            x = x(:);
            y = y(:);
            d = x.^2 + y.^2;
            
%             ind  = (1:length(x))';
%             ind0 = mod(ind((x==0) & (y==0)), 2);
            
            toIncl = (rIn.^2 <= d) & (d <= rOut.^2); %  & (mod(ind,2)==ind0);
            
            x = x(toIncl);
            y = y(toIncl);
            
            if toPlot
                [oX oY] = pol2cart(0:0.1:pi*2.1, rOut);
                [iX iY] = pol2cart(0:0.1:pi*2.1, rIn);
                
                plot(oX, oY, 'k-', iX, iY, 'k-'); hold on;
                plot(x,y,'b.'); axis equal; axis square; hold off;
            end
        end
        
        
        function [rX rY] = drawXY(r, x, y, n)
            if isempty(r)
                rr = rand(2,n);
            else
                rr = rand(r,2,n);
            end
            
            
        end
    end
end