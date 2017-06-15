classdef PsyHover < PsyPTB
    properties
        % Number of patches.
        n              = nan;
        
        % Angles to position the patches. 
        % Provide scalar for equidistant positioning around a circle.
        angleRad       = pi; 
        
        % Eccentricity of the patches, i.e., the radius of the circle.
        eccenDeg       = 4;
        
        % Sensitive radius. 
        sensRDeg    = nan(2,1); % Defaults to sizeDeg.
        sensRPix    = nan(2,1); % Defaults to sizePix.
        
        % Sort patches by their spatial location...
        % 'likeText'    : L to R then U to D (default).
        % 'likeClock'   : clockwise.
        % 'none'        : In the order specified by angleRad.
        %                 If angleRad is scalar and n>1, the order is clockwise.
        sortOrder      = 'likeText';
        
        % Color while the cursor is in/out of the patch.
        colorIn         = [255 0 0]';
        colorOut        = [255 255 0]'; % cat(3, [255 0 0]', [255 255 0]'); 
        
        % Logged names for enter/exit/hold.
        enterMarks      = {};
        exitMarks       = {};
        holdMarks       = {};
        
        % Which patch is entered (first).
        chosen = nan;
        
        % Whether any patch is entered.
        inNow           = nan;
        
        % When the current patch was entered.
        tEntered        = nan;
        
        % How long to stay in the target to be regarded as 'hold'.
        holdSec         = 0.5;
        
        % inpMode: Key, Mouse, or Eye
        inpMode         = 'Mouse';
        
        % keys: keys to enter
        keyNames = {};
    end
    
    
    properties (Transient)
        Inp       = [];
    end
    
    
    methods
        %% Before Each Experiment
        function me = PsyHover(cScr, varargin)
            me = me@PsyPTB;
            
            me.tag           = 'Hover';
            
            me.tempNames     = {'Inp'}; % Will not be copied/saved.
            me.commPsy       = 'FillCircle';
            
            me.sizeDeg       = 0.5;
            me.centerDeg     = [0 0]';
            
            if nargin > 0, me.Scr = cScr; end                
            if nargin > 1
                varargin2fields(me, varargin);
                me.init;
            end
        end
        
        
        function init(me, varargin)
            % Unlike the superclass PsyPTB, PsyHover.init just gets the 
            % property values, rearranges patches, and performs unit conversion.
            %
            % See also: PsyPTB/init
            
            varargin2fields(me, varargin);
            
            % To prevent overload during high frequency sampling, 
            % update appearance only before each draw, 
            % and check real timing at closeLog.
            me.updateOn  = {'befDraw'}; % unionCellStr(me.updateOn, {me.inpMode});
                
            initArrangement(me);
            initHover(me);
        end
        
        
        %% Before Each Trial
        function initLogTrial(me)
            me.initTrial;
            
            me.enterMarks   = csprintf('enter%d', num2cell(1:me.n));
            me.exitMarks    = csprintf('exit%d',  num2cell(1:me.n));
            me.holdMarks    = csprintf('hold%d',  num2cell(1:me.n));

            me.initLogEntries('markFirst', ...
                              [me.enterMarks, me.exitMarks, me.holdMarks], ...
                              'absSec');

            me.initLogTrial@PsyPTB;
        end
        
        
        %% During Experiment
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
            
            if isnan(me.chosen), me.chosen = iPatch; end
        end
        
        
        function update(me, from)
            % update(me, from)
            %
            % See also closeLog.
            
            if ~me.visible, return; end

            from = me.inpMode;
%             if any(strcmp(from, {'Mouse', 'Eye', 'Key'})) % Deprecated
                cInp = me.Inp;
                cSampledSec = cInp.sampledAbsSec;
                
                % Determine 'in'
                if strcmp(from, 'Key')
                    if cInp.keyDown
                        in = find(strcmps(cInp.cKeyNames, me.keyNames), 1, 'first');
                    else
                        in = me.inNow;
                        
                        if cInp.keyUp && ...
                                any(find(strcmps(cInp.cKeyNamesUp, me.keyNames), 1, 'first') == in)
                            in = [];
                        end
                    end
                else
                    xy_me  = me.xyPix;
                    xy_inp = cInp.xyPix;
                    
                    in = find( (xy_me(1,:) - xy_inp(1)).^2 ...
                             + (xy_me(2,:) - xy_inp(2)).^2 ...
                              < me.sensRPix.^2 );
                    
%                     switch me.commPsy
%                         case {'FillCircle', 'FrameCircle'}
%                             in = find( sum(bsxfun(@minus, me.xyPix, ...
%                                                           cInp.xyPix) .^ 2 ...
%                                           , 1) ...
%                                        < me.sensRPix.^2);    
                            % isInCircle(me.xyPix, cInp.xyPix, me.sizePix);
                            
