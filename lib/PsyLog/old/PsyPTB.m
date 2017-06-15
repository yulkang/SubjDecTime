classdef PsyPTB < PsyVis
    properties
        commPsy     = '';
        commPTB     = '';
        
        argsPsy     = {};
        argsPTB     = {};
        
        % Copied from Scr.info at the time of initLog().
        win         = nan;
        pixPerDeg   = nan;
        centerPix   = [nan nan];
        centerPix4  = nan(1,4);
    end
    
    
    methods
        function me = PsyPTB(varargin)
            me.tag = 'PTB'; % default tag
            
            if nargin > 0
                me.init(varargin{:});
            end
        end
        
        
        function init(me, commPsy, argsPsy)
            me.commPsy   = commPsy;
            me.argsPsy   = argsPsy;
        end
        
        
        function initLog(me)
            me.win         = me.Scr.info.win;
            me.pixPerDeg   = me.Scr.info.pixPerDeg;
            me.centerPix   = me.Scr.info.centerPix(:);
            me.centerPix4  = [me.centerPix; me.centerPix];
            
            commPsy2PTB(me);
            argsPsy2PTB(me);

            initLog(me.log);
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
                case {'FillCircle', 'FillSquare', 'FrameCircle', 'FrameSquare'}
                    % Copy except rect.
                    toCopy             = setdiff(1:length(me.argsPsy), 2);
                    me.argsPTB(toCopy) = me.argsPsy(toCopy);
                    
                    % Transform rect.
                    if size(me.argsPsy{2},1) == 1
                        me.argsPTB{2} = ...
                             me.argsPsy{2}([1 2 1 2]) ...
                           + me.argsPsy{2}([3 3 3 3]) .* [-1, -1, 1, 1] ...
                           * me.pixPerDeg + me.centerPix4';
                                                
                    else
                        me.argsPTB{2} = bsxfun(@add, ...
                             me.argsPsy{2}([1 2 1 2],:) ...
                           + bsxfun(@times, me.argsPsy{2}([3 4 3 4],:), [-1, -1, 1, 1]') ...
                           * me.pixPerDeg, me.centerPix4);
                    end
                    
                                        
                case 'DrawDots'
                    % xy
                    me.argsPTB{1} = me.argsPsy{1} * me.pixPerDeg + me.centerPix;
                    
                    % size
                    me.argsPTB{2} = me.argsPsy{2} * me.pixPerDeg;
                    
                    % color
                    me.argsPTB{3} = me.argsPsy{3};
                    
                    % center
                    me.argsPTB{4} = me.argsPsy{4} * me.pixPerDeg;
                    
                    
                case {'FillRect', 'FrameRect', 'FillOval', 'FrameOval', 'DrawArc', 'FrameArc'}
                    % Copy except coordinates.
                    toCopy             = setdiff(1:length(me.argsPsy), 2);
                    me.argsPTB(toCopy) = me.argsPsy(toCopy);
                    
                    % Transform coordinates.
                    me.argsPTB{2} = me.argsPTB{2} * me.PixPerDeg ...
                                                  + me.centerPix;
                                              
%                 case 'DrawLine'
%                     
%                 case 'DrawLines'
%                     
%                 case {'FramePoly', 'FillPoly'}
                    
                otherwise
                    error('Unsupported .commPsy: %s', me.commPsy);
            end
        end
        
        
        function argsPTB2Psy(me)
        end
        
        
        function updated = update(me) 
            % PsyPTB won't update. So the function does nothing but drawing.
            % To update before drawing in the subclass, call
            % updateNDraw@super(me); 
            % from the subclass's updateNDraw().
            
            me.updated  = false;
            updated     = false;
        end
        
        
        function draw(me)
            Screen(me.commPTB, me.Scr.info.win, me.argsPTB{:});
        end
    end
end