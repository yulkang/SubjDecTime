classdef PsyScr < handle
    %
    % : Wrapper for Screen() function that logs every frame's onset.
    %   Also can contain other PsyLog suite objects,
    %   for automatic logging of onset & offset, and
    %   for shorter & more readable code.
    %
    %
    % Minimal workflow (using frame onset logging functionality only)
    %
    %     Scr = PsyScr('distCm', 50); % Others are set automatically.
    %     Scr.open;
    %
    %     for iTrial = 1:nTrial
    %         Scr.initLog; % init log every trial.
    %         ...
    %         Scr.markEpoch('epochName1');
    %         ...
    %         Scr.closeLog; % optionally, mark the end of the trial.
    %         save(fileName, 'Scr'); % Save the log of the trial.
    %     end
    %
    %     Scr.close;
    %
    %
    % Full workflow (using PsyVis objects for shorter & more readable code)
    %
    %     Scr = PsyScr('distCm', 50); % Others are set automatically.
    %     Scr.open;
    %
    %     % Visual objects, named, and coordinate specified in visual degrees.
    %     Scr.addVis( PsyPTB('FP'   , 'FillOval', [0 0 1], [255 0 0]) );
    %     Scr.addVis( PsyPTB('Targ' , 'FillOval', [-5 0 1; 5 0 1], [255 0 0]) );
    %     Scr.addVis( PsyMotionDots('Motion', [0 0 2.5]);
    %
    %     % Auditory objects. Be reassured that actual sound is cached but not saved every trial.
    %     Scr.Aud.wav = PsyWav('correct', 'correct.wav', 'wrong', 'wrong.wav');
    %
    %     % Input
    %     Scr.addInp(PsyMouse, PsyKey, PsyEye); % Devices to use. Automatically logged.
    %     Scr.addRead(@checkInput); % How to interpret the input. Automatically logged.
    %
    %     for iTrial = 1:nTrial
    %         Scr.initLog(maxSec); % Init log every trial. 
    %                              % Also initializes all PsyVis/Aud/Inp/Read objects' log
    %                              % contained in Scr.
    %         
    %         coh = randsample([-0.512 -0.256 0.256 0.512]);
    %         Scr.Vis.Motion.init('coh', coh, 'maxSec', maxSec);
    %
    %         Scr.show('FP');
    %         Scr.wait('until', 1, {'fixAcq'}); % 'until' waits until 1 sec from trial start.
    %
    %         Scr.show('Targ', 'Motion');
    %         Scr.wait('for', 5, {'fixBreak'}); % waits 5 sec until fixation break.
    %
    %         Scr.hide('Motion');
    %         Scr.wait('for', 1, {'targAcq'});
    %
    %         if Scr.Read.v.dir == sign(coh)
    %             Scr.Aud.wav.play('Correct');
    %         else
    %             Scr.Aud.wav.play('Wrong');
    %         end
    %
    %         Scr.closeLog; % optionally, mark the end of the trial.
    %         save(fileName, 'Scr'); % Save the log of the trial.
    %     end
    %
    %     Scr.close;
    %     
    %
    % PsyScr Properties:
    %
    %     Trial % (optional) parent. A PsyTrial object.
    % 
    %     % Logging
    % 
    %     L = struct('frOnAbsSec', 'frOnRelSec');
    %     stT = nan; %  start time of current Log.  Always in AbsSec.
    %     enT = nan; % end time of current Log.    Always in AbsSec.
    % 
    %     % PTB interface
    % 
    %     scr % physical screen
    %     win % handle to window
    %     rect % size of the window
    %     widthCm % physical width of the screen showing area.
    %     distCm % physical distance from the eye to the screen.
    %     refreshRate % real or asserted refresh rate.
    %     pixPerDeg
    %     bkgColor % background color
    % 
    %     % PsyVis interface
    % 
    %     Vis  % scalar struct with fields of PsyVis objects.
    %     visOrd % cell array of currently shown PsyVis object names, from bottom to top. 
    % 
    %     % Other PsyLog objects
    % 
    %     Aud  % scalar struct with fields of PsyAud objects.
    %     Inp  % object vector.
    %     Read % scalar struct with fields of PsyRead objects.
    %
    %
    % PsyScr Methods:
    %
    %     PsyScr    - Constructor.
    %     init      - Assign multiple properties at once.
    %     open      - Wrapper for Screen('OpenWindow'), assigns defaults if needed.
    %     close     - Wrapper for Screen('Close').
    %     initLog   - Initializes timestamp & PsyVis log for each trial.
    %     closeLog  - Marks trial end timestamp.
    %     flip      - Performes Screen('Flip') and logs onset timing & PsyVis order.
    %     

    
    properties
        %% PsyLog interface
        
        Trial % (optional) parent. A PsyTrial object.
        name = 'Scr';
        
        %% Timing
        
        frOnAbsSec
        cFr
        
        stT = nan; % start time of current Log.  Always in AbsSec.
        enT = nan; % end time of current Log.    Always in AbsSec.
        
        logOn = false; % Turned on by initLog, turned off by closeLog.
        
        %% PTB interface
        
        scr % physical screen
        win % handle to window
        rect % size of the window
        widthCm % physical width of the screen showing area.
        distCm % physical distance from the eye to the screen.
        refreshRate % real or asserted refresh rate.
        pixPerDeg % pixel per degree. Assumed constant but not really when the screen is big or close enough.
        bkgColor = [0 0 0]; % background color
        constPixPerDeg = true; % treat pixPerDeg constant throughout a display. False unsupported now.
        
        %% Epoch logging
        % .toLog        : a scalar boolean. true if any Scr.addEpoch happened before flip.
        % .iEpoch       : where to log now.
        % .onAbsSec     : timestamp of each snapshot.
        % .onLog        : a scalar struct. Each field has a scalar .iEpoch value
        %                 at the time Scr.addEpoch issued.
        epochLog = struct('nEpoch', 0, 'toLog', {false}, 'iLog', {1}, ...
                          'onAbsSec', {[]}, 'onLog', {struct});
        
        
        %% PsyVis interface & logging
        
        Vis   % scalar struct with fields of PsyVis objects.
        
        % Following are initialized with initLog.
        
        nVis     = 0; % Number of visual objects in Vis.
        visOrd   = PsyOrder; % A PsyOrder object.
        
        % visOrdLog: log for psyVis 
        % .toLog    : a scalar boolean. true if any PsyVis object is shown or hidden.
        % .iLog     : where to log now.
        % .onAbsSec : timestamp of each snapshot.
        % .visOrd   : array of visOrd, logged whenever there's a change.
        visOrdLog   = struct('toLog', {false}, 'iLog', {1}, ...
                          'onAbsSec', {[]}, 'visOrd', {});
        
        %% Other PsyLog objects
        
        Aud   % scalar struct with fields of PsyAud objects.
        Inp   % PsyInp object cell array (1 x nInp).
        Read  % scalar PsyRead object.
    end
    
    
    methods
        
        %% Initialization
        
        function me = PsyScr(varargin)
        % Scr = PsyScr;
        %
        % : Assigns an empty PsyScr struct for later use.
        %   No argument syntax supported for uncomplicated saving & loading.
        %
        % Scr = PsyScr('propName1', prop1, ...);
        %
        % : Equivalent to Scr = PsyScr; Scr.init('propName1', prop1, ...);
            
            if nargin>0
                me.init(varargin{:});
            end
        end
        
        
        function init(me, varargin)
        % Scr.init('propName1', prop1, ...)
        %
        % : Sets multiple properties at once. Code kept minimal for flexibility.
        %   Specify .distCm of your own setup. It defaults to
        %   sensible yet arbitrary values.
            
            struct2obj(me, varargin{:});
            
            if isempty(me.distCm)
                me.distCm = 50;
                warning('.distCm is unset!  Will be set to an arbitrary value of %d cm..', ...
                         me.distCm);
            end
        end
        
        
        function open(me, varargin)
        % Scr.open([screenNumber, color, rect, ...]);
        %
        % : Same syntax as Screen('OpenWindow', ...).
        %   Defaults to last screen, and black background.
        %   Computes pixPerDeg from estimated resolution,
        %   and widthCm and distCm from Scr.init().
            
            % Setting defaults
            if (length(varargin) < 1) && isempty(me.scr)
                me.scr = max(Screen('Screens'));
            elseif ~isempty(varargin{1})
                me.scr = varargin{1};
            end
            
            if (length(varargin) < 2) && isempty(me.bkgColor)
                me.bkgColor = [0 0 0];
            elseif ~isempty(varargin{2})
                me.bkgColor = varargin{2};
            end
            
            argin = varargin(3:end);
            
            % Opening
            [me.win, me.rect] = Screen('OpenWindow', me.scr, me.bkgColor, argin{:});
            
            % Physical size
            wCm = Screen('DisplaySize', me.scr) / 10;
            fprintf('Detected display width: %d cm\n', wCm);
            
            if ~isempty(me.widthCm) && abs(me.widthCm - wCm) > 1
                error('Detected (%d cm) and specified (%d cm) display width differs > 1cm!', ...
                      wCm, me.widthCm);
            else
                me.widthCm = wCm;
            end
            
            if ~isempty(me.widthCm) && ~isempty(me.distCm)
                me.pixPerDeg = me.rect(3) / (atan(me.widthCm / 2 / me.distCm) ...
                                             * 2 / pi * 180);
            end
            
            % Refresh rate
            rRate = Screen('NominalFrameRate', me.scr);
            fprintf('Detected refresh rate: %d Hz\n', rRate);
            
            if ~isempty(me.refreshRate) && me.refreshRate ~= rRate
                warning('Detected nominal (%d Hz) and specified (%d Hz) refresh rate differs!', ...
                        rRate, me.refreshRate);
            else
                me.refreshRate = rRate;
            end
        end
        
        
        function close(me)
            Screen('Close', me.win);
        end
        
        
        %% Logging
        
        function [frOnAbsSec, cFr] = flip(me, varargin)
            % [frOnAbsSec, cFr] = Scr.flip(...)
            %
            % : Wrapper for Screen('flip').
            %   Also logs frame onset and visual objects' order (if they exist).
            
            [~, frOnAbsSec] = Screen('Flip', me.win, varargin{:});
            cFr = me.cFr;
            
            frOnRelSec = frOnAbsSec - Scr.stT;
            
            if me.logOn
                me.frOnAbsSec(me.cFr) = frOnAbsSec;
                me.frOnRelSec(me.cFr) = frOnRelSec;

                pVisOrd     = me.visOrdLog.visOrd(me.logVis.iLog-1).cell;
                cVisOrd     = me.visOrd.cell;
                newlyShown  = setdiff(cVisOrd, pVisOrd);
                newlyHidden = setdiff(pVisOrd, cVisOrd);

                for cVis = newlyShown
                    me.Vis.(cVis{1}).nOn = me.Vis.(cVis{1}).nOn + 1;
                    me.Vis.(cVis{1}).onFr(me.Vis.(cVis{1}).nOn)     = me.cFr;
                    me.Vis.(cVis{1}).onAbsSec(me.Vis.(cVis{1}).nOn) = frOnAbsSec;
                    me.Vis.(cVis{1}).onRelSec(me.Vis.(cVis{1}).nOn) = frOnRelSec;
                end

                for cVis = newlyHidden
                    me.Vis.(cVis{1}).nOff = me.Vis.(cVis{1}).nOff + 1;
                    me.Vis.(cVis{1}).offFr(me.Vis.(cVis{1}).nOff)     = me.cFr;
                    me.Vis.(cVis{1}).offAbsSec(me.Vis.(cVis{1}).nOff) = frOnAbsSec;
                    me.Vis.(cVis{1}).offRelSec(me.Vis.(cVis{1}).nOff) = frOnRelSec;
                    me.Vis.(cVis{1}).durSec(me.Vis.(cVis{1}).nOff)    = ...
                        me.Vis.(cVis{1}).offAbsSec(me.Vis.(cVis{1}).nOff) - ...
                        me.Vis.(cVis{1}).onAbsSec(me.Vis.(cVis{1}).nOn);
                end

                if me.visOrdLog.toLog % when show/hide/change in order was attempted.
                    me.visOrdLog.visOrd(me.logVis.iLog)        = me.visOrd;
                    me.visOrdLog.onAbsSec(me.logVis.iLog)      = frOnAbsSec;
                    me.visOrdLog.toLog                         = false;
                    me.visOrdLog.iLog                          = me.visOrdLog.iLog + 1;
                end

                if me.epochLog.toLog % when addEpoch was called.
                    me.epochLog.onAbsSec(me.epochLog.iLog)  = frOnAbsSec;
                    me.epochLog.toLog                       = false;
                    me.epochLog.iLog                        = me.L.iLog + 1;
                end
            end
            
            me.cFr = me.cFr + 1;
        end
        
        
        function initLog(me, maxSec, maxNEpoch)
            % Scr.initLog(maxSec, maxNEpoch);
            %
            % Initializes current frame (.cFr) as 1, start time (.stT) from GetSecs,
            % and empties and allocates logging variables,
            % like .frOnAbsSec, and .L.visOrd.
            %
            % If .Vis contains no PsyVis objects as fields at this point,
            % .L.visOrd will not be allocated.
            
            me.logOn = true;
            
            if nargin<2, maxSec = 5;     end
            if nargin<3, maxNEpoch = 20; end
            
            me.cFr = 1;
            me.stT = GetSecs;
            
            maxNFr = ceil(maxSec / me.refreshRate);
            
            me.frOnAbsSec = nan(1, maxNFr);
            
            %% epoch logging
            me.epochLog.toLog       = false;
            me.epochLog.iLog        = 1;
            me.epochLog.onAbsSec    = nan(1, maxNFr);
            me.epochLog.onLog       = cell2struct(nan(1,me.visOrdLog.nEpoch), fieldnames(me.epochLog.onLog));
            
            %% object logging
            if ~isempty(me.Vis)
                me.visOrdLog.toLog     = false;
                me.visOrdLog.iLog      = 1;
                me.visOrdLog.onAbsSec  = cell2struct(nan(1,me.visOrdLog.nVis), fieldnames(me.Vis));
                me.visOrdLog.visOrd(maxNEpoch) = PsyOrder;
                
                for cVis = fieldnames(me.Vis)'
                    me.Vis.(cVis{1}).initLog(maxNFr, maxNEpoch);
                end
            end
            
            if ~isempty(me.Aud)
                for cAud = fieldnames(me.Aud)'
                    me.Aud.(cAud{1}).initLog(maxNFr, maxNEpoch);
                end
            end
            
            if ~isempty(me.Inp)
                for cInp = fieldnames(me.Inp)'
                    me.Inp.(cInp{1}).initLog(maxNFr, maxNEpoch);
                end
            end
            
            if ~isempty(me.Read)
                me.Read.initLog(maxNFr, maxNEpoch);
            end
        end
        
        
        function closeLog(me)
            % Scr.closeLog
            %
            % Saves trial end timestamp at Scr.enT.
            
            me.enT = GetSecs;  
            
            me.logOn = false;
        end
        
        
        function frOnRelS = frOnRelSec(me, vec)
            % frOnRelSec = Scr.frOnRelSec([...]);
            %
            % : frame onset timestamp, relative to trial onset.
            %   Use as if it is a vector property.
            %
            % Ex>
            % Scr.frOnRelSec(3:5) == Scr.frOnAbsSec(3:5) - Scr.stT
            %
            % ans = 
            %       1 1 1
            
            if nargin == 2
                frOnRelS = me.frOnAbsSec(vec) - me.stT;
            else
                frOnRelS = me.frOnAbsSec - me.stT;
            end
        end
        
        
        %% Epoch logging
        
        function addEpoch(me, varargin)
            % Scr.addEpoch(epochName1[, epochName2, ...])
            %
            % : Add a complete list of epoch names that can possibly
            %   appear within a trial before calling Scr.initLog for
            %   that trial, to prevent memory waste.
            
            for cEpochName = varargin
                me.epochLog.onLog.(cEpochName{1}) = [];
            end
        end
        
        
        function markEpoch(me, epochName)
            % Scr.markEpoch(epochName)
            %
            % : Reserves to add epoch timestamps,
            %   which will be marked at the upcoming Scr.flip.
            %   Epoch names should be unique within a trial,
            %   or the last call to Scr.addEpoch will overwrite
            %   existing timestamp.
            %
            %   Declaring epochs before Scr.initLog for each trial
            %   saves memory.
            
            if ~isfield(me.epochLog.onLog, epochName)
                me.addEpoch(epochName);
            end
            
            me.epochLog.onLog.(epochName) = me.epochLog.iLog;
        end
        
        
        function delEpoch(me, epochName)
            % Scr.delEpoch(epochName)
            %
            % : Deletes epochName from the internal list.
            %   If the epoch is used in later trials, Scr.delEpoch is
            %   often unnecessary. Using Scr.initLog will initialize
            %   the epoch's onset as nan.
            %
            %   You can safely finish using Scr struct without ever using
            %   Scr.delEpoch. It exists only for consistency's sake.
            
            me.epochLog.onLog = rmfield(me.epochLog.onLog, epochName);
            me.epochLog.nEpoch = length(fieldnames(me.epochLog.onLog));
        end
        
        
        function delEpochAll(me)
            % Scr.delEpochAll
            %
            % : Empties the epochName list.
            %   If any epoch is used in later trials, Scr.delEpochAll is
            %   usually unnecessary. Using Scr.initLog will initialize
            %   the epoch's onset as nan.
            %
            %   You can safely finish using Scr struct without ever using
            %   Scr.delEpochAll. It exists only for consistency's sake.
            
            me.epochLog.onLog = struct;
            me.epochLog.nEpoch = 0;
        end
        
        
        function absSec = epochOnAbsSec(me, epochName)
            % absSec = me.epochOnAbsSec(epochName);
            
            absSec = me.epochLog.onAbsSec(me.epochLog.onLog.(epochName));
        end
        
        
        function relSec = epochOnRelSec(me, epochName)
            % relSec = me.epochOnRelSec(epochName);
            
            relSec = me.epochLog.onAbsSec(me.epochLog.onLog.(epochName)) - me.stT;
        end
        
        
        function absSec = epochOffAbsSec(me, epochName)
            % absSec = me.epochOffAbsSec(epochName);
            
            absSec = me.epochLog.onAbsSec(me.epochLog.onLog.(epochName) + 1);
        end
        
        
        function relSec = epochOffRelSec(me, epochName)
            % relSec = me.epochOffRelSec(epochName);
            
            relSec = me.epochLog.onAbsSec(me.epochLog.onLog.(epochName) + 1) - me.stT;
        end
        
        
        %% PsyVis interface
        
        function show(me, varargin)
            % Scr.show(order, PsyVisName1, [PsyVisName2, ..])
            % Scr.show(PsyVisName1, [PsyVisName2, ..])
            %
            % Show PsyVis object(s), already added by Scr.addVis, 
            % in the specified order, from next frame.
            % Also used to change the order the object is shown.
            %
            % The object(s) will be drawn only with its own .draw command,
            % through Scr.updateNDrawAll or Scr.drawAll.
            %
            % Order is a string. '^objName' will mean just above the
            % object. '_objName' will just below it. 
            % Default is '^en_', above all other objects.
            % '_st_' will mean below all other objects.
            %
            % When order is empty or omitted, the objects will be added
            % above all other objects.
            %
            % Among the specified objects, the last will be drawn last, 
            % i.e., above the others.
                        
            for cVis = varargin
                if ~isfield(me.Vis, cVis{1})
                    error('%s unavailable: use Scr.addVis before showing!\n', ...
                            cVis{1});
                end
            end
           
            me.visOrd = me.visOrd.on(varargin{:});
            me.L.visChanged = true;
        end
        
        
        function hide(me, varargin)
            % Scr.hide(PsyVisName1, [PsyVisName2, ..])
            %
            % Hide PsyVis object(s), already added by Scr.addVis, from next frame.
            %
            % Doesn't issue error when the specified object is not currently
            % shown.
            
            try
                for cVis = varargin
                    if any(me.Vis.(cVis{1}).visible == [me.VISIBLE me.NEWLY_SHOWN])
                        me.Vis.(cVis{1}).visible = me.NEWLY_HIDDEN;
                        me.Vis.offFr(end+1) = me.cFr;
                    end
                end
            catch cErr
                if ~isfield(me.Vis, cVis{1})
                    fprintf('%s unavailable: use Scr.addVis before hiding!\n', ...
                            cVis{1});
                end
                rethrow(cErr);
            end

            me.visOrd.off(varargin{:});
            me.L.visChanged = true; % Log takes place whenever show/hide/change in order is attempted.
        end
        
        
        function updateNDrawAll(me)
            % Scr.updateNDrawAll
            %
            % : updates and draws all PsyVis objects that are 
            %   listed on Scr.visOrd, in the list's order.
            
            for cVis = me.visOrd.cell
                me.Vis.(cVis{1}).update;
                me.Vis.(cVis{1}).draw;
            end
        end
        
        
        function updateAll(me)
            % Scr.updateAll
            %
            % : updates all PsyVis objects that are 
            %   listed on Scr.visOrd, in the list's order.
            
            for cVis = me.visOrd.cell
                me.Vis.(cVis{1}).update;
            end
        end
        
        
        function drawAll(me)
            % Scr.drawAll
            %
            % : draws all PsyVis objects that are 
            %   listed on Scr.visOrd, in the list's order.
            
            for cVis = me.visOrd.cell
                me.Vis.(cVis{1}).draw;
            end
        end
        
        
        function addVis(me, obj)
            % Scr.addVis(PsyVis_object)
            %
            % : adds one PsyVis object as a field of me.Vis.
            %   PsyVis.name will be the field's name, so it should differ from
            %   those already added, or the existing one will be overwritten.
            %   Refer to any object added to Scr as Scr.Vis.(obj_name).
            
            me.Vis.(obj.name) = obj;
            me.visOrdLog.nVis = length(fieldnames(me.visOrdLog.nVis));
        end
        
        
        function delVis(me, objName)
            % Scr.delVis(objName)
            
            me.Vis = rmfield(me.Vis, objName);
            me.visOrdLog.nVis = length(fieldnames(me.visOrdLog.nVis));
        end
        
        
        function delVisAll(me)
            % Scr.delVisAll;
            
            me.Vis = struct;
            me.visOrdLog.nVis = 0;
        end
        
        
        %% Waiting & Timing
        
        [frOnset, cFr] = wait(mode, funcNArgs, sched, immediateFinish, flipArgs)
        
        
        %% Coordinate transformation
        
        s = deg2screen(d, format);
        d = screen2deg(s, format);
    end
    
    
    methods (Static)
        %% Copying
        
        function obj2 = copyobj(obj)
            obj2 = struct2obj(PsyScr, obj);
        end
        
        
        %% Coordinate transformation -- Rect
        
        sRect = rectAround(sRectCenter, sRectSize);
        dRect = rectAroundDeg(dRectCenter, dRectSize);
    end
end