classdef PsyPTB < PsyVis
    properties
        commPsy     = '';
        commPTB     = '';
        
        % argsPsy
        xyDeg       = nan(2,1);
        sizeDeg     = nan(2,1);
        centerDeg   = nan(2,1);
        penWidthDeg = 0.05;
        
        % argsPTB
        xyPix       = nan(2,1);
        sizePix     = nan(2,1);
        centerPix   = nan(2,1);
        penWidthPix = nan;
        
        % common
        color       = nan(3,1);
        smooth      = 0;  % for DrawLines.
        misc        = {};
        miscName    = {}; % What each entry in misc means
        
        % Copied from Scr.info at the time of initLog().
        win            = nan;
        pixPerDeg      = nan;
        winCenterPix   = nan(2,1);
        winCenterPix4  = nan(4,1);
        
        % Options
        
        % Automatic updating is disabled by default because 
        % some existing classes (e.g., PsyCursor) get/set pix directly
        % for speed. But in the future that behavior may be unnecessary.
        auto_deg2pix_bef_draw = false; 
    end
    
    
    methods
        function me = PsyPTB(cScr, varargin)
            % me = PsyPTB(Scr, ...)
            %
            % See also PsyPTB.initPsyProps.
            
            me = me@PsyVis;
            
            me.rootName = 'Scr';
            me.parentName = 'Scr';
            me.tag = 'PTB'; % default tag
            
            if nargin > 0, me.Scr = cScr; end
            if nargin > 1
                me.init(varargin{:});
            end
        end
        
        
        function init(me, varargin)
            % init(me, ...)
            %
            % See also PsyPTB.initPsyProps.
            
            copyScrInfo(me);
            
            if nargin > 1
                initPsyProps(me, varargin{:});
                argsPsy2PTB(me);
            end
        end
        
        
        function initLogTrial(me, varargin)
%             if ~isempty(varargin)
%                 initLogTrial@PsyVis(me);
%             else
                copyScrInfo(me);
                initLogTrial@PsyVis(me);
%             end
        end
        
        
        function copyScrInfo(me)
            me.win            = me.Scr.info.win;
            me.pixPerDeg      = me.Scr.info.pixPerDeg;
            me.winCenterPix   = reshape(me.Scr.info.centerPix, [], 1);
            me.winCenterPix4  = [me.winCenterPix; me.winCenterPix];
        end
        
        
        function initPsyProps(me, commPsy, varargin)
            % me.initPsyProps('DrawDots', sizeDeg, color, centerDeg);
            % me.initPsyProps('DrawLines', xyDeg, penWidthDeg, color, centerDeg, smooth);
            % me.initPsyProps('Other_commands', color, xyDeg, sizeDeg);
            %
            % Other_commands include Fill/FrameCircle/Oval/Rect.
            % Frame/FillPoly are not supported yet.
            %
            % xyDeg  : (2 x N) matrix.
            %          Center of the display is [0 0].
            %           
            % sizeDeg: (2 x N) matrix.
            %          The format should match xyDeg's.
            %          Unlike PsychToolbox, the size is radius, not diameter.
            
            me.commPsy   = commPsy;
            me.commPsy2PTB;
            
            switch commPsy
                case 'DrawDots'
                    me.xyDeg = varargin{1};
                    
                    try     me.sizeDeg = varargin{2} * 2;
                    catch,  me.sizeDeg = 0.1; end
                    
                    try     me.color = varargin{3};
                    catch,  me.color = [255 255 255]'; end
                    
                    try     me.centerDeg = varargin{4}(:); % enforce column vector.
                    catch,  me.center = [0; 0]; end
                    
                    me.misc = varargin(5:end);
                    varargin2fields(me, varargin(5:end));
                    
                case 'DrawLines'
                    try     me.xyDeg = varargin{1};
                    catch,  me.xyDeg = [0 0; 0 0]; end
                    
                    try     me.penWidthDeg = varargin{2};
                    catch,  me.penWidthDeg = 0.1; end
                    
                    try     me.color = varargin{3};
                    catch,  me.color = [255 255 255; 255 255 255]'; end
                    
                    try     me.centerDeg = varargin{4};
                    catch,  me.centerDeg = [0 0]; end
                    
                    try     me.smooth = varargin{5};
                    catch,  me.smooth = 0; end
                    
                otherwise
                    try     me.color = varargin{1};
                    catch,  me.color = [255 255 255]'; end
                    
                    try     me.xyDeg = varargin{2};
                    catch,  me.xyDeg = [0; 0]; end
                    
                    try     me.sizeDeg = varargin{3};
                    catch,  me.sizeDeg = [1; 1]; end
                    
                    me.misc = varargin(4:end);
                    varargin2fields(me, varargin(4:end));
            end
        end
        
        
        function siz = nElem(me)
            siz = max(size(me.xyDeg,2), size(me.sizeDeg,2));
        end
        
        
        function commPsy2PTB(me)
            switch me.commPsy
                case 'FillCircle'
                    me.commPTB = 'FillOval';
                    
                case 'FillSquare'
                    me.commPTB = 'FillRect';
                    
                case 'FrameCircle'
                    me.commPTB = 'FrameOval';
                    
                case 'FrameSquare'
                    me.commPTB = 'FrameRect';
                    
                otherwise
                    me.commPTB = me.commPsy;
            end
        end
        
        
        function argsPsy2PTB(me)
            %% Coordinate transformation.
            switch me.commPsy
                case 'DrawDots'
                    me.xyPix     = me.xyDeg * me.Scr.info.pixPerDeg;
                    me.sizePix   = me.sizeDeg * me.pixPerDeg;
                    me.centerPix = me.centerDeg * me.pixPerDeg + me.winCenterPix;
                    