%                         case {'FillRect', 'FrameRect'}
%                             in = find( sum( bsxfun(@lt, ...
%                                                 abs(bsxfun(@minus, me.xyPix, ...
%                                                                cInp.xyPix)) ...
%                                                 , me.sensRPix) ...
%                                           , 1));
%                     end
                end
                
                % Common to inpModes
                cTEntered = me.tEntered; % when the current patch was entered,
                                         % if any.

                if isempty(in) || isnan(in)
                    % new out
                    if ~isnan(cTEntered) 
                        exit(me, me.inNow, cSampledSec);
                    end                        
                else
                    % new in
                    if isnan(me.t_.(me.enterMarks{in}))
                        % If directly jumped from another patch
                        if ~isnan(cTEntered)
                            exit(me, me.inNow, cSampledSec);
                        end

                        % Enter the new patch
                        enter(me, in, cSampledSec);
                        cTEntered = cSampledSec;
                    end

                    % maintained
                    if (cSampledSec - cTEntered >= me.holdSec(in)) ...
                       && isnan(me.t_.(me.holdMarks{in}))

                        addLog(me, me.holdMarks(in), cSampledSec);
                    end
                end
%             end
        end
        
        
        %% After Experiment
        function closeLog(me)
            me.closeLog@PsyPTB('pix2deg');
            
            if any(strcmp(me.inpMode, {'Eye', 'Mouse'}))
                % Convert xyPix to xyDeg if not done already.
                if ~(me.Inp.n_.xyDeg == me.Inp.n_.xyPix)
                    me.Inp.closeLog;
                end
                
                % For each enter and exit, determine the real timing
                % by looking back from the recorded timing 
                % and examining the real position.
                for cc  = {'enter', 'exit'
                           @lt    , @ge}
                    evt = cc{1};
                    op  = cc{2};
                
                    incl    = find(me.did(evt));
                    t       = me.relSec(evt, 'all');

                    for ii  = incl
                        ct  = t(ii);
                        [cXyDeg, tRelS]  = me.Inp.vTrim('xyDeg', 'LE', ct);

                        t1st = tRelS(find(...
                                       op(sum(bsxfun(@minus, ...
                                                     me.xyDeg(:,ii), ...
                                                     cXyDeg) .^ 2 ...
                                             ,1) ...
                                        , me.sensRDeg.^2) ...
                                     , 1, 'first'));

                        me.replaceT(sprintf('%s%d', evt, ii), t1st, 'relSec');
                    end
                end
            end
        end
        
        h = plot(Hover, relS);        
        
        %% Analysis
        function res = did(me, eventName, ix)
            % res = did(me, eventName, [ix])
            % 
            % eventName : 'enter', 'hold', 'exit'
            % ix        : omit to querry all.
            
            if nargin < 3
                ix = 1:me.n;
            end
            
            res = false(1, length(ix));
            
            for ii = 1:length(ix)
                res(ii) = (me.n_.(sprintf('%s%d', eventName, ix(ii))) > 0);
            end
        end
        
        
        function res = relSec(me, eventName, opt)
            % res = relSec(me, eventName, opt)
            %
            % eventName: 'enter', 'hold', 'exit'
            %
            % opt: 'happened' (default), 'all'
            %
            % res: all the time that the event happened.
            %      NaN if none happened.
            
            if nargin == 1
                res = me.relSec@PsyLogs;
                
            elseif any(strcmp(eventName, {'enter', 'hold', 'exit'}))
            
                if ~exist('opt', 'var'), opt = 'happened'; end
                
                switch opt
                    case 'happened'
                        cIx = me.did(eventName);

                        switch nnz(cIx)
                            case 0
                                res = nan;
                            case 1
                                res = me.relSec@PsyLogs(...
                                         sprintf('%s%d', eventName, find(cIx)));
                            otherwise
                                res = zeros(1, nnz(cIx));

                                for ii = find(cIx)
                                    res(ii) = me.relSec@PsyLogs(...
                                                 sprintf('%s%d', eventName, ii));
                                end
                        end
                        
                    case 'all'
                        res = zeros(1,me.n);
                        for ii = 1:me.n
                            res(ii) = me.relSec@PsyLogs(...
                                     sprintf('%s%d', eventName, ii));
                        end
                end
            else
                res = me.relSec@PsyLogs(eventName);
            end
        end
        
        
        function res = absSec(me, eventName)
            % res = absSec(me, eventName)
            %
            % eventName: 'enter', 'hold', 'exit'
            % unit     : 
            %
            % res: all the time that the event happened.
            
            if any(strcmp(eventName, {'enter', 'hold', 'exit'}))
            
                cIx = me.did(eventName);

                switch nnz(cIx)
                    case 0
                        res = nan;
                    case 1
                        res = me.t_.(sprintf('%s%d', eventName, find(cIx)));
                    otherwise
                        res = zeros(1, nnz(cIx));

                        for ii = find(cIx)
                            res(ii) = me.t_.(sprintf('%s%d', eventName, ii));
                        end
                end
            else
                res = me.t_.(eventName);
            end
        end
        
        
        function th = exitAngle(me)
            % th = exitAngle(me)
            %
            % See also EXITTRAJ
           
            ixExit  = find(me.did('exit'));
            
            if length(ixExit) == 1
                xyMe    = me.xyPix(:,ixExit);
                tExit   = me.absSec('exit');
                xyInp = me.Inp.vTrim('xyPix', tExit, tExit, 'absSec');
                
                Dxy     = xyInp - xyMe;
                th      = cart2pol(Dxy(1), Dxy(2));
            else
                warning('exitAngle currently works only for 1 exit!');
                th = nan; r = nan; Dxy = nan(2,1);
            end
        end
        
        
        function [xyDeg t] = exitTraj(me, fromT, toT)
            % [xyDeg t] = exitTraj(me, fromT, toT)
            %
            % See also EXITANGLE
            
            if ~(me.Inp.n_.xyDeg == me.Inp.n_.xyPix)
                me.Inp.closeLog;
            end
            
            tExit   = me.absSec('exit');
            xyDeg   = me.Inp.vTrim( 'xyDeg', tExit+fromT, tExit+toT, 'absSec');
            t       = me.Inp.relSec('xyDeg', tExit+fromT, tExit+toT, 'absSec');
        end
        
        
        %% Subfunctions
        function initArrangement(me)
            me.commPsy2PTB;
            
            % Provide scalar for equidistant positioning around a circle.
            % By construction, xyDeg goes in clockwise direction from angleRad.
            % Zero rad means rightward.
            if (length(me.angleRad) == 1) && (me.n > 1)
                me.angleRad = me.angleRad + pi*2*((1:me.n)-1)./me.n;
            end
            
            % If unspecified, n is the length of angleRad.
            if isnan(me.n)
                me.n = length(me.angleRad);
            end
                
            for ii = me.n:-1:1
                [me.xyDeg(1, ii), me.xyDeg(2, ii)] ...
                    = pol2cart(me.angleRad(ii), me.eccenDeg);
            end
            
            % Center at centerDeg. centerDeg of [0 0] is the screen's center.
            me.xyDeg = bsxfun(@plus, me.xyDeg, me.centerDeg);
            
            % Sort patches as specified.
            switch me.sortOrder
                case 'likeText'
                    % First, convert xyDeg into xyPix, to avoid numerical error
                    % resulting in unwanted sort result.
                    me.argsPsy2PTB;
                    
                    % Sort xyPix coordinates, first based on y (from up to down),
                    % then based on x (from left to right).
                    [~, sortedIx] = sortrows(round(me.xyPix'), [2 1]);
                    me.xyPix = me.xyPix(:, sortedIx);
                    
                    % Reorder xyDeg in the sorted order.
                    me.xyDeg = me.xyDeg(:, sortedIx);
                    
                case 'none'
                    % Leave xyDeg untouched. - even likeClock? sounds wrong
                    
                otherwise % including likeClock - 150730
                    error('sortOrder %s unsupported yet!\n', me.sortOrder);
            end
            
            % Autofill colors if necessary
            if size(me.color, 2) ~= me.n
                me.color = repmat(me.color(:,1), [1, me.n]);
            end
            if size(me.colorIn, 2) ~= me.n
                me.colorIn = repmat(me.colorIn(:,1), [1, me.n]);
            end
            if size(me.colorOut, 2) ~= me.n
                me.colorOut = repmat(me.colorOut(:,1), [1, me.n]);
            end
        end
        
        
        function argsPsy2PTB(me)
            % Sets xyPix, sizePix, penWidthPix, centerPix, [sensRDeg], sensRPix.
            
            me.centerPix = me.Scr.deg2pix(me.centerDeg);
            me.argsPsy2PTB@PsyPTB;
            
            if any(isnan(me.sensRDeg))
                me.sensRDeg = me.sizeDeg;
            end
            me.sensRPix = me.sensRDeg .* me.pixPerDeg;
        end
        
        
        function initHover(me)
            me.copyScrInfo;
            me.argsPsy2PTB;
        end
        
        
        function initTrial(me)
            me.Inp = me.Scr.c.(me.inpMode);
            
            for cProp = {'holdSec', 'sizeDeg', 'sizePix'}
                if length(me.(cProp{1})) < me.n
                    me.(cProp{1}) = repmat(me.(cProp{1}), [1 me.n]);
                end
            end            
            
            me.color        = me.colorOut;
            me.inNow        = nan;
            me.tEntered     = nan;
        end
        
        function set.colorIn(me, v)
            if ~isempty(me.n) && ~isnan(me.n)
                me.colorIn  = rep2fit(v, [3 me.n]);
            
                if ~isnan(me.inNow)
                    me.color(:,me.inNow) = me.colorIn(:,me.inNow);
                end
            end
        end
        
        function set.colorOut(me, v)
            if ~isempty(me.n) && ~isnan(me.n) 
                me.colorOut = rep2fit(v, [3 me.n]);

                me.color = me.colorOut;
                if ~isnan(me.inNow) && size(me.colorIn,2) >= me.inNow
                    me.color(:,me.inNow) = me.colorIn(:,me.inNow);
                end
            end
        end
    end
end