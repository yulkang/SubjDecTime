classdef PsyRDKConst < PsyRDKCol
    % PSYRDKCONST  Keeps dot number constant across frames.
    
    properties
        % Separate randstreams for motion and color.
        rM = PsyRStream; % For dot position
        rC = PsyRStream; % For dot color
        
        % Also need to reverse mot and col on run_exp (when considering answer)
        % and make_MDDTrial level (to match seeds).
        % (in PsyRDKCol)
%         reverse_mot = false; % determine dX dY from 180 + mot_dir        
%         reverse_col = false; 
        
        gray_fr = [];
        balanced_color_fr = [];
        mirror_fr = [];
        
        balance_initial_color = false;        
    end
    
    properties (Dependent)
        gray_mode
        balanced_color_mode
        mirror_mode
        
        mot_dir % in deg
        speed_deg_per_sec
        speed_pix_per_fr
    end
    
    methods
        %% Experiment functions
        function RDK = PsyRDKConst(varargin)
            RDK = RDK@PsyRDKCol(varargin{:});
        end
        
        function n = getNDot(RDK)
            n = round(RDK.dotDensity * (RDK.apRDeg^2 - RDK.apInnerRDeg^2) * pi ...
                / RDK.Scr.info.refreshRate);
        end
        
        function [R, n] = set_apRDeg_for_even_nDot(RDK)
            n = ceil(RDK.getNDot/2)*2; % Make it even, no less than current one.
            
            R = sqrt((n * RDK.Scr.info.refreshRate) / (pi * RDK.dotDensity) ...
                    + RDK.apInnerRDeg^2);
                
            RDK.nDot = n;
        end
        
        function initRStream(RDK, rSeed)
            if iscell(rSeed)
                RDK.initRStream@PsyRStream(rSeed{1});

                % Always generate two numbers.
                seeds = floor(rand(RDK.rStream, 1,2) * 2^31);
                
                % Use the general randStream to generate seeds for
                % the other randStreams.
                %
                % Since we always generate two numbers, given the same
                % general seed, the other stream(s) with 'shuffle' gives
                % same results.
                for iSeed = 1:2
                    if strcmp(rSeed{1+iSeed}, 'shuffle')
                        rSeed{1+iSeed} = seeds(iSeed); 
                    end
                end
                
                RDK.rM.initRStream(rSeed{2});
                RDK.rC.initRStream(rSeed{3});
            
            else
                error('Provide {seedGeneral, seedMotion, seedColor}!');
            end
        end
        
        function preRun(RDK)
            RDK.replayLevel = 'none';
            
            for ii = 1:RDK.maxN
                RDK.update('befDraw');
            end
            
            RDK.replayLevel = 'contents';
        end
        
        function initTrial(RDK)