%                 case 'DrawLine'
                case 'DrawLines'
                    me.xyPix     = me.xyDeg * me.pixPerDeg;
                    me.sizePix   = me.sizeDeg * me.pixPerDeg;
                    me.centerPix = me.centerDeg * me.pixPerDeg + me.winCenterPix;
                    me.penWidthPix = me.penWidthDeg * me.Scr.info.pixPerDeg;
                    
%                 case {'FramePoly', 'FillPoly'}
                    
                otherwise
                    me.xyPix     = me.Scr.deg2pix(me.xyDeg);
                    me.sizePix   = me.sizeDeg * me.Scr.info.pixPerDeg;
                    me.penWidthPix = me.penWidthDeg * me.Scr.info.pixPerDeg;
            end
        end
        
        
        function rect = xyDeg2RectPix(me, xyDeg, sizeDeg)
            % xyDeg2RectPix(me, xyDeg)
            
            if size(xyDeg, 1) == 1
                rect = [xyDeg-sizeDeg, xyDeg+sizeDeg] ...
                       * me.pixPerDeg ...
                       + me.winCenterPix4';
            else
                rect = bsxfun(@plus, ...
                                [bsxfun(@minus, xyDeg, sizeDeg); ...
                                 bsxfun(@plus,  xyDeg, sizeDeg)] ...
                               * me.pixPerDeg ...
                               , me.winCenterPix4);
            end
        end
        
        
        function closeLog(me, conversionDir) % TODO
            % closeLog(me, conversionDir)
            
            switch conversionDir
                case 'pix2deg'
                case 'deg2pix'
            end
            
            % Set toLog = false
            me.closeLog@PsyLogs;
        end
        
        
        function update(me, from) 
            
%             if me.visible && strcmp(from, 'befDraw') ...
%                && ~strcmp(me.commPTB, 'DrawDots')
%                 
%                 me.rect = PsyPTB.xyPix2RectPix(me.xyPix, me.sizePix); % Done on drawing
%             end
        end
        
        
        function res = draw(me, win)
            % Supported: 'DrawDots', 
            %            'FillOval', 'FillRect', 'FrameOval', 'FrameRect', ...
            %            'DrawArc', 'FrameArc'.
            %
            % Unsupported: 'DrawLine', 'DrawLines', 'FramePoly', 'FillPoly'.
            
            if me.auto_deg2pix_bef_draw
                me.argsPsy2PTB;
            end
            
            if nargin < 2
                win = me.win;
            end
            
            switch me.commPTB
                case 'DrawDots'
                    Screen('DrawDots', win, me.sizePix, me.color, me.centerPix);
            
                case {'FillOval', 'FillRect'}
                    Screen(me.commPTB, win, me.color, ...
                           PsyPTB.xyPix2RectPix(me.xyPix, me.sizePix));
                       
                case {'FrameOval', 'FrameRect'}
                    Screen(me.commPTB, win, me.color, ...
                           PsyPTB.xyPix2RectPix(me.xyPix, me.sizePix), ...
                           me.penWidthPix);
            
                case 'DrawLines' 
                    Screen('DrawLines', win, round(me.xyPix), round(me.penWidthPix), me.color(:)', ...
                                        round(me.centerPix(:)')); % , me.smooth);
                       
                case 'FillArc'
                    Screen('FillArc', win, me.color, ...
                           PsyPTB.xyPix2RectPix(me.xyPix, me.sizePix), ...
                           me.startAngle, me.arcAngle);
                    
                case 'FrameArc'
                    Screen('FrameArc', win, me.color, ...
                           PsyPTB.xyPix2RectPix(me.xyPix, me.sizePix), ...
                           me.startAngle, me.arcAngle, me.penWidthPix);
            end
            
            res = true;
        end
        
        
        function cRect = rect(me)
            cRect = PsyPTB.xyPix2RectPix(me.xyPix, me.sizePix);
        end
        
        
        function xyPix = xyDeg2Pix(me, xyDeg)
            % xyPix = xyDeg2Pix(me, xyDeg)
            
            if size(xyDeg, 1) == 1
                xyPix = xyDeg * me.pixPerDeg + me.winCenterPix(:)';
            else
                xyPix = bsxfun(@plus, xyDeg * me.pixPerDeg, me.winCenterPix);
            end
        end
        
        h = plot(me, relS)
    end
    
    
    methods (Static)
        function rect = xyPix2RectPix(xyPix, sizePix)
            % rect = xyPix2RectPix(xyPix, sizePix)
            
            if size(xyPix, 1) == 1
                rect = [xyPix-sizePix, xyPix+sizePix];
            else
                rect = [bsxfun(@minus, xyPix, sizePix); ...
                        bsxfun(@plus,  xyPix, sizePix)];
            end
        end
        
        function xy_dst = xy4lines(xy1, xy2)
            % xy_dst = xy4lines(xy1, xy2)
            %
            % xy1    : (2, N) starting points.
            % xy2    : (2, N) ending points.
            %
            % xy_dst : (2, N*2) coordinates suitable to feed Scrren('DrawLines').
            
            n = size(xy1, 2);
            
            xy_dst(:, 2:2:n*2) = xy2;
            xy_dst(:, 1:2:n*2) = xy1;
        end
    end
end