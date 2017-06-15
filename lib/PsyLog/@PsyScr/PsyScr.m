classdef PsyScr < PsyLogs
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
    %         Scr.initLog; % init Log every trial.
    %         ...
    %         Scr.markEpoch('epochName1');
    %         ...
    %         Scr.closeLog; % optionally, mark the end of the trial.
    %         save(fileName, 'Scr'); % Save the Log of the trial.
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
    %         Scr.initLog(maxSec); % Init Log every trial. 
    %                              % Also initializes all PsyVis/Aud/Inp/Read objects' Log
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
    %         save(fileName, 'Scr'); % Save the Log of the trial.
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
    %     initLog   - Initializes timestamp & PsyVis Log for each trial.
    %     closeLog  - Marks trial end timestamp.
    %     flip      - Performes Screen('Flip') and logs onset timing & PsyVis order.
    %     
    %
    % 2012-2014 (c) Yul Kang. hk2699 at columbia dot edu

    properties
        Scr; % link to itself.
        
        %% Timing
        cFr         = 1;   % current frame.
        frOnAbsSec  = nan;
        frOnPredAbsSec = nan;
        startAt     = nan; % desired start time.
        
        %% PTB interface: capsulized in a struct to ease copying.
        % info: See PsyScr.default_info for more information.
        info = PsyScr.default_info;
        