%             RDK.balanced_color_fr = [];
%             RDK.mirror_fr = [];
            
            % Balance initial color if asked
            if RDK.balance_initial_color
                RDK.balanced_color_fr = union(RDK.balanced_color_fr, 1:RDK.nFrSet);                
            end
            
            % In balanced_color_mode or mirror_mode,
            % enforce even number of dots by expanding outer aperture.
            if RDK.balanced_color_mode || RDK.mirror_mode
                if rem(RDK.getNDot, 2) ~= 0
                    RDK.apRDeg = RDK.set_apRDeg_for_even_nDot;
                end
            end
            
            if RDK.reverse_mot && RDK.coh > 0
                error('When reverse_mot == true, coh must be nonpositive!');
            end
            if RDK.reverse_col && RDK.prop > 0.5
                error('When reverse_col == true, prop must be <=0.5 !');
            end
            
            RDK.initTrial@PsyRDKCol;
        end
        
        function initLogEntries(RDK, varargin)
            % No need to record toShow, because every dot will always be shown.
            
            if nargin > 1
                RDK.initLogEntries@PsyLogs(varargin{:});
            else
                switch RDK.replayLevel
                case 'none'
                    RDK.initLogEntries@PsyLogs('propCell', {'xyPix', 'col2', 'toJump'}, ...
                                    'fr', {}, RDK.maxN);

                case 'contents'
                    RDK.initTimeEntries({'xyPix', 'col2'}, RDK.maxN);
                end
            end
        end
        
        function toJump = get_toJump(RDK)
            % Jumps
            toJump = rand(RDK.rM.rStream, 1, RDK.nDot) > abs(RDK.cur_coh);
        end
        
        function [xy, rt] = sampleXY(RDK, nJump, r)
            % [xy, rt] = sampleXY(RDK, nJump, r)
            
            if nargin < 3, r = rand(RDK.rM.rStream, 2, nJump); end
            
            [xy, rt] = circRnd(nJump, RDK.apRPix, r, RDK.apInnerRPix);
        end
        
        function wrapXY(RDK, r)
            % wrapXY(RDK, r)
            %
            % Dots moved outside circular aperture wraps back and
            % randomly repositioned in y dimension
            % to maintain constant density without invoking 
            % motion energy to the opposite direction.
            
            % Copy to avoid repetitive reference to handle object property
            c_xyPix       = RDK.xyPix;
            c_apRPix      = RDK.apRPix;
            c_apInnerRPix = RDK.apInnerRPix;
            c_apDiaPix    = RDK.apDiaPix;
            c_coh         = RDK.cur_coh;
            c_mot_dir     = RDK.mot_dir / 180 * pi;
            
            % What crossed which edge
            dist2   = sum(c_xyPix.^2, 1);

            toWrap1 = (dist2 > c_apRPix^2);
            toWrap2 = (dist2 < c_apInnerRPix^2);
            toWrap  = toWrap1 | toWrap2;

            % Rotate toWrap's before calculating offset
            [c_xyPix(1, toWrap), c_xyPix(2, toWrap)] = ...
                rotate_2d(-c_mot_dir, ...
                    c_xyPix(1, toWrap), c_xyPix(2, toWrap));
            
            % Previous offset
            dX = zeros(1,size(r,2));
            dX(1,toWrap1) = abs(c_xyPix(1,toWrap1)) ...
                          - sqrt(c_apRPix^2 - c_xyPix(2,toWrap1).^2);

            dX(1,toWrap2) = sqrt(c_apInnerRPix^2 - c_xyPix(2,toWrap2).^2) ...
                        - abs(c_xyPix(1,toWrap2));

            % Sample y uniformly
            c_xyPix(2,toWrap) = r(2,toWrap) * (c_apRPix + c_apInnerRPix) * 2;

            innerCircle = (c_xyPix(2,:) >  c_apDiaPix) & toWrap;
            outerCircle = (c_xyPix(2,:) <= c_apDiaPix) & toWrap;

            c_xyPix(2,innerCircle) = c_xyPix(2, innerCircle) ...
                                   - c_apDiaPix - c_apInnerRPix;
            c_xyPix(2,outerCircle) = c_xyPix(2, outerCircle) ...
                                   - c_apRPix;

            % Calculate x from y for outer circle
            c_xyPix(1,innerCircle) = sign(c_coh) ...
                           * sqrt(c_apInnerRPix^2 - c_xyPix(2, innerCircle).^2);

            c_xyPix(1,outerCircle) = -sign(c_coh) ...
                           * sqrt(c_apRPix^2 - c_xyPix(2, outerCircle).^2);

            % Add previous offset
            c_xyPix(1,:) = c_xyPix(1,:) + dX * sign(c_coh);
            
            % Rotate back
            [c_xyPix(1,toWrap), c_xyPix(2,toWrap)] = ...
                rotate_2d(c_mot_dir, ...
                    c_xyPix(1, toWrap), c_xyPix(2, toWrap));
            
            % Put back to RDK.xyPix
            RDK.xyPix(:,toWrap) = c_xyPix(:, toWrap);
            
