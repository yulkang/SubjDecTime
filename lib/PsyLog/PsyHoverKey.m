classdef PsyHoverKey < PsyHover
    properties
%         % Number of patches.
%         n              = 2;
%         
%         % Angles to position the patches. 
%         % Provide scalar for equidistant positioning around a circle.
%         angleRad       = pi; 
%         
%         % Eccentricity of the patches, i.e., the radius of the circle.
%         eccenDeg       = 4;
%         
%         % Sort patches by their spatial location...
%         % 'likeText'    : L to R then U to D (default).
%         % 'likeClock'   : clockwise.
%         % 'none'        : In the order specified by angleRad.
%         %                 If angleRad is scalar and n>1, the order is clockwise.
%         sortOrder      = 'likeText';
%         
%         % Color while the cursor is in/out of the patch.
%         colorIn         = [255 0 0]';
%         colorOut        = [255 255 0]'; % cat(3, [255 0 0]', [255 255 0]'); 
%         
%         % Logged names for enter/exit/hold.
%         enterMarks      = {};
%         exitMarks       = {};
%         holdMarks       = {};
%         
%         % Whether any patch is entered.
%         inNow           = nan;
%         
%         % When the current patch was entered.
%         tEntered        = nan;
%         
%         % How long to stay in the target to be regarded as 'hold'.
%         holdSec         = 0.5;
    
        keyMap   = {};    
    end
    
    
    properties (Transient)
        Key      = [];
    end
    
    
    methods
        function me = PsyHoverKey(cScr, varargin)
            me = me@PsyHover;
            
            me.tag           = 'HoverKey';
            me.updateOn      = unionCellStr(me.updateOn, {'Key'});
            
            me.tempNames     = {'Key'}; % Will not be copied/saved.
            me.commPsy       = 'FillCircle';
            
            me.sizeDeg = 0.5;
            me.centerDeg = [0 0]';
            
            if nargin > 0, me.Scr = cScr; end                
            if nargin > 1
                me.init(varargin{:});
            end
        end
        
        
        function initTrial(me)
            me.initTrial@PsyHover;
            
            me.Key = me.Scr.c.Key;
        end
        
        
        function exit(me, iPatch, t)
            % exit(me, iPatch, t)
            
            me.color(:,iPatch) = me.colorOut(:,iPatch); % repmat(me.colors(:, 1, 1), [1, nnz(newOut)]);
            addLog(me, me.exitMarks(iPatch), t);

            me.tEntered = nan;
            me.inNow    = nan;
        end
        
        
        function enter(me, iPatch, t)
            % enter(me, iPatch, t)
            
            me.color(:,iPatch) = me.colorIn(:,iPatch); % repmat(me.colors(:, 1, 2), [1, nnz(newIn)]);
            addLog(me, me.enterMarks(iPatch), t);

            me.tEntered = t;
            me.inNow    = iPatch;
        end
        
        
        function update(me, from)
            % update(me, from)
            
            if ~me.visible, return; end
                    
            switch from
                case 'Key'
                    
                    cKey        = me.Key;
                    cSampledSec = cKey.sampledAbsSec;
                    cKeyNames   = cKey.cKeyNames;
                    
                    cOn         = strcmpfinds(cKeyNames, me.keyMap, true);
                    
                    
                    
                    switch me.commPsy
                        case 'FillCircle'
                            in = find( sum(bsxfun(@minus, me.xyPix, ...
                                                          cMouse.xyPix) .^ 2 ...
                                          , 1) ...
                                       < me.sizePix.^2);    
                            % isInCircle(me.xyPix, cMouse.xyPix, me.sizePix);
                            
                        case 'FillRect'
                            in = find( sum( bsxfun(@lt, ...
                                                abs(bsxfun(@minus, me.xyPix, ...
                                                               cMouse.xyPix)) ...
                                                , me.sizePix) ...
                                          , 1));
                    end
                           
                    cTEntered = me.tEntered; % when the current patch was entered,
                                             % if any.
                    
                    if isempty(in)
                        % new out
                        if ~isnan(cTEntered) 
                            exit(me, me.inNow, cSampledSec);
                        end                        
                    else
                        % new in
                        if isnan(cTEntered) && ...
                           isnan(me.t_.(me.enterMarks{in}))
                           
                            enter(me, in, cSampledSec);
                        end
                        
                        % maintained
                        if cSampledSec - cTEntered >= me.holdSec(in) ...
                           && isnan(me.t_.(me.holdMarks{in})) 
                           
                            addLog(me, me.holdMarks(in), cSampledSec);
                        end
                    end
            end
        end
        
        
        function exitAngle(~)
            % EXITANGLE     Unsupported in PsyHoverKey. 
            %
            % See also PsyHover.EXITANGLE
            
            error('exitAngle unsupported in PsyHoverKey!');
        end
        
        
        function exitTraj(~, ~, ~)
            % EXITANGLE     Unsupported in PsyHoverKey. 
            %
            % See also PsyHover.EXITTRAJ
            
            error('exitTraj unsupported in PsyHoverKey!');
        end
    end
end