classdef PsyRDKCol < PsyPTB & PsyRStream
    properties
        dotDensity  = 16.7; % dots per deg^2 per second.
        
        apCenterDeg   = [0 0];
        apRDeg        = 2.5;
        apInnerRDeg   = 0;
        
        apCenterPix   = [];
        apRPix        = [];
        apInnerRPix   = [];
        apDiaPix      = [];
        apRect        = [];
        
        dotSizeDeg  = 0.1;
        dotSizePix  = [];
        
        dXYDegPerSec= [5; 0]; % 5 deg/sec.
        dXYPixPerFr = [];
        
        dotType     = 0; % 0: square (default), 1: circle, 2: high quality circle.
        
        firstPix    = [];
        
        reverse_mot = false; % determine dX dY from 180 + mot_dir        
        reverse_col = false;
        
        % replayLevel
        % 'none'    : Sample anew.
        % 'contents': Use positions/colors in the log. Overwrite timestamps.
        % 'all'     : Leave log untouched.
        replayLevel = 'none';
        
        toReplay    = 0;
        
        nFrSet      = 3; % Number of frames to alternate through.
        cFr         = 0;
        
        nDot        = [];
        
        colors      = [255 255 0; 0 255 255; 212 212 212]'; 
        
        coh         = 0.05;
        prop        = 0.5;
        
        info        = [];
        
        % Things that will update every frame.
        cFrSet      = 0;  % Cycles through 1:nFrSet
        
        % xyPix     : defined in superclass PsyPTB.
        
        % Color. Either 0 or 1. 0 means cols(1,:), 1 means cols(2,:)
        col2        = []; 
        toShow      = [];
        
        % Jumping (rather than coherently moving) dots.
        toJump      = [];
        
        n           = 0;
        maxSec      = [];
        
        iXyPix
        
        %% Analysis
        % momentary and cumulative evidence, and sum.
        ev = struct('M', struct('mom', [], 'cum', [], 'sum', nan), ...
                    'C', struct('mom', [], 'cum', [], 'sum', nan));
             
        % LLR.(PROP)(k) 
        % : log likelihood ratio of the answer being the second choice
        %   given k dots having PROP supporting the second choice.
        LLR = struct;
    end
    
    properties (Dependent)
        maxFr
    end
    
    properties (Transient)
        cPix   % (yPix, xPix, tFr, color12)
        bwPix  % (yPix, xPix, tFr)
        xyct
        MFilt
    end
    
    methods
    %% Experiment functions
        function RDK = PsyRDKCol(cScr, varargin)
            RDK = RDK@PsyPTB;
            RDK.updateOn = {'befDraw'};
            
            RDK.tag = 'RDKCol';
            
            if nargin > 0, RDK.Scr = cScr; end
            
            if nargin > 1
                init(RDK, varargin{:});
            end
        end
        
        function init(RDK, coh, prop, rSeed, varargin)
            % init(RDK, coh, prop, rSeed, varargin)
            %
            % rSeed: 'shuffle', 'reset', or specific number.
            %
            % init() without arguments will reset rStream, and do 
            % other necessary initialization without changing 
            % parameters, so as to generate the same dot pattern again.
            
            %% Arguments
            try RDK.coh  = coh; catch, end
            try RDK.prop = prop; catch, end
            
            varargin2fields(RDK, varargin);

            %% RandStreams
            initRStream(RDK, rSeed);
            
            % Because first call of rand() for the randstream takes ~0.1 second, 
            % use it once, whether it is reset or created.
            update(RDK, 'init');
        end
        
        function n = getNDot(RDK)
            n = round(RDK.dotDensity * (RDK.apRDeg * 2)^2 / RDK.Scr.info.refreshRate);
        end
        
        function initTrial(RDK)
            % Initializes for a trial.
            %
            % Now that RDK.Scr is there, 
            % we can do unit tansformation & allocate memory.
            
            if RDK.reverse_mot && RDK.coh > 0
                error('When reverse_mot == true, coh must be nonpositive!');
            end
            if RDK.reverse_col && RDK.prop > 0.5
                error('When reverse_col == true, prop must be <=0.5 !');
            end
            
            RDK.n = 0;
            if isempty(RDK.maxSec)
                RDK.maxSec = RDK.Scr.info.maxSec; % maxN is calculated from maxSec
            end
            
            RDK.win = RDK.Scr.info.win;
            
            %% Unit transformation
            RDK.nDot = RDK.getNDot;
            
            RDK.apRPix       = RDK.apRDeg * RDK.Scr.info.pixPerDeg;
            RDK.apInnerRPix  = RDK.apInnerRDeg * RDK.Scr.info.pixPerDeg;
            RDK.apDiaPix     = RDK.apRPix * 2;
            RDK.apCenterPix  = deg2pix(RDK.Scr, RDK.apCenterDeg')'; %  - RDK.apRPix;
            RDK.apRect       = [RDK.apCenterPix - RDK.apRPix, ...
                               RDK.apCenterPix + RDK.apRPix];
            
            RDK.dotSizePix   = RDK.dotSizeDeg * RDK.Scr.info.pixPerDeg;
            
            RDK.dXYPixPerFr  = RDK.dXYDegPerSec / RDK.Scr.info.refreshRate ...
                                              * RDK.Scr.info.pixPerDeg;
            
            %% Allocate memory
            RDK.xyPix    = zeros(2, RDK.nDot);
            RDK.col2     = false(1, RDK.nDot);
            RDK.firstPix = zeros([size(RDK.xyPix) RDK.nFrSet]);
            
            % toShow: in square sampling, will be updated. 
            %         in circle sampling, will remain unchanged.
            RDK.toShow   = true(1, RDK.nDot);
        end
        
        function initLogEntries(RDK, varargin)
            if nargin > 2
                RDK.initLogEntries@PsyPTB(varargin{:});
            else
                switch RDK.replayLevel
                case 'none'
                    RDK.initLogEntries@PsyLogs('propCell', {'xyPix', 'col2', 'toShow', 'toJump'}, ...
                                             'fr', {}, RDK.maxN); 
                case 'contents'
                    RDK.initTimeEntries({'xyPix', 'col2', 'toShow'}, ...
                                             RDK.maxN); 
                end
            end
        end
        
        function initPreCalc(RDK, isSimMode)
            % Precalculate first frames.
            for ii = 1:RDK.nFrSet
                RDK.firstPix(:,:,ii) = RDK.sampleXY(RDK.nDot);
            end
            
            % Pre-run to reduce real-time overhead.
            if nargin < 2 || ~isSimMode
                % Temporarily set alpha to zero
                cColor = RDK.colors;
                RDK.colors(4,:) = zeros(1, size(RDK.colors,2)); 
                
                RDK.xyPix = RDK.firstPix(:,:,1);
                
                % Pre-run the time-critical functions
                RDK.visible = true;
                update(RDK, 'befDraw');
                try
                    draw(RDK);
                catch err
                    % Warning can be ignored.
%                     warning(err_msg(err));
                end
                RDK.visible = false;
                
                % Revert color
                RDK.colors = cColor;
                
                % Revert log
                RDK.initLogTrial(true);
            end
        end
        
        function initLogTrial(RDK, varargin) 
            RDK.initTrial;
            RDK.initLogEntries;
            RDK.initLogTrial@PsyLogs;
            RDK.initPreCalc(varargin{:});
        end
        
        function xy = sampleXY(RDK, nJump, r)
            % xy = sampleXY(RDK, nJump, r)
            
            if nargin < 3
                xy = (rand(RDK.rStream, 2, nJump) - 0.5) * RDK.apDiaPix;
            else
                xy = (r - 0.5) * RDK.apDiaPix;
            end
        end
        
        function wrapXY(RDK, r)
            % wrapXY(RDK, r)
            %
            % Dots moved outside square wraps back and
            % randomly repositioned in y dimension
            % to maintain constant density without invoking 
            % motion energy to the opposite direction.
            
            c_coh = RDK.cur_coh;
            
            toWrap             = RDK.xyPix(1,:) * sign(c_coh) > RDK.apRPix;
            RDK.xyPix(1,toWrap) = RDK.xyPix(1,toWrap) - RDK.apDiaPix * sign(c_coh);
            RDK.xyPix(2,toWrap) = (r(2, toWrap)-0.5) * RDK.apDiaPix;
        end
        
        function maskXY(RDK)
            % Mask
            dist = sum(RDK.xyPix .^ 2, 1);

            if RDK.apInnerRPix > 0
                RDK.toShow = (dist < RDK.apRPix ^ 2) & (dist > RDK.apInnerRPix ^ 2);
            else
                RDK.toShow = (dist < RDK.apRPix ^ 2);
            end
        end
        
        function r = randXY(RDK)
            r = rand(RDK.rStream, 2, RDK.nDot);
        end
        
        function toJump = get_toJump(RDK)
            % Jumps
            toJump = rand(RDK.rStream, 1, RDK.nDot) > abs(RDK.cur_coh);
        end
        
        function updateXY(RDK)
            RDK.toJump = RDK.get_toJump;
            toJump = RDK.toJump;
            
            % Keep routines that run on the first and following calls 
            % as similar as possible.
            r  = RDK.randXY;

            RDK.xyPix(:, toJump) = RDK.sampleXY(nnz(toJump), r(:, toJump));

            if RDK.n <= RDK.nFrSet
                RDK.xyPix = RDK.firstPix(:,:,RDK.n); 

            else 
                RDK.xyPix(:,~toJump) = RDK.v_.xyPix{RDK.n - RDK.nFrSet}(: ,~toJump);
                RDK.xyPix(:,~toJump) = bsxfun(@plus, ...
                                        RDK.xyPix(:,~toJump), ...
                                        RDK.dXYPixPerFr(:) * sign(RDK.cur_coh));

                RDK.wrapXY(r);
            end
            
            % Coherent dots are reversed already. Since get_toJump uses abs coh, need to reverse them only.
            if RDK.reverse_mot
                RDK.xyPix(:, toJump) = mirror_xy(RDK.xyPix(:, toJump), 90); % mot_dir is assumed to be 0. % RDK.mot_dir + 90);
            end
            
            RDK.maskXY;
        end
        
        function updateCol(RDK)
            % Colors are updated every frame.
            if isnan(RDK.prop)
                RDK.col2(1,:) = 2 + zeros(1, RDK.nDot);
            else
                if RDK.reverse_col
                    % First do the opposite, then flip, so that
                    % matcheed seedC gives exactly opposite images.
                    c_prop = 1 - RDK.prop;
                else
                    c_prop = RDK.prop;
                end

                % Colors are updated every frame.
                RDK.col2(1,:) = (rand(RDK.rStream, 1, RDK.nDot) < c_prop);

                % Reverse_col always reverses color
                if RDK.reverse_col
                    RDK.col2 = ~RDK.col2;
                end
            end
        end
        
        function updateLog(RDK)
            % Log
            addLog(RDK, {'xyPix', 'col2', 'toShow', 'toJump'}, RDK.Scr.cFr);
        end
        
        function loadXY(RDK)
            RDK.xyPix  = RDK.v_.xyPix{RDK.n};
            RDK.toShow = RDK.v_.toShow{RDK.n};
        end
        
        function loadCol(RDK)
            RDK.col2   = RDK.v_.col2{RDK.n};
        end
        
        function update(RDK, from) 
            % Sample from square and show only those in circular aperture.

            if ~any(strcmp(from, 'befDraw')) || ~RDK.visible, return; end
            
            RDK.n       = RDK.n + 1;

            switch RDK.replayLevel
                case 'none'
                    updateXY(RDK);
                    updateCol(RDK);
                    updateLog(RDK);
                    
                case 'contents'
                    loadXY(RDK);
                    loadCol(RDK);
                    updateLog(RDK);
                    
                case 'replayM'
                    loadXY(RDK);
                    updateCol(RDK);
                    updateLog(RDK);
                    
                case 'replayC'
                    updateXY(RDK);
                    loadCol(RDK);
                    updateLog(RDK);
                    
                case 'all' % Leave log untouched.
                    loadXY(RDK);
                    loadCol(RDK);
            end     
        end
        
        function draw(RDK)
            if any(RDK.toShow)
                Screen('DrawDots', RDK.win, ...
                                   RDK.xyPix(:, RDK.toShow), ...
                                   RDK.dotSizePix, ...
                                   RDK.colors(:, RDK.col2(1, RDK.toShow) + 1), ...
                                   RDK.apCenterPix, RDK.dotType);
            end
        end
        
        function closeLog(RDK)
            % CLOSELOG  
            % - convert pixel coordinates to degrees.
            
            copyLogInfo(RDK, 'xyPix', 'xyDeg');
            
            pixPerDeg = RDK.Scr.info.pixPerDeg;
            
            RDK.v_.xyDeg = cellfun(@(v) bsxfun(@plus, ...
                v / pixPerDeg, RDK.apCenterDeg(:)), ...
                RDK.v_.xyPix, 'UniformOutput', false);
        end   
        
        function res = maxN(RDK)
            if isempty(RDK.maxSec)
                res = RDK.maxN_.xyPix;
                RDK.maxSec = res / RDK.Scr.info.refreshRate;
                warning('maxSec reconstructed from maxN_.xyPix and Scr.info.refreshRate!');
            else
                res = ceil(RDK.maxSec * RDK.Scr.info.refreshRate);
            end
        end
        
        function v = get.maxFr(RDK)
            v = ceil(RDK.maxSec * RDK.Scr.info.refreshRate);
        end
        
        h = plot(RDK, relS)
        
    %% Analysis functions
        function [eMot, eMotVec, cME, tf] = roughEnMot(RDK, ~, ~)
            % [eMot, eMotVec, cME, tf] = roughEnMot(RDK, ~, ~)
            %
            % Rough motion energy, given by the number of dots moving coherently.
            
            try
                xyPix   = cell2mat3(RDK, 'xyPix');
            catch err_xyPix
                warning(err_msg(err_xyPix));
                disp('Error calculating toShowMat.. returning empty matrix!');
                xyPix   = [];
            end
            
            if isempty(xyPix)
                eMotVec = [];
                eMot    = nan;
                tf      = [];
            else
                xyPix   = xyPix(:,:,2);
                xyPix(~cell2mat3(RDK, 'toShow')) = nan;

                tf      = PsyRDKCol.findSame(xyPix, RDK.nFrSet) .* sign(RDK.cur_coh);
                eMotVec = hVec(sum(tf, 2));
                eMot    = sum(eMotVec);
            end
            
            cME = cumsum(eMotVec);
            
            RDK.ev.rM.mom = eMotVec;
            RDK.ev.rM.cum = cME;
            RDK.ev.rM.sum = eMot;
        end
        
        
        function LLR = calc_LLR(RDK, bino_prop, propRep)
            % LLR = calc_LLR(RDK, bino_prop, propRep)
            %
            % See also LLRCol, LLR
            
            if ~exist('bino_prop', 'var') || isempty(bino_prop)
                bino_prop = 'col2'; 
            end
            
            % If not calculated already
            if ~isfield(RDK.LLR, bino_prop) || isempty(RDK.LLR.(bino_prop))
                LLR     = RDK.LLRColRDK(propRep);
                RDK.LLR.(bino_prop)  = LLR;
                
            else
                LLR = RDK.LLR.(bino_prop);
            end
        end
        
        
        function [CEsum, mCE, cCE, tf, LLR] = roughEnCol(RDK, ~, propRep, bino_prop, res_field)
            % [CEsum, mCE, cCE, tf, LLR] = roughEnCol(RDK, [~, propRep, bino_prop = 'col2', res_field = 'rC'])
            %
            % On average, exact for a given frame. But over multiple frames,
            % sluggishness of screen and the subject's color perception
            % can increase a dot's effective lifetime and change the energy.
            %
            % By changing bino_prop and res_field, can calculate
            % evidence from other binomial properties, too.
            %
            % LLR: LLR vector pre-computed with PsyRDKCol.LLRCol().
            %      Calculated only when RDK.LLR.(bino_prop) is empty.
            %      To recalculate, set RDK.LLR.(bino_prop) to empty.
            %
            % See also: PSYRDKCOL.LLRCOL ROUGHENMOT CELL2MAT3
            
            if ~exist('bino_prop', 'var'), bino_prop = 'col2'; end
            if ~exist('res_field', 'var'), res_field = 'rC'; end
            
            if ~exist('propRep', 'var')
                LLR = calc_LLR(RDK, bino_prop);
            else
                LLR = calc_LLR(RDK, bino_prop, propRep);
            end
            
            % Calculate tf, considering toShow if PsyRDKCol (not its subclasses).
            if strcmp(class(RDK), 'PsyRDKCol') || ~isvector(LLR) %#ok<STISA>
                try
                    toShowMat = cell2mat3(RDK, 'toShow');
                catch err_toShowMat
                    warning(err_msg(err_toShowMat));
                    disp('Error calculating toShowMat.. returning empty matrix!');
                    toShowMat = [];
                end                
                
                if isempty(toShowMat)
                    tf  = [];
                    mCE = [];
                else
                    % Calculate frame-by-frame LLR to account for
                    %       variation in the number of shown dots.
                    tf  = cell2mat3(RDK, bino_prop) & toShowMat;
                    mCE = hVec(subsMulti(LLR, sum(tf, 2)+1, sum(toShowMat, 2)+1));
                end
            else
                tf   = cell2mat3(RDK, bino_prop);
                mCE  = hVec(LLR(sum(tf, 2)+1));
            end            
            
            % Calculate CE
            if isempty(tf)
                cCE = [];
                CEsum = nan;
            else                
                cCE     = cumsum(mCE);
                CEsum   = cCE(end);
            end
            
            % Save CE
            RDK.ev.(res_field).mom = mCE;
            RDK.ev.(res_field).cum = cCE;
            RDK.ev.(res_field).sum = CEsum;
        end
        
        
        function getCPix(RDK, varargin)
            % getCPix(RDK, varargin)
            %
            % OPTIONS
            % 'xyct', RDK.xyct
            % 'rot_deg', [] % -RDK.mot_dir (PsyRDKConst) or 0 (PsyRDKCol)
            % 'use_GPU', false
            %
            % Clear cPix after ENMOT -- it takes huge memory!
            %
            % See also: ENMOT, CLEARCPIX
            
            S = varargin2S(varargin, {
                'xyct', RDK.xyct
                'rot_deg', []
                'use_GPU', false
                });
            if isempty(S.rot_deg)
                S.rot_deg = 0;
            end
            
            try 
                % If mot_dir property exists,
                % rot_deg is relative to the motion's direction
                S.rot_deg = S.rot_deg - RDK.mot_dir;
            catch
            end
            c_xyct = S.xyct;
                
            if S.rot_deg ~= 0
                % Rotate
                c_xyct(:,1:2) = c_xyct(:,1:2) * rotate_mat(S.rot_deg)';
            end
            
            [RDK.cPix, RDK.bwPix] = PsyRDKCol.xyct2full( ...
                c_xyct, RDK.dotSizePix, RDK.apRPix, 'use_GPU', S.use_GPU);
        end    
        
        function [h cMat] = plotCPix(RDK, col, fr)
            if nargin < 2, col = 'bw'; end
            if nargin < 3, fr = 1; end
            
            if isempty(RDK.cPix), RDK.getCPix; end
            
            switch col
                case 'c'
                    cMat = RDK.cPix(:,:,fr,1) ...
                         + RDK.cPix(:,:,fr+RDK.nFrSet,1) * 2 ...
                         + RDK.cPix(:,:,fr,2) * 3 ...
                         + RDK.cPix(:,:,fr+RDK.nFrSet,2) * 4;
                    
                case 'bw'
                    cMat = RDK.bwPix(:,:,fr) ...
                         + RDK.bwPix(:,:,fr + RDK.nFrSet)*2;
            end
            
            h = imagesc(cMat);
            title(sprintf('coh %1.3f, prop %1.3f', RDK.coh, RDK.prop));
        end
        
        function clearCPix(RDK)
            % clearCPix(RDK)
            %
            % Clear cPix after ENMOT -- it takes huge memory!
            %
            % See also GETCPIX, ENMOT
            
            RDK.cPix = [];
            RDK.bwPix = [];
        end
        
        function [MEsum, mME, cME, MFilt] = EnMot(RDK, MFilt, varargin)
            % Calculates motion energy. 
            %
            % [MEsum, mME, cME, MFilt] = EnMot(RDK, [MFilt, addSec = 0.2])
            %
            % * Clears cPix after ENMOT.
            %
            % See also CLEARCPIX, 
            %   PsyMotionFilter.apply, PsyMotionFilter.PsyMotionFilter
            
            S = varargin2S(varargin, {
                'to_getCPix', isempty(RDK.cPix) || isempty(RDK.bwPix)
                'cPix_opt', {}
                'MFilt_opt', {}
                });
            
            if ~exist('MFilt', 'var') || isempty(MFilt)
                if isempty(RDK.MFilt)
                    MFilt = PsyMotionFilter(RDK); 
                    RDK.MFilt = MFilt;
                else
                    MFilt = RDK.MFilt;
                end
            end
            
            if S.to_getCPix
                RDK.getCPix(S.cPix_opt{:});
            end
            
            if ~isempty(RDK.cPix)
                mME = MFilt.apply(RDK, S.MFilt_opt{:});
                cME = cumsum(mME);
                MEsum = cME(end);
            else
                mME = [];
                cME = [];
                MEsum = 0;
            end
            
            RDK.ev.M.mom = mME;
            RDK.ev.M.cum = cME;
            RDK.ev.M.sum = MEsum;
            
            RDK.clearCPix;
        end
        
        
        function S = EnMot2S(RDK, varargin)
            % S = EnMot2S(RDK, varargin)
            %
            % S: a struct with fields MEsum, mME, and cME.
            %
            % See also PsyRDKCol.EnMot.
            
            [c{1:3}] = EnMot(RDK, varargin{:});
            S = cell2struct(c, {'MEsum', 'mME', 'cME'}, 2);
        end
        
        
        function [CEsum, mCE, cCE] = EnCol(RDK, varargin)
            % [CEsum, mCE, cCE] =  EnCol(RDK, [LLR, propRep, ...])
            %
            % Convolved version of roughEnCol.
            %
            % See also: PsyRDKCol.roughEnCol.
            
            S = varargin2S(varargin(3:end), { ...
                'gamma_mean', 0.075, ...
                'gamma_std',  0.05, ...
                });
            
            relS = RDK.relSec('xyPix');
            relS = relS - relS(1);
            
            % TODO: Can also smear dot counts *before* computing LLR
            [~, mCE] = roughEnCol(RDK, varargin{:});
            mCE = conv_t(mCE, ...
                gampdf_ms(relS, S.gamma_mean, S.gamma_std));
            
            cCE = cumsum(mCE);
            CEsum = sum(mCE);
        end
        
        function res = cell2mat3(RDK, name)
            % CELL2MAT3  Convert into T x nDot x (x,y) matrix,
            %            from 1 x T cells of (x,y) x nDot.
            %
            % res = cell2mat3(RDK, name)
            
            res = permute(cell2mat(reshape2vec(RDK.vTrim(name), 3)), [3 2 1]);
        end
        
        function h = plotTraj(RDK, varargin)
            S = varargin2S(varargin, {...
                'draw_traj', true, ...
                });
            
            hold on;
            
            th = 0:0.1:(2.1*pi);
            [x y] = pol2cart(th, RDK.apRPix);
            plot(x, y,'b-', 'LineWidth', 0.5); box off;
            hold on;
            [x y] = pol2cart(th, RDK.apInnerRPix);
            plot(x, y,'b-', 'LineWidth', 0.5); box off;
            hold on;
            crossLine('h', [0, -RDK.apRPix, RDK.apRPix], 'k-');
            crossLine('v', [0, -RDK.apRPix, RDK.apRPix], 'k-');

            axis equal; axis square;
            xlim([-RDK.apRPix, RDK.apRPix]*1.2);
            ylim([-RDK.apRPix, RDK.apRPix]*1.2);

            xyPix = RDK.cell2mat3('xyPix');
            xPix = squeeze(xyPix(:,:,1));
            yPix = squeeze(xyPix(:,:,2));
            
            if S.draw_traj
                for jj = 1:RDK.nFrSet
                    c = zeros(1,3);
                    c(mod(jj,3)+1) = 1; % jj = rand(1,3); %  .* (0.5 + 0.5.*round(rand(1,3)));
                    disp(c);
                    for ii = 1:RDK.nDot

                        gradLine(xPix(jj:RDK.nFrSet:end,ii),yPix(jj:RDK.nFrSet:end,ii),...
                            c, 'LineWidth', 2);
                    end
                end
            end
            
            hold on;
            plot(xPix, yPix, 'b.'); hold on;
            plot(RDK.xyPix(1,RDK.toShow), RDK.xyPix(2,RDK.toShow), 'r.');
            hold off;
            
            h = gca;
        end
        
        function LLRNcol2 = LLRColRDK(RDK, propRep)
            % LLRCol  Non-static version of LLRCol. Detects nDot and considerAp.
            %
            % LLRNcol2 = LLRColRDK(RDK, propRep)
            %
            % propRep : A vector of proportion of one color.
            %           Assuming every dot is either one of two colors.
            %
            % LLRNcol2(NColor2+1)
            %       = Exact log likelihood of the answer being color 2 over 1,
            %         given a frame with NColor2 dots having color 2.
            %
            % Give nDot as a vector to get LLRNcol2 of size (NColor2+1, nDot+1).
            %
            % See also PsyRDKCol.LLRCol
            
            cl = class(RDK);
            switch cl
                case 'PsyRDKCol'
                    considerAp = true;
                    
                case 'PsyRDKConst'
                    considerAp = false;
                    
                otherwise
                    error('PsyRDKCol:considerAp_undefined', ...
                        'considerAp undefined for %s!', cl);
            end
            
            LLRNcol2 = PsyRDKCol.LLRCol(0:RDK.nDot, propRep, considerAp);
        end
        
        function set.coh(RDK, v)
            if isa(v, 'function_handle')
                RDK.coh = v(RDK.fr_incl);
            else
                RDK.coh = v;
            end
        end
        
        function v = cur_coh(RDK)
            v = RDK.coh(min(end, max(RDK.n, 1)));
        end
        
        function v = fr_incl(RDK)
            dt = 1 / RDK.Scr.info.refreshRate;
            nt = ceil(RDK.maxSec / dt);
            v = 0:dt:(dt*nt);
        end
        
        function M = get.xyct(RDK)
            if isempty(RDK.xyct)
                xy = RDK.cell2mat3('xyPix');
                c  = RDK.cell2mat3('col2');
                t  = repmat((1:size(xy,1))', [1 size(xy,2)]);
                
                M = [reshape(xy, [], 2), c(:), t(:)];
                
                % What to include
                sVec  = RDK.cell2mat3('toShow');
                M     = M(sVec(:), :);
            
                RDK.xyct = M;
                
            else
                M = RDK.xyct;
            end
        end
    end
    
    methods (Static)
        function [cPix, bwPix] = xyct2full(xyct, dotSizePix, apRPix, varargin)
            % [cPix, bwPix] = xyct2full(xyct, dotSizePix, apRPix, varargin)
            %
            % dotSizePix, apRPix: scalar in pix.
            %
            % OPTIONS:
            % 'useGPU', false
            
            S = varargin2S(varargin, {
                'use_GPU', false
                'xyLen' []
                'tLen', []
                });
            
            % Get x, y, color, time
            if isempty(xyct), cPix = []; bwPix = []; return; end
            
            xyct(:,1:2) = round(bsxfun(@plus, xyct(:,1:2), apRPix(1))) + 1;
            
            % Consider dot's size
            pixDot  = (0:max(round(dotSizePix)-1, 0)) - floor(dotSizePix/2);
            
            % Length
            if isempty(S.xyLen)
                xyLen = round(apRPix(1))*2+1 ...
                      + abs(pixDot(1))+abs(pixDot(end)) + 2; % Give enough space
            else
                xyLen = S.xyLen;
            end
            if isempty(S.tLen)
                tLen = max(xyct(:,4));
            else
                tLen = S.tLen;
            end

            ix      = sub2ind([xyLen, xyLen, tLen, 2], xyct(:,2), xyct(:,1), xyct(:,4), xyct(:,3)+1);
            
            % Fill
            if S.use_GPU
                ccPixOrig = gpuArray.zeros(xyLen, xyLen, tLen, 2);
            else
                ccPixOrig = zeros(xyLen, xyLen, tLen, 2);
            end
            ccPixOrig(ix) = 1;
            cPix   = ccPixOrig;

            % Fill dots
            for xPixDot = pixDot
                for yPixDot = pixDot
                    
                    cPix = cPix | circshift(ccPixOrig, ...
                        [yPixDot, xPixDot, 0, 0]);
                end
            end
            
            % Consider type
%             if S.use_GPU
%                 try
%                     cPix  = gpuArray(cPix);
%                 catch 
%                 end
%             end
            
            bwPix = min(squeeze(sum(cPix, 4)), 1);
        end

        
        function [xy, c] = xyct2cell(xyct, RDKCol)
            % XYCT2CELL  Convert (nDot x nFr) x (x,y,c,fr) matrix into
            % 1 x nFr cells of (x,y) x nDot and (col2) x nDot.
            %
            % [xy, c] = xyct2cell(xyct, [RDKCol])
            %
            % If RDKCol is provided, replaces v_.xyPix and v_.col2.
            
            t = xyct(:,4);
            T = max(t);
            
            xy = cell(1, T);
            c  = cell(1, T);
            
            for ii = 1:T
                incl = t == ii;
                
                xy{ii} = xyct(incl, 1:2)';
                c{ii}  = xyct(incl, 3)';
            end
            
            if nargin >= 2
                RDKCol.v_.xyPix = xy;
                RDKCol.v_.col2  = c;
                RDKCol.n_.xyPix = length(xy);
                RDKCol.n_.col2  = length(c);
            end
        end
        
%         function C = mat3_2_cell(M)
%             error('Yet to implement!');
%         end
        
        [MEsum mME cME succEv MFilt] = EnMots(src, objName)
        % [MEsum mME cME succEv MFilt] = EnMots(src, objName)
        %
        % src: Either (1) a cell array of file names or 
        %             (2) a struct array with a field 'RDKCol'.
        % objName: Defaults to 'RDKCol'.
        
        [CEsum mCE cCE succEv LLR] = EnCols(src, objName)
        % [CEsum mCE cCE succEv LLR] = EnCols(src, objName)
        %
        % src: Either (1) a cell array of file names or 
        %             (2) a struct array with a field 'RDKCol'.
        % objName: Defaults to 'RDKCol'.
        
        
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
            % LLRNcol2 = LLRCol(nDot, propRep, considerAp = true)
            %
            % LLRNcol2(NColor2+1)
            %       = Exact log likelihood of the answer being color 2 over 1,
            %         given a frame with NColor2 dots having color 2.
            %
            % propRep
            % - When all expected proportions are equiprobable, 
            %   use 1 x n_prop_rep. Each element is an expected proportion
            %   of a condition.
            %
            % - When they are not equiprobable, 
            %   use (prop, p_prop) x n_prop_rep.
            %   The second row is the probability of each proportion.
            %
            % considerAp
            %     : If true (default) calculates mean effective number of dots,
            %       based on the proportion of dots in a circle filling a 
            %       sqrare.
            %
            % Give nDot as a vector to get LLRNcol2 of size (NColor2+1, nDot+1).
            %
            % See also PsyRDKCol.LLRColRDK
            
            if ~exist('considerAp', 'var'), considerAp = true; end
            
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
                % Equiprobable
                if isvector(propRep)
                    nPropRep  = length(propRep);
                    p_prop    = ones(size(propRep));
                    
                % Not equiprobable
                else
                    nPropRep  = size(propRep, 2);
                    p_prop    = propRep(2,:);
                    propRep   = propRep(1,:);
                end
                
                pNCol2 = zeros(nPropRep, nDotEffec+1);
                
                % pNCol2(prop,#col2) = p(prop, #col2) = p(#col2 | prop) * p(prop)
                for iProp = 1:nPropRep
                    cProp = propRep(iProp);
                    
                    pNCol2(iProp,:) = binopdf(0:nDotEffec, nDotEffec, cProp) ...
                        * p_prop(iProp);
                end
                
                % p(prop | #col2) = p(prop, #col2) / p(#col2)
                pPropGivenNCol2 = bsxfun(@rdivide, pNCol2, sum(pNCol2,1));
                
                % p(prop > 0.5 | #col2) = sum(p(prop | #col2) for prop > 0.5)
                p2GivenNCol2    = sum(pPropGivenNCol2((propRep>0.5), :), 1);
                
                % p(prop < 0.5 | #col2) = sum(p(prop | #col2) for prop < 0.5)
                p1GivenNCol2    = sum(pPropGivenNCol2((propRep<0.5), :), 1);
                
                % Note: p(prop = 0.5 | #col2) doesn't contribute to the logit,
                %       since logit(p=0.5) = 0.
                %
                % logit = log(p(prop > 0.5 | #col2)) - log(p(prop < 0.5 | #col2))
                LLRNcol2        = log(p2GivenNCol2) - log(p1GivenNCol2);
            end
        end
    end
end