%             % DEBUG
%             if any(sum(RDK.xyPix.^2, 1) > c_apRPix.^2) || ...
%                     any(sum(RDK.xyPix.^2, 1) < c_apInnerRPix.^2)
%                 error('Boundary violation!');
%             end
        end
        
        function r = randXY(RDK)
            r = rand(RDK.rM.rStream, 2, RDK.nDot);
        end
        
        function updateCol(RDK)
            if isnan(RDK.prop) % Gray mode
                RDK.col2 = 2 + zeros(1, RDK.nDot);
            else
                if any(RDK.n == RDK.balanced_color_fr)
                    c_nDot = RDK.nDot;

                    RDK.col2 = false(1, c_nDot);
                    RDK.col2(1,randperm(RDK.rC.rStream, c_nDot, floor(c_nDot/2))) = true;
                else
                    if RDK.reverse_col
                        % First do the opposite, then flip, so that
                        % matcheed seedC gives exactly opposite images.
                        c_prop = 1 - RDK.prop;
                    else
                        c_prop = RDK.prop;
                    end
                
                    % Colors are updated every frame.
                    RDK.col2 = (rand(RDK.rC.rStream, 1, RDK.nDot) < c_prop);
                end

                % Reverse_col always reverses color
                if RDK.reverse_col
                    RDK.col2 = ~RDK.col2;
                end
            end
        end
        
        function maskXY(RDK)
            % PsyRDKConst does not mask, since all dots are in the aperture.
            %
            % Apply mirror/reverse direction mode if necessary
            
            % Mirror mode
            if any(RDK.n == RDK.mirror_fr)
                % If balanced color, choose colors to be half and half
                if any(RDK.n == RDK.balanced_color_fr)
                    n_dot  = RDK.nDot;
                    n_incl = n_dot / 4;
                    
                    c_col2 = RDK.col2;
                    
                    dot1 = find(~c_col2, n_incl, 'first');
                    dot2 = find(c_col2,  n_incl, 'first');
                    first_half = false(1, n_dot);
                    first_half([dot1, dot2]) = true;
                    
                    c_xy    = RDK.xyPix;
                    mot_dir = RDK.mot_dir;
                    
                    c_xy(:, c_col2 & ~first_half) = mirror_xy(c_xy(:, c_col2 & first_half), mot_dir+90);
                    c_xy(:,~c_col2 & ~first_half) = mirror_xy(c_xy(:,~c_col2 & first_half), mot_dir+90);
                    
                    % Assign back to xyPix
                    RDK.xyPix = c_xy;
                else
                    error('Yet to implement!');
                end
            end
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
                toJump = true(1, RDK.nDot);

            else 
                RDK.xyPix(:,~toJump) = RDK.v_.xyPix{RDK.n - RDK.nFrSet}(: ,~toJump);
                RDK.xyPix(:,~toJump) = bsxfun(@plus, ...
                                        RDK.xyPix(:,~toJump), ...
                                        RDK.dXYPixPerFr(:) * sign(RDK.cur_coh));

                RDK.wrapXY(r);
            end
            
            % Coherent dots are reversed already. Since get_toJump uses abs coh, need to reverse them only.
            if RDK.reverse_mot 
                RDK.xyPix(:, toJump) = mirror_xy(RDK.xyPix(:, toJump), RDK.mot_dir + 90);
            end
            
            RDK.maskXY;
        end        
        
        function loadXY(RDK)
            RDK.xyPix  = RDK.v_.xyPix{RDK.n};
        end
        
        function updateLog(RDK)
            % Don't log toShow. It's always all true.
            addLog(RDK, {'xyPix', 'col2', 'toJump'}, RDK.Scr.cFr);
        end
        
        function update(RDK, from) 
            % Sample from square and show only those in circular aperture.

            if ~any(strcmp(from, 'befDraw')) || ~RDK.visible, return; end
            
            RDK.n       = RDK.n + 1;

            switch RDK.replayLevel
                case 'none'
                    updateCol(RDK);
                    updateXY(RDK);
                    updateLog(RDK);
                    
                case 'contents'
                    loadCol(RDK);
                    loadXY(RDK);
                    updateLog(RDK);
                    
                case 'replayM'
                    updateCol(RDK);
                    loadXY(RDK);
                    updateLog(RDK);
                    
                case 'replayC'
                    loadCol(RDK);
                    updateXY(RDK);
                    updateLog(RDK);
                    
                case 'all' % Leave log untouched.
                    loadCol(RDK);
                    loadXY(RDK);
            end     
        end
        
        function import(RDK, RDKCol, extentM, extentC)
            % import(RDK, RDKCol, extentM, extentC)
            %
            % extentM,C : 'contents' (default), 'seed', 'none'
            
            if ~exist('extentM', 'var') || isempty(extentM), 
                extentM = 'contents'; end
            if ~exist('extentC', 'var') || isempty(extentC), 
                extentM = 'contents'; end
            
            if ~strcmp(extentM, 'none')
                RDK.rM   = copyRStream(RDKCol.rM);
                RDK.ev.M = RDKCol.ev.M;
                        
                if strcmp(extentM, 'contents')
                    RDK = copyLogInfos(RDKCol, RDK, {'xyPix'});
                end
            end
            
            if ~strcmp(extentC, 'none')
                RDK.rC   = copyRStream(RDKCol.rC);
                RDK.ev.C = RDKCol.ev.C;
                
                if strcmp(extentC, 'contents')
                    RDK = copyLogInfos(RDKCol, RDK, {'col2'});
                end
            end
        end
        
        function closeLog(RDK)
            RDK.closeLog@PsyRDKCol;
            
            if strcmp(RDK.replayLevel, 'contents')
                % Truncate those that are not replayed.
                for cField = {'xyPix', 'col2'}
                    RDK.n_.(cField{1}) = RDK.n;
                    RDK.t_.(cField{1}) = RDK.tTrim(cField{1});
                    RDK.v_.(cField{1}) = RDK.vTrim(cField{1});
                end
            end
        end
        
        %% Analysis functions
        function res = cell2mat3(RDK, name) % Will be faster if I revise getCPix.
            if strcmp(name, 'toShow')
                res = true(RDK.n_.xyPix, RDK.nDot);
            else
                res = cell2mat3@PsyRDKCol(RDK, name);
            end
        end
        
        %% Balancing
        function set_balanced_color_mode(RDK, st, st_unit, en, en_unit)
            error('Yet to implement!');
        end
        
        function set_gray_mode(RDK, st, st_unit, en, en_unit)
            error('Yet to implement!');
        end
        
        function res = get.gray_mode(RDK)
            res = ~isempty(RDK.gray_fr);
        end
        
        function res = get.balanced_color_mode(RDK)
            res = ~isempty(RDK.balanced_color_fr);
        end
        
        function res = get.mirror_mode(RDK)
            res = ~isempty(RDK.mirror_fr);
        end
        
        %% Dependent properties
        function set.mot_dir(RDK, deg)
            % set.mot_dir(RDK, deg)
            
            [dx, dy] = pol2cart(deg / 180 * pi, RDK.speed_deg_per_sec);
            
            RDK.dXYDegPerSec = [dx, dy];
            try
                RDK.dXYPixPerFr  = [dx, dy] * RDK.Scr.info.pixPerDeg;
            catch
                warning('RDK.Scr is not set - couldnt set dXYPixPerFr!');
            end
        end
        
        function deg = get.mot_dir(RDK)
            % deg = get.mot_dir(RDK)
            
            deg = atan2(RDK.dXYDegPerSec(2), RDK.dXYDegPerSec(1)) / pi * 180;
        end
        
        function v = get.speed_deg_per_sec(RDK)
            v = sqrt(sum(RDK.dXYDegPerSec .^ 2));
        end
        
        function v = get.speed_pix_per_fr(RDK)
            v = sqrt(sum(RDK.dXYPixPerFr .^ 2));
        end        
    end
    
    methods (Static)
        RDK = test(Scr_opts, RDK_opts)
    end
end