%         % pref_scr_global: Passed to Screen('Preference', name, val)
%         % Defaults:
%         % 'SkipSyncTests',    0
%         % 'TextRenderer',     0
%         pref_scr_global = varargin2S({}, {
%             'SkipSyncTests',    0
%             'TextRenderer',     0
%             });
    
        %% For the semi-mirror mode
        % win(k): handle(s) of the k-th window.
        % Any windows from 2nd are drawn opportunistically.
        win = []; 
        
        % info_win(k): Information about the k-th window.
        info_win = struct; 
        
        % vis_in_win(k) = .(vis_obj) = true if vis_obj appears in the k-th window.
        vis_in_win = struct; 
        
        %% For opportunistic processing between flips
        % Cell array of function handles. 
        % Always evaluated in order, even when interrupted. 
        % (e.g., 1->2->(interruption)->3->1->2-> ...)
        % Interrupted when the previous flip of the primary screen is done,
        % at which updateBefFlip for the primary screen begins.
        % Resumes after the async_flip begins for the primary screen.
        f_oppor = {@() false}; 
        c_oppor = 1;
        t_thres_f_oppor = 0.01; % Require 7ms before next flip to process f_oppor
        
        %% Interface to children objects in general
        % .c: Scalar struct with fields of children objects.
        % PsyVis    % Appears on screen.    Logged with onFr, offFr, and v.
        % PsyAud    % Sound played.         Logged with onAbsSec.
        % PsyInp    % Input.                Logged with onAbsSec & v.
        % PsyRead   % Interpreted from Inp. Logged with onAbsSec & v.
        % PsyEpoch  % Schedules.            Logged with on/offFr.
        c           = struct;
        
        % cell array of tags of all children, according to class:
        % e.g. cNames.Vis = {'visObj1', 'visObj2', ...}.
        cTags       = struct; 
        
        % List of PsyXXX (abstract) classes whose (sub)class objects can be
        % children of Scr via Scr.addObj().
        kindList = {'Vis', 'Aud', 'Inp'};
        
        %% Interface to PsyVis objects
        visOrd      = []; % visOrd(k): the order number where the Vis object
                          %            whose name is Scr.cTag.Vis{k}
                          %            will be drawn.

        %% Objects to check on events.
        %  updateOn.(eventName) = {'objName1', 'objName2', ...}
        updateOn    = struct;
        
        %% Trial related
        trial = []; % (optional). Contains paramters for random distribution.

        saveOpt = struct('fileName', 'trial_', ...
                         'pathPostfix', '', ...
                         'filePostfix', '', ...
                         'path', '.', ...
                         'timestamp', nan, ... % trial onset
                         'runSt', nan, ... % run onset (run > trial).
                         'useGit', false, ...
                         'GitOpt', struct( ...
                            'askOverwriting', false, ... % Trial.mat should be overwritten on every trial, 
                            ...                         % so turn off askOverwriting.
                            'diaryOnConstruct', true ...
                            ) ...
                         );
        finishTrialOpt = struct('next', {{'after', 1}});
        
        useGit = false;
        Git = [];
        
        opened = false;
        debugMode = false;
    end
        
    properties (Dependent)
        % verdict.('epoch_on'|'epoch_pass'|'epoch_done') = relSec
        % epoch_on   : when the epoch began
        % epoch_pass : when the epoch ended without untilFun satisfied
        % epoch_done : when the epoch ended with untilFun satisfied
        verdict
        n_oppor
    end    
    
    properties (Constant)
        default_info = varargin2S({}, {
            'scr',          [] % physical screen
            'win',          [] % handle to window
            'rect',         [] % size of the window
            'widthCm',      [] % physical width of the screen showing area.
            'distCm',       [] % physical distance from the eye to the screen.
            'halfSizeDeg',  [] % size in degree.
            'refreshRate',  [] % real or asserted refresh rate.
            'pixPerDeg',    [] % pixel per degree. Assumed constant but not really when the screen is big or close enough.
            'centerPix',    [] % center position in pixel.
            'bkgColor',     [] % background color
            'constPixPerDeg', true % treat pixPerDeg constant throughout a display. False unsupported now.
            'maxSec',       5 % maximum time per trial. Used to initialize logs.
            'hideCursor',   true % Hide cursor on open.
            'priority',     []
            'prevPriority', []
            'skipSyncTests', false
            'win_ord'       1 % 1: Primary window, 2: First secondary window
            'argin',        {}
        }); %        
    end
    
    properties (Transient)
        hax % for plot()
    end
    
    methods
        %% Initialization & logging
        function me = PsyScr(varargin)
        % Scr = PsyScr;
        %
        % : Assigns an empty PsyScr struct for later use.
        %   No argument syntax supported for uncomplicated saving & loading.
        %
        % Scr = PsyScr('propName1', prop1, ...);
        %
        % : Equivalent to Scr = PsyScr; Scr.init('propName1', prop1, ...);
            
            %% PsyDeepCopy interface
            me.Scr = me; % link to itself.
            
            me.rootName     = 'Scr';
            me.parentName   = 'Scr';
            me.tag          = 'Scr';
            me.deepCpNames  = {'Git'};
            me.deepCpStructNames = {'c'};
            
            %% Logging
            me.initLogEntries('mark', ...
                             {'st_waiting', 'st', 'en', 'frOn', 'beginDraw', 'finishDraw'}, 'absSec'); % DEBUG - befDraw
            me.initLogEntries('valCell', {'verdict'}, 'absSec', {blanks(20)}, 20); 
            me.initLogEntries('prop1', {'visOrd'}, 'fr', nan);
            
            %% Initialize me.updateOn
            me.updateOn.befDraw = {};

            %% Initialize me.saveOpt
            % when called by ABC/DEF.m, the default path is:
            %
            % ABC/DEF/DEF_(index).(ext)
            
            me.initSaveOpt;
            
            %% Initialize me.info
            if nargin>0, me.init(varargin{:}); end
            
            %% Others
            me.cTags.Inp = {};
        end
        
        function initOpt(me, optName, varargin)
            % INITOPT   Specify options.
            %
            % Scr.initOpt(optName, 'option1', option1, ...)
            %
            % optName   : 'saveOpt' or 'finishTrialOpt'.
            %
            % options - saveOpt
            %   pathPostfix     : string.
            %   filePostfix     : string.
            %
            % options - finishTrialOpt (also specify with finishTrial().)
            %   next            struct('after', 1) % in sec
            
            me.(optName) = varargin2fields(me.(optName), varargin, false);
        end
        
        function init(me, varargin)
        % Scr.init('propName1', prop1, ...)
        %
        % : Sets multiple properties at once. Code kept minimal for flexibility.
        %   Specify .distCm of your own setup. It defaults to
        %   sensible yet arbitrary values.
        %
        %   Set win_ord > 1 to intialize secondary windows.
        
            c_info = varargin2S(varargin, PsyScr.default_info);
            
            %% Screen, rect
            if isempty(c_info.scr)
                c_info.scr = max(Screen('Screens'));
                disp('Scr.info.scr is unset!  Will be set to the last screen detected.');
            end
            
            if isempty(c_info.rect)
                c_info.rect = reshape(Screen('Rect', c_info.scr), [], 1);
                fprintf('Setting to detected screen rect:'); 
                fprintf(' %d', c_info.rect); fprintf('\n');
            end
            
            c_info.centerPix = [sum(c_info.rect([1 3]) / 2), sum(c_info.rect([2 4])) / 2];
            
            %% Physical size
            if isempty(c_info.distCm)
                c_info.distCm = 55;
                warning(['Scr.info.distCm is unset!  Will be set to an arbitrary value ' ...
                         'of %d cm..'], ...
                         c_info.distCm);
            end
            
            if ~isfield(c_info, 'widthCm') || isempty(c_info.widthCm)
                wCm = Screen('DisplaySize', c_info.scr) / 10;
                fprintf('Detected display width: %d cm\n', wCm);

                if ~isempty(c_info.widthCm) && abs(c_info.widthCm - wCm) > 1
                    warning(['Detected (%d cm) and specified (%d cm) display width ' ...
                             'differs > 1cm!'], ...
                          wCm, c_info.widthCm);
                else
                    c_info.widthCm = wCm;
                end
            end
            
            if ~isempty(c_info.widthCm) && ~isempty(c_info.distCm)
                c_info.pixPerDeg = c_info.rect(3) / ...
                                    (atan(c_info.widthCm / 2 / c_info.distCm) ...
                                             * 2 / pi * 180);
                                         
                c_info.halfSizeDeg = reshape(c_info.rect(3:4) / 2 ...
                                            / c_info.pixPerDeg, ...
                                            [], 1);
            end
            
            %% Refresh rate
            if isempty(c_info.refreshRate)
                c_info.refreshRate = Screen('NominalFrameRate', c_info.scr);
                if c_info.refreshRate == 0
                    c_info.refreshRate = 60; % DEBUG
                end
            end
                        
            %% Background color
            if isempty(c_info.bkgColor)
                c_info.bkgColor = [0 0 0];
                fprintf('Setting background color to:');
                fprintf(' %d', c_info.bkgColor); fprintf('\n');
            end
            
            %% Set to property
            me.info_win = varargin2SArray( ...
                me.info_win, c_info.win_ord, c_info);
            
            if c_info.win_ord == 1 % If primary window
                me.info = c_info;
                
            else % If secondary window
                me.initLogEntries('mark', ...
                    csprintf('%s%d', {'frOn', 'finishDraw'}, c_info.win_ord), ...
                    'absSec');
            end
        end
        
        function open(me, c_win_ord) 
        % Scr.open(win_ord=1);
        %
        % : Defaults to the primary screen.
        
            if nargin < 2, c_win_ord = 1; end
        
            c_info = me.info_win(c_win_ord);
            c_info.priority     = MaxPriority(c_info.scr, 'KbCheck');
            c_info.prevPriority = Priority(c_info.priority);

            % Cursor
            if c_info.hideCursor
                HideCursor();
            end
            
            % Opening
            disp('Scr.info:');
            disp(c_info);
                
            if c_win_ord == 1
                AssertOpenGL;
                Screen('Preference', 'SkipSyncTests', double(c_info.skipSyncTests));
            end
            
            [c_info.win, c_info.rect] = ...
                Screen('OpenWindow', c_info.scr, c_info.bkgColor, c_info.argin{:});
            
            me.opened(c_win_ord) = true;
            me.win(c_win_ord) = c_info.win;
            c_info.rect = reshape(c_info.rect, [], 1);
            
            % Flip once if secondary screen, since AsyncFlipCheckEnd
            % returns 0 if no flip was attempted.
            if c_win_ord > 1
                Screen('Flip', c_info.win);
            end                
            
            % Refresh rate
            rRate = 1 / Screen('GetFlipInterval', c_info.win); % Screen('NominalFrameRate', c_info.scr);
            fprintf('Detected refresh rate: %d Hz\n', rRate);
            
            if ~isempty(c_info.refreshRate) && c_info.refreshRate ~= rRate
                warning(['Detected (%d Hz) and specified (%d Hz) ' ...
                         'refresh rate differ! Using specified rate.'], ...
                        rRate, c_info.refreshRate);
            elseif (~isempty(rRate) && ~isnan(rRate)) && ...
                   (isempty(c_info.refreshRate) || isnan(c_info.refreshRate))
                fprintf('Refresh rate not given. Using detected rate.\n');
                c_info.refreshRate = rRate;
            end
            
            c_info.halfSizeDeg = reshape(c_info.rect(3:4) / 2 ...
                                            / c_info.pixPerDeg, ...
                                            [], 1);
            % Blend function
            Screen('BlendFunction', c_info.win, ...
                    GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                
            % Copy to property
            me.info_win = varargin2SArray(me.info_win, c_win_ord, c_info);
            
            if c_win_ord == 1
                me.info = c_info;
            end
        end
        
        function close(me, c_win_ord)
            
            if nargin < 2
                Screen('CloseAll');
                me.opened = false(size(me.opened));
            else
                for cc_win_ord = c_win_ord
                    Screen('Close', me.win(cc_win_ord));
                    me.opened(c_win_ord) = false;
                end
            end
            
            Priority(me.info_win(1).prevPriority);

            if me.info_win(1).hideCursor
                ShowCursor;
            end
        end
        
        %% Object maintenance: Should occur outside Scr.initLog .. Scr.closeLog block.
        function obj = exchangeObj(me, objName, newObj)
            % oldObj = Scr.exchangeObj('oldObjName', newObj);
            
            prevKind = '';
            
            for ccKind = fieldnames(me.cTags)'
                cKind = ccKind{1};
                
                if any(strcmp(objName, me.cTags.(cKind)))
                    prevKind = cKind;
                    break;
                end
            end
           
            if isempty(prevKind)
                error('prevObj has not been added to Scr yet!');
            else
                me.c.(objName) = newObj;
                obj            = newObj;
            end
        end
        
        function varargout = addObj(me, kind, varargin)
            % Adds objects to Scr.
            % Objects' tags are replaced by the input names.
            %
            % varargout = addObj(me, kind, obj1, [obj2, ...])
            % - kind  : String. One of Scr.kindList.
            %
            % varargout = addObj(me, kind, obj_struct, [{obj_field_name1, ...}])
            % - obj_struct: Struct with fields of objects.
            %
            % varargout = addObj(me, {kind, [win1, ...]}, obj1, [obj2, ...])
            % - win   : Window number to show the object if visible.
            %           1 (primary), 2 (first secondary), ...
            
            varargout = varargin;
            
            % Parse kind & win
            if iscell(kind)
                c_wins = kind{2};
                kind   = kind{1};
            else
                c_wins = 1;
            end
            
            % Check kind
            if ~ischar(kind) || ~any(strcmp(kind, me.kindList))
                fprintf('Kind should be one of:');
                fprintf(' %s', me.kindList{:}); fprintf('\n');
                
                if ischar(kind)
                    error('Unsupported kind: %s\n', kind);
                else
                    error('Unsupported kind!');
                end
            end
            
            if isstruct(varargin{1})
                % Parse struct input
                S_obj   = varargin{1};
                
                if length(varargin) >= 2
                    assert(iscell(varargin{2}), 'Struct should be followed by a cell array of field names, if any!');
                    f_names = varargin{2};
                else
                    f_names = fieldnames(S_obj);
                end
                
                varargin = cell(1, length(f_names));
                
                for ii = 1:length(f_names)
                    varargin{ii} = S_obj.(f_names{ii});
                end
            else
                % Parse inputnames
                f_names = cell(1, length(varargin));
                for ii = 1:length(varargin)
                    f_names{ii} = inputname(ii + 2);
                end
            end
            
            
            
            % Add objects
            for iObj = 1:length(varargin)
                cObj = varargin{iObj};
                
                % Replace tag with inputname, if available.
                %
                % To add an object from an object array or cell array, 
                % (like addObj(... , objects(1)) or addObj(... , objects{1})), 
                % set the tag appropriately before addObj, since inputname
                % is unavailable.
                %
                % To keep the tag different from inputname, 
                % use instance_name(1), but it may cause confusion.
                if ~isempty(f_names{iObj})
                    cObj.tag = f_names{iObj};
                end
                
                % Add cTags
                if ~isfield(me.cTags, kind)
                    me.cTags.(kind) = {};
                end
                
                if ~isfield(me.c, cObj.tag)
                    me.cTags.(kind) = [me.cTags.(kind), {cObj.tag}];
                    
                % Add to visOrd
                    if strcmp(kind, 'Vis')
                        me.visOrd = [me.visOrd, length(me.visOrd)+1];
                    end
                end
                
                % Add to win
                for c_win = c_wins
                    me.vis_in_win(c_win).(cObj.tag) = true;
                end
                
                % Add handle to c
                me.c.(cObj.tag) = cObj;
                
                % Add updateOn
                if strcmp(kind, 'Inp')
                    if ~isfield(me.updateOn, cObj.tag)
                        me.updateOn.(cObj.tag) = {};
                    end
                end
                
                if isprop(cObj, 'updateOn')
                    for cUpdateOn = cObj.updateOn
                        if isfield(me.updateOn, cUpdateOn{1})
                            me.updateOn.(cUpdateOn{1}) = ...
                                union(me.updateOn.(cUpdateOn{1}), {cObj.tag});
                        else
%                             error('Event %s should be registered before adding listener %s!', ...
%                                     cUpdateOn{1}, cObj.tag);
                            me.updateOn.(cUpdateOn{1}) = {cObj.tag};
                        end
                    end
                end
                
                % Make sure its .Scr links back to me.
                cObj.Scr = me;
            end
        end
        
        function deleted = delObj(me, kind, varargin)
            % deleted = delObj(me, kind, obj1, [obj2, ...])
            %
            % Completely deletes children objects of Scr.
            %
            % kind      : String. One of Scr.kindList.
            % deleted   : Boolean vector. True if deletion happened.
            
            if ~strcmp(kind, me.kindList)
                fprintf('Kind should be one of:');
                fprintf(' %s', me.kindList); fprintf('\n');
                error('Unsupported kind: %s\n', kind);
            end
            
            deleted = false(1, length(varargin));
            
            for iObj = 1:length(varargin)
                cWhich          = strcmp(varargin{iObj}, me.cTags.(kind));
                deleted(iObj)   = any(cWhich);
                
                if deleted(iObj)                
                    
                    % Destroy object
                    cTag = me.cTags.(kind){cWhich};
                    if isa(me.c.(cTag), 'PsyDeepCopy')
                        delTree(me.c.(cTag));
                    else
                        delete(me.c.(cTag));
                    end
                       
                    % Manage me.c
                    me.c = rmfield(me.c, cTag{1});
                    
                    % Manage me.cTags.(kind)
                    me.cTags.(kind) = me.cTags.(kind)(~cWhich);
                end
            end
        end
        
        %% PsyLogs interface
        function initLogTrial(me)
            % Initialize reference tree, 
            % Run initLogTrial for self and children,
            % Start at designated time and record it,
            % Get the first flip timestamp.
            
            me.toLog = true;
            
            me.cFr = 1;
            maxNFr = ceil(me.info.maxSec * me.info.refreshRate);
            
            % Initialize primary screen's maxN
            setFields(me, 'maxN_', {'frOn', 'beginDraw', 'finishDraw'}, maxNFr); % DEBUG - beginDraw
            
            % Initialize secondary screens
            for i_win_ord = 2:length(me.win)
                setFields(me, 'maxN_', csprintf('%s%d', {'frOn', 'beginDraw', 'finishDraw'}, i_win_ord), maxNFr); % DEBUG - beginDraw
            end
            
            initSecondaryScr(me);
            
            % Initialze reference tree.
            initTree(me);
            
            % Initialize Log of Scr itself
            initLogTrial@PsyLogs(me);
           
            % Run initLogTrial() for every child.
            if ~isempty(me.c)
                for cChild = fieldnames(me.c)'
                    initLogTrial(me.c.(cChild{1}));
                end
            end
            
            % Wait if required
            waitTrialStart(me);
        end
        
        function waitTrialStart(me)
            if ~isnan(me.startAt)
                % Trial start waiting timestamp
                addLog1(me, 'st_waiting', GetSecs);
                
                if me.startAt > GetSecs
                    % Trial start timestamp is set to startAt, 
                    % because we can wait until startAt.
                    addLog1(me, 'st', me.startAt);
                    
                    % Use Scr.wait to allow for input logging, etc.
%                     wait(me, @() false, 'until', me.startAt);
                    WaitSecs('UntilTime', me.startAt); % Doesn't allow input logging.
                else
                    % Trial start timestamp is set to current time.
                    addLog1(me, 'st', GetSecs);
                end
                
                fprintf('Trial onset discrepancy from planned time: %2.1f msec\n', ...
                    (me.t_.st - me.startAt) * 1000);
                
                me.startAt = nan;
            else
                % Trial start timestamp
                addLog(me, {'st_waiting', 'st'}, GetSecs);
            end
            
            % Get the first flip timestamp, and boot up Screen subfunctions.
            if isnan(me.frOnAbsSec) 
                try
                    [~, me.frOnAbsSec] = Screen('Flip', me.info.win, 0, 1);
                catch lastErr
                    if me.debugMode
                        warning('Initial flip unsuccessful!');
                        me.frOnAbsSec = GetSecs;
                    else
                        rethrow(lastErr);
                    end
                end
            end
        end
        
        function [obj_err, err_closeLog] = closeLog(me, closeLogAll)
            % Scr.closeLog
            %
            % Marks trial end timestamp.
            
            if nargin<2, closeLogAll = true; end
                
            addLog1(me, 'en', GetSecs);
            
            if closeLogAll
                n_err = 0;
                obj_err = cell(1,10);
                err_closeLog = cell(1,10);
                
                for cChild = fieldnames(me.c)'
                    try
                        closeLog(me.c.(cChild{1}));
                        
                    catch c_err_closeLog
                        n_err = n_err + 1;
                        obj_err{n_err} = cChild{1};
                        err_closeLog{n_err} = c_err_closeLog;
                    end
                end
                err_closeLog((n_err+1):end) = [];
                obj_err((n_err+1):end) = [];
            
                if n_err > 0
                    fprintf('Object(s) without working closeLog:');
                    cfprintf(' %s', obj_err);
                    fprintf('\n');
                end
            else
                obj_err = {};
                err_closeLog = {};
            end
            
            % Set toLog=false.
            me.closeLog@PsyLogs;
        end
        
        %% PsyVis interface
        function show(me, varargin)
            % Scr.show(Obj1, Obj2,...)
            % Scr.show('all');
            
            if ischar(varargin{1}) && strcmp(varargin{1}, 'all')
                for cObjName = me.cTags.Vis
                    show(me.c.(cObjName{1}));
                end
            else
                for ii = 1:length(varargin)
                    show(varargin{ii});
                end
            end
        end
        
        function hide(me, varargin)
            % Scr.hide(Obj1, Obj2,...)
            % Scr.hide('all');
            
            if ischar(varargin{1}) && strcmp(varargin{1}, 'all')
                for cObjName = me.cTags.Vis
                    hide(me.c.(cObjName{1}));
                end
            else
                for ii = 1:length(varargin)
                    hide(varargin{ii});
                end
            end
        end
        
        function moveVisObj(me, varargin)
            % Should happen only once in a frame. 
            % Don't use moveAbove or moveBelow. They won't log the change!
            
            for ii = 1:3:length(varargin)
                switch varargin{ii+1}
                    case 'above'
                        moveAbove(me, varargin{ii}, varargin{ii+2});
                        
                    case 'below'
                        moveBelow(me, varargin{ii}, varargin{ii+2});
                end
            end
            
            addLog1(me, 'visOrd', me.cFr);
        end
        
        function moveAbove(me, objToMove, aboveObj)
            % moveAbove(me, objToMove, aboveObj)
            
            prevOrd = me.visOrd;
            
            pOrd = prevOrd( strfind(objToMove, fieldnames(me.Vis)) );
            nOrd = prevOrd( strfind(aboveObj , fieldnames(me.Vis)) );
            
            if nOrd < pOrd
                me.visOrd = prevOrd + ((prevOrd < pOrd) & (prevOrd >= nOrd));
                
            elseif nOrd > pOrd
                me.visORd = prevOrd - ((prevOrd > pOrd) & (prevOrd <= nOrd));
                
            end 
            me.visOrd(prevOrd == pOrd) = nOrd;
        end
        
        function moveBelow(me, objToMove, belowObj)
            % moveBelow(me, objToMove, belowObj)
            
            prevOrd = me.visOrd;
            
            pOrd = prevOrd( strfind(objToMove, fieldnames(me.Vis)) );
            nOrd = prevOrd( strfind(belowObj , fieldnames(me.Vis)) ) + 1;
            
            if nOrd < pOrd
                me.visOrd = prevOrd + ((prevOrd < pOrd) & (prevOrd >= nOrd));
                
            elseif nOrd > pOrd
                me.visORd = prevOrd - ((prevOrd > pOrd) & (prevOrd <= nOrd));
                
            end 
            me.visOrd(prevOrd == pOrd) = nOrd;
        end
        
        %% Waiting & Timing
        function wait(me, epochName, untilFun, forOrUntil, t, frOrSec)
            % wait(me, epochName, untilFun, forOrUntil, t, frOrSec)
            %
            % wait(me, untilFun, args, 'for',   t, 'fr')
            % wait(me, untilFun, args, 'for',   t, 'sec')
            % wait(me, untilFun, args, 'until', t, 'fr')
            % wait(me, untilFun, args, 'until', t, 'sec')
            %
            % me.v_.verdict (a cell array) will have 
            %  'epochName_on' when wait() is called,
            %  'epochName_done' when wait finished because untilFun is satisfied,
            %  'epochName_pass' when wait finished because time passed 
            %                   (without untilFun being satisfied.)
            %
            % See also: updateBefFlip, checkInp, flip_async_begin, flip_async_end, flip
            
            % Add rough epoch onset timestamp
            addLog1(me, 'verdict', GetSecs, [epochName '_on']);
            
            % Input handling
            if ~exist('epochName', 'var'), epochName = 'wait'; end
            if ~exist('untilFun', 'var'), untilFun = @() false; end
            if ~exist('forOrUntil', 'var'), forOrUntil = 'for'; end
            if ~exist('t', 'var'), t = 1; end
            if ~exist('frOrSec', 'var'), frOrSec = 'sec'; end
            
            % Parse time
            switch forOrUntil
                case 'for'
                    switch frOrSec
                        case 'fr'
                            t       = me.cFr + t;
                            timeFun = @(obj) obj.cFr < t;
                            
                        case 'sec'
                            % match nearest predictable last frame onset to t.
                            t       = GetSecs + t - 0.5/me.info.refreshRate; % me.frOnAbsSec + t - 0.5/me.info.refreshRate;
                            
                            timeFun = @(obj) obj.frOnAbsSec < t;
                    end
                case 'until'
                    switch frOrSec
                        case 'fr'
                            timeFun = @(obj) obj.cFr < t;
                            
                        case 'sec'
                            % match nearest predictable last frame onset to t.
                            t       = t - 0.5/me.info.refreshRate;
                            timeFun = @(obj) obj.frOnAbsSec < t ;
                    end
            end
            
            % Loop until time passes or the condition is met.
            while ~untilFun()
                
                % If time passed without satisfying the condition
                if ~timeFun(me)
                    addLog1(me, 'verdict', me.frOnAbsSec, ...
                          [epochName '_pass']);
                    return;
                end
                
                addLog1(me, 'beginDraw', GetSecs);
                
                % Scheduled change in Inp and Vis.
                updateBefFlip(me);

%                 % Just flip. Async flip may cause dropped frames.
%                 flip(me);
%                 
                % Attempt Flip
                flip_async_begin(me);
                
                % Do opportunistic processing until flip completes & Log flip.
                flip_async_end(me);
            end
            
%             flip_async_ensure_finished(me, 1); % DEBUG
            
            % If the condition was satisfied
            addLog1(me, 'verdict', me.frOnAbsSec, ...
                       [epochName '_done']);
        end
        
        function updateBefFlip(me)
            % Update Inp and Vis before flip
            
            prevFrOnAbsSec     = me.frOnAbsSec;
            predNextFrOnAbsSec = me.frOnPredAbsSec;

            % High or low frequency sampling of Inp
            for cInp = me.cTags.Inp

                ccInp = me.c.(cInp{1});

                if (prevFrOnAbsSec < ccInp.highFreqAtAbsSec) && ...
                   (ccInp.highFreqAtAbsSec <= predNextFrOnAbsSec)

                    ccInp.freq = ccInp.highFreq;
                end
                if (prevFrOnAbsSec < ccInp.lowFreqAtAbsSec) && ...
                   (ccInp.lowFreqAtAbsSec <= predNextFrOnAbsSec)

                    ccInp.freq = ccInp.lowFreq;
                end
            end

            % Show or hide
            for cVis = me.cTags.Vis

                ccVis = me.c.(cVis{1});

                if (predNextFrOnAbsSec >= ccVis.showAtAbsSec) && ...
                   ~(predNextFrOnAbsSec >= ccVis.hideAtAbsSec) && ... % To deal with hideAtAbsSec == NaN
                        ~ccVis.visible && ~ccVis.shownAtAbsSec

                   show(ccVis);
                   ccVis.shownAtAbsSec = true;
                end

                if (ccVis.hideAtAbsSec <= predNextFrOnAbsSec) && ...
                       ccVis.visible && ~ccVis.hiddenAtAbsSec

                   hide(ccVis);
                   ccVis.hiddenAtAbsSec = true;
                end

                % Update visual objects
                %  Update only happens after flip finishes.
                %  Otherwise, updated object may end up not being presented.
                %  If it doesn't matter, updating BETWEEN flip attempt & finish
                %  can allow extra time for updating & drawing.

                if ccVis.visible && any(strcmp('befDraw', ccVis.updateOn))
                    update(ccVis, 'befDraw');
                end

                checkInp(me); % Call after every time-consuming procedure
            end            

            % Draw
            [~, cVisOrd] = sort(me.visOrd);

            c_vis_in_win = me.vis_in_win(1);
            cc           = me.c;
            
            for cVis = me.cTags.Vis(cVisOrd)
                
                % Draw only if cVis belongs to the primary window.
                if ~isequal(c_vis_in_win.(cVis{1}), true), continue; end
                
                ccVis = cc.(cVis{1});

                % Draw only if visible
                if ccVis.visible
                    draw(ccVis);

                    checkInp(me); % Call after every time-consuming procedure
                end
            end
            
            % Opportunistic processing
            deadline_f_oppor = predNextFrOnAbsSec - me.t_thres_f_oppor;
            c_n_oppor = me.n_oppor;
                
            if c_n_oppor > 0 && GetSecs < deadline_f_oppor
                c_f_oppor = me.f_oppor;
                cc_oppor  = me.c_oppor;
                
                cc_oppor_beginning = cc_oppor;
                
                while GetSecs < deadline_f_oppor
                    % Perform opportunistic functions.
                    if c_f_oppor{cc_oppor}()
                        % Proceed to the next one only when succeed.
                        cc_oppor = mod(cc_oppor, c_n_oppor) + 1;
                        
                        % Process one cycle only
                        if cc_oppor == cc_oppor_beginning, break; end
                    end
                    
                    checkInp(me);
                end
            end
        end
        
        function checkInp(me)
            % CHECKINP  Get input with frequency of each.
            %
            % Check if Inp.active==true,
            % with frequencey of Inp.freq.
            %
            % Inp should be added with Scr.addObj('Inp', ...)
            %
            % Will call .update() in other objects listed in
            % Scr.updateOn.(Inp). Objects are added to this list
            % if they have a property .updateOn = {Inp1, Inp2, ...},
            % when they are added with Scr.addObj().
            %
            % Currently, PsyInp superclasses Mouse, Key, and Eye.
            
            cc      = me.c;
            
            for cInp = me.cTags.Inp
                ccInp = cc.(cInp{1});
                cFreq = ccInp.freq;
                
                % Whether to sample is determined by the time interval
                % the current absolute second is in, rather than 
                % the amount of time passed from the last sample, 
                % to prevent accumulation of error.
                %
                % Note that freq = 0 will always falsify the condition,
                % and will disable checking input.
                if  ccInp.active && ...
                    (floor(ccInp.sampledAbsSec * cFreq) < ...
                     floor(GetSecs * cFreq))
                
                    get(ccInp);
                    
                    % Update (listener) objects.
                    for cObj = me.updateOn.(cInp{1});
                        update(cc.(cObj{1}), cInp{1});
                    end
                end
            end
        end
        
        function pFrOnAbsSec = flip_async_begin(me, ~, c_win_ord, varargin)
            % pFrOnAbsSec = flip_async_begin(me, skip_if_prev_unfinished, c_win, varargin)
            %
            % pFrOnAbsSec : 0 if previous flip is unfinished.
            %
            % See also: flip_async_end, flip, wait
            
            if nargin < 3
                c_win_ord = 1;
                c_win = me.info.win; 
            else
                c_win = me.win(c_win_ord);
            end
            
%             % Legacy. Maybe unncessary
%             if (nargin >= 2) && skip_if_prev_unfinished ...
%                     && (Screen('AsyncFlipCheckEnd', c_win) == 0)
%                 
%                 pFrOnAbsSec = 0;
%                 return;
%             end
            
            % Begin asyncFlip
            pFrOnAbsSec = Screen('AsyncFlipBegin', c_win, varargin{:});
            
            % Log
            if c_win_ord == 1
                addLog1(me, 'finishDraw', GetSecs);
            else
                addLog1(me, sprintf('finishDraw%d', c_win_ord), GetSecs);
            end
        end
        
        function [finished, cFrOnAbsSec] = flip_async_is_finished(me, c_win_ord)
            % [finished, cFrOnAbsSec] = flip_async_is_finished(me, c_win_ord = 1)
            
            if nargin < 2, c_win = me.info.win; else c_win = me.win(c_win_ord); end
            
            [finished, cFrOnAbsSec] = Screen('AsyncFlipCheckEnd', c_win);
            
            if finished
                if c_win_ord == 1
                    addLog1(me, 'frOn', cFrOnAbsSec);
                else
                    addLog1(me, sprintf('frOn%d', c_win_ord), cFrOnAbsSec);
                end
            end
        end
        
        function varargout = flip_async_ensure_finished(me, c_win_ord)
            % [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = ...
            %   flip_async_ensure_finished(me, c_win_ord = 1)
            
            if nargin < 2
                [varargout{1:nargout}] = Screen('AsyncFlipEnd', me.info.win);
            else
                [varargout{1:nargout}] = Screen('AsyncFlipEnd', me.win(c_win_ord));
            end
        end
           
        function cFrOnAbsSec = flip_async_end(me)
            % flip_async_end  Used by primary window only.
            %
            % cFrOnAbsSec = flip_async_end(me)
            
            me.cFr = me.cFr + 1;
            
            finished = 0;
            
            while finished == 0
                [finished, cFrOnAbsSec] = flip_async_is_finished(me, 1);                
                checkInp(me);
            end

            me.frOnAbsSec = cFrOnAbsSec;
            me.frOnPredAbsSec = cFrOnAbsSec + 1 / me.info.refreshRate;
        end
        
        function [cFrOnAbsSec, cFr] = flip(me) % , varargin)
            % [cFrOnAbsSec, cFr] = Scr.flip(...)
            %
            % : Wrapper for Screen('flip').
            %   Also logs frame onset and visual objects' order (if they exist).
            
            [~, cFrOnAbsSec] = Screen('Flip', me.info.win); % , varargin{:});
            
            me.frOnAbsSec = cFrOnAbsSec;
            me.frOnPredAbsSec = cFrOnAbsSec + 1 / me.info.refreshRate;
            
            addLog1(me, 'frOn', cFrOnAbsSec);
            
            me.cFr = me.cFr + 1;
            cFr = me.cFr;
        end
        
        %% Secondary screens
        function initSecondaryScr(me)
            % Call from initLogTrial, since that is when all addObj is 
            % finished.
            
            wins  = me.win;
            n_win = length(wins);
            
            if n_win < 2, return; end
            
            cc = me.c;
            
            me.f_oppor = {};
            me.c_oppor = 1;
            
            n_oppor = 0;
            
            c_vis_in_win = me.vis_in_win;
            
            for i_win = 2:n_win
                
                % If no objects are added, break.
                if length(c_vis_in_win) < i_win
                    break;
                end
                
                n_oppor_c_win = 0;
                
                for cVis = me.cTags.Vis
                    % If visible in i_win,
                    if isequal(c_vis_in_win(i_win).(cVis{1}), true)
                        ccVis = cc.(cVis{1});
                        
                        n_oppor_c_win = n_oppor_c_win + 1;
                        
                        % Ensure async flip is finished before drawing.
                        % Being prudent here. May better do it after drawing.
                        if n_oppor_c_win == 1
                            n_oppor = n_oppor + 1;
                            me.f_oppor{n_oppor} = @() flip_async_is_finished(me, i_win);
                        end
                        
                        % Draw objects
                        n_oppor       = n_oppor + 1;
                        me.f_oppor{n_oppor} = @() draw( ccVis, wins(i_win) );
                    end
                end
                
                if n_oppor_c_win > 0
%                     % If concurrent drawing and flipping is not a problem for the given system,
%                     n_oppor = n_oppor + 1;
%                     me.f_oppor{n_oppor} = @() flip_async_is_finished(me, wins(i_win));
                    
                    % Flip
                    n_oppor = n_oppor + 1;
                    me.f_oppor{n_oppor} = @() flip_async_begin(me, true, i_win);
                end
            end
        end
        
        %% Trial related
        function initGit(me, subjName, dep_paths, varargin)
            % initGit(me, subjName, {dep_paths}, 'GitOpt1', GitOpt1, ...)
            
            me.saveOpt.GitOpt = varargin2S(varargin, me.saveOpt.GitOpt);
            varargin = [{dep_paths(:)'}, S2C(me.saveOpt.GitOpt), ...
                        {'subjName', subjName}];
            
            me.useGit = true;
            
            me.Git = PsyGit(varargin{:});            
            
            me.initSaveTimeStamp(me.Git.opt.timeStamp);
        end
        
        
        function initSaveOpt(me, varargin)
            % Scr.initSaveOpt('saveOpt1', saveOpt1, ...)
            %
            % To use Git, use initGit() instead of this.
            
            me.saveOpt = varargin2fields(me.saveOpt, varargin, false);
            
            [me.saveOpt.path, me.saveOpt.fileName] = fileparts(baseCaller);
            if isempty(me.saveOpt.fileName)
                me.saveOpt.path     = ...
                    fullfile('testTrial', me.saveOpt.pathPostfix);

                me.saveOpt.fileName = 'testTrial_'; 
            else
                me.saveOpt.path     = fullfile(me.saveOpt.path, ...
                                              [me.saveOpt.fileName ...
                                               me.saveOpt.pathPostfix]);
                me.saveOpt.fileName = [me.saveOpt.fileName ...
                                       me.saveOpt.filePostfix '_'];
            end
            
            me.initSaveTimeStamp;
        end
    
    
        function initSaveTimeStamp(me, timeStamp)
            if ~exist('timeStamp', 'var')
                timeStamp = now;
            end
            
            if isnan(me.saveOpt.runSt)
                me.saveOpt.runSt = timeStamp;
                me.saveOpt.timestamp = me.saveOpt.runSt;
            else
                me.saveOpt.timestamp = timeStamp;
            end            
        end
        
        function pth = savePathFull(me, varargin)
            % pth = savePathFull(me, varargin)
            
            if me.useGit
                pth = fullfile(me.Git.nameStr('', '', '', ''), varargin{:}); 
            else
                pth = fullfile(me.saveOpt.path, varargin{:});
            end
        end
        
        function pth = saveFilter(me, subFolder, ext)
            % SAVEFILTER Specify subfolder and filename.
            %
            % pth = saveFilter(me, subFolder, [ext = '*.mat'])
            %
            % subFolder: 'orig' or 'res'
            
            if ~exist('ext', 'var'), ext = '*.mat'; end
            
            if me.useGit
                pth = me.Git.nameStr(subFolder, '', ext, '');
            else
                if isfield(me.saveOpt, 'subFolder') && ...
                        ~strcmpLast(me.saveOpt.path, me.saveOpt.pathPostfix)
                    me.saveOpt.path = replaceFolder(me.saveOpt.path, '');
                end
                
                pth = me.savePathFull(subFolder, [me.saveOpt.fileName, ext]);
            end
        end
                
        function runFileName = runFile(me, subFolder, ext)
            % RUNFILE File name with run onset date and time.
            %
            % A run is from the first call to Scr.initSaveOpt after 
            % the construction of Scr to its destruction.            
            %
            % res  = Scr.trialFile(subFolder, [ext = '.mat'])
            %
            % Example:
            %   Scr.trialFile('orig', '.mat')
            %   Scr.trialFile('res', '_good performance.mat')
            %
            % See also: trialFile, nextFile.
            
            if ~exist('ext', 'var'), ext = '.mat'; end
            
            if me.useGit
                runFileName = me.Git.nameScr('run', subFolder, ext, me.saveOpt.runSt);
            else
                runFileName = me.saveFilter(subFolder, ...
                            [datestr(me.saveOpt.runSt, 'yyyymmddTHHMMSS'), ext]);
            end
        end
        
        function trialFileName = trialFile(me, subFolder, ext)
            % TRIALFILE File name with trial onset date and time.
            %
            % A trial is from Scr.initLogTrial to Scr.closeLog.
            %
            % res  = Scr.trialFile(subFolder, [ext = '.mat'])
            %
            % subFolder argument is intentianally required (no default)
            %           to prevent unintended overwriting of data.
            %           Use 'orig' only if it is really the original data,
            %           and 'res' only if it is the results from
            %           post-experiment analyeis.
            %
            % Example:
            %   Scr.trialFile('orig', '.mat')
            %   Scr.trialFile('res', '_good performance.mat')
            %
            % See also: runFile, nextFile.
            
            if ~exist('ext', 'var'), ext = '.mat'; end
            
            if me.useGit
                trialFileName = me.Git.nameScr('trial', subFolder, ext, me.saveOpt.timestamp);
            else
                trialFileName = me.saveFilter(subFolder, ...
                            [datestr(me.saveOpt.timestamp, 'yyyymmddTHHMMSS'), ext]);
            end
        end
        
        function nextFileName = nextFile(me, varargin)
            % NEXTFILE Alias for trialFile.
            %
            % See also: trialFile.
            
            nextFileName = me.trialFile(varargin{:});
        end
        
        function TrFileName = TrFile(me, subFolder, ext, is_backup)
            % TrFileName = TrFile(me, subFolder, ext='.mat', is_backup=false)
            
            if ~exist('ext', 'var'), ext = '.mat'; end
            if ~exist('is_backup', 'var'), is_backup = false; end
            
            if me.useGit
                if is_backup
                    TrFileName = me.Git.nameScrLog('Tr_bak', subFolder, ext);
                else
                    TrFileName = me.Git.nameScrLog('Tr', subFolder, ext);
                end
            else
                if is_backup
                    TrFileName = me.saveFilter(subFolder, ...
                        ['Trial_' ...
                          datestr(me.saveOpt.runSt, 'yyyymmddTHHMMSS') ext]);
                else
                    TrFileName = me.saveFilter(subFolder, ['Trial' ext]);
                end
            end
        end
        
        function dst = makePath(me, subDir)
            % dst = makePath(me, subDir)
            
            if ~exist('subDir', 'var'), subDir = ''; end
            
            dst = me.savePathFull(subDir);
            
            if ~exist(dst, 'dir')
                mkdir(dst);
            end
        end
        
        function dst = saveDiary(me, comment1, comment2)
            % Start keeping diary.
            % 
            % dst = Scr.saveDiary;

            if me.useGit
                me.Git.diary('on');
            else
                me.makePath('orig');

                if nargin < 2
                    newComment  = '';
                    prevComment = '';

                elseif nargin < 3
                    newComment  = comment1;
                    prevComment = newComment;
                else
                    prevComment = comment1;
                    newComment  = comment2;
                end

                if isempty(prevComment)
                    src = me.runFile('orig', '.txt');
                else
                    src = me.runFile('orig', ['_' prevComment '.txt']);
                end

                if isempty(newComment)
                    dst = me.runFile('orig', '.txt');
                else
                    dst = me.runFile('orig', ['_' newComment '.txt']);
                end

                if exist(src, 'file')
                    if ~strcmp(src, dst)
                        diary off;
                        movefile(src, dst);

                        diary(dst);                
                        fprintf('\nRenamed diary to %s\n\n', dst);
                    else
                        diary(dst);                
                        fprintf('\nKept name of the diary as %s\n\n', dst);
                    end
                else
                    diary(dst);
                    fprintf('\nBegan keeping diary to %s\n\n', dst);
                end
            end
        end
        
        
        function closeDiary(me, postRunComment)
            % closeDiary(me, postRunComment)
            
            if me.useGit
                me.Git.diary('off');
                me.Git.diary('moveToScr', postRunComment);
            else
            end
        end
        
        
        function dst = saveDep(me, comment)
            % Zip the base m-file and all m-files it depends on.
            %
            % dst = Scr.saveDep;
            %
            % Unnecessary when using Scr.Git.

            me.makePath('orig');

            src = baseCaller;
            if nargin < 2 || isempty(comment)
                dst = me.runFile('orig', '.zip');
            else
                dst = me.runFile('orig', ['_' comment '.zip']);
            end

            dep2txt(src, 'zipFile', dst, 'verbose', false);
            fprintf('\nZipped %s and its children to %s\n\n', src, dst);
        end
        
        
        function finishTrial(me, varargin)
            opt = varargin2fields(me.finishTrialOpt, varargin, true);
            
            closeLog(me);
            
            try
                switch opt.next{1}
                    case 'after' % After last frame onset
                        me.startAt = me.frOnAbsSec + opt.next{2};

                    case 'at'
                        me.startAt = opt.next{2};
                        
                    otherwise
                        error('Unknown startAt %s! Give after or at', me.startAt);
                end
            catch c_lasterror
                warning(c_lasterror.message);
                warning('Scr.finishTrialOpt.next not set properly!');
            end
            
            diffOn = diff(me.tTrim('frOn'));
            fprintf('Delayed frame (relSec): ');
            fprintf('%1.3f ', me.relSec('frOn', ...
                find(diffOn > 1.5 / me.info.refreshRate)+1)); ...
                fprintf('\n');
    
            fprintf('Verdicts:\n');
            verdicts = me.vTrim('verdict');
            t_verdicts = me.relSec('verdict');
            
            for ii = 1:length(verdicts)
                fprintf(' %20s (relSec): %6.3f', verdicts{ii}, t_verdicts(ii));
                if mod(ii,2) == 0, fprintf('\n'); end
            end
            
            fprintf('\n');
        end
        
        %% Coordinate transformation
        %  Slow. Incorporate directly into the code where time is critical.
        
        function pixXY = deg2pix(me, degXY)
            pixXY = reshape( ...
                        bsxfun(@plus, ...
                            degXY * me.info.pixPerDeg, ...
                            repmat(me.info.centerPix(:), [size(degXY,1)/2, 1])), ...
                        size(degXY));
        end
        
        function degXY = pix2deg(me, pixXY)
            % degXY = pix2deg(me, pixXY)
            
            degXY = reshape( ...
                        bsxfun(@minus, ...
                            pixXY, repmat(me.info.centerPix(:), [size(pixXY,1)/2, 1])) ...
                        / me.info.pixPerDeg, ...
                        size(pixXY));
        end
        
        function xy_deg = prop2deg(me, xy_prop)
            % xy_prop : 2 x N array
            
            xy_deg = bsxfun(@times, xy_prop - 0.5, me.info.halfSizeDeg(:) * 2);
        end
        
        function xy_prop = deg2prop(me, xy_deg)
            % xy_deg : 2 x N array
            
            xy_prop = bsxfun(@rdivide, xy_deg, me.info.halfSizeDeg * 2) + 0.5;
        end
        
        %% Convenience functions: Frame drop, etc.
        function tf = wasVerdict(me, varargin)
            % tf = wasVerdict(me, verdicts)
            % 
            % tf = strcmps(me.v_.verdict, verdicts);
            
            tf = strcmps(me.v_.verdict, varargin);
        end
        
        function t = tVerdict(me, varargin)
            % t = tVerdict(me, verdicts)
            % 
            % t = strcmps(me.v_.verdict, verdicts);
            
            t = me.t_.verdict(strcmps(me.v_.verdict, varargin));
        end
        
        function [nDropped dropFr dropRelSec dropIFI] ...
                = droppedFr(me, fromRelSec, toRelSec, thres)
        % DROPPEDFR     Report dropped frame within given time interval
        %
        % [nDropped dropFr dropRelSec dropIFI] ...
        %        = droppedFr(fromRelSec, toRelSec, thres)
        %
        % from/toRelSec time interval to seek dropped frames.
        %               Omit or set empty, nan, -inf, or inf to examine all frames.
        %
        % thres         frames that appeared after thres / refreshRate
        %               from previous frame will be reported.
        %
        % nDropped      number of frames dropped
        %
        % dropFr        dropped frames (1 is the first frame in the trial)
        %
        % dropRelSec    onset of the dropped frames
        %
        % dropIFI       interval from previous frame onset
        
            % Input arguments
            if ~exist('thres', 'var'), thres = 1.5; end
            
            % Get frame onsets
            frOn     = me.relSec('frOn');
            
            % If the time window is unspecified
            if nargin < 2 || isempty(fromRelSec) || any(isnan(fromRelSec))
                fromRelSec = frOn(1);
            end
            if nargin < 3 || isempty(toRelSec) || any(isnan(toRelSec))
                toRelSec = frOn(end);
            end    
            
            fromRelSec = fromRelSec(1);
            toRelSec   = toRelSec(1);
            
            % One frame before the first frame to the last frame.
            if fromRelSec <= frOn(1)
                ix_frOn1    = 1;
            else
                ix_frOn1    = find(frOn >= fromRelSec, 1, 'first');
            end
            frOn_1      = frOn(ix_frOn1)-0.0001;
            
            if toRelSec >= frOn(end)
                ix_frOnLast = length(frOn);
            else
                ix_frOnLast = min(find(frOn <= toRelSec, 1, 'last'), length(frOn));
            end
            frOn_last   = frOn(ix_frOnLast)+0.0001;

            % Leave only frames within range.
            frOn     = [frOn_1, hVec(frOn(ix_frOn1:ix_frOnLast)), frOn_last];
            
            % thres is multiplied to hardware interframe interval
            thresSec = thres / me.info.refreshRate;
            
            % Interframe interval
            IFI        = diff(frOn);
            
            % Outputs
            dropFr     = find(IFI > thresSec);
            
            dropRelSec = frOn(dropFr + 1);
            dropIFI    = IFI(dropFr);
            
            if ~isempty(dropFr)
                dropFr     = dropFr + ix_frOn1 - 1;
            end
            
            nDropped   = length(dropFr);
        end
        
        %% Get/Set functions
        function tSt = get.verdict(me)
            try
                tSt = cell2struct(num2cell(me.relSec('verdict')), me.v('verdict'), 2);
            catch
                tSt = struct;
            end    
        end
        
        function v = get.n_oppor(me)
            v = length(me.f_oppor);
        end
    end 
    
    
    methods (Static)
        %% Testing
        me = testSecondaryScr(opt_scr1, opt_scr2, varargin)
        
        %% Coordinate transformation -- Rect
        rectPix = rectAroundPix(rectCenterPix, rectSizePix);
        rectDeg = rectAroundDeg(rectCenterDeg, rectSizeDeg);
    end
end