classdef PsyLogs < PsyDeepCopy
    % A general logging class that logs timestamps, with or without attached
    % values and properties of the parent object.
    %
    % A version meant to
    % (1) superclass the object of logging 
    % (2) use struct rather than cell array, for easy access.
    
    properties
        n_          = struct;
        maxN_       = struct;
        
        t_          = struct;
        v_          = struct;
        
        defaultV_   = struct;
        
        src_        = struct;
        tUnit_      = struct;
        
        toLog       = false;
    end
    
    
    properties (Dependent)
        names_
    end
    
    
    methods
        %% Before each run: Constructor, Init & subfunctions.
        function me = PsyLogs(varargin)
            % Logs = PsyLogs(src, names, tUnit, [defaultV, maxN]);
            %
            % See help PsyLogs/initLogEntries for details.
            
            if nargin > 0
                initLogEntries(me, varargin{:});
            end
        end
        
        
        function initLogEntries(me, src, names, tUnit, defaultV, maxN) %#ok<INUSL>
            % Logs.initLogEntries(src, names, tUnit, [defaultV, maxN])
            %
            % src       : One of:
            %             'val1', 'val2', 'val3', 'valCell',
            %             'mark', 'markFirst', 'markLast'.
            %
            % names     : Row cell vector of strings.
            %             Should be unique within a PsyLogs object.
            %             In case src='prop', the name should match the
            %             property to log from.
            %
            % tUnit     : Row cell vector of 'fr' or 'absSec'.
            %
            % defaultV  : Row cell vector.
            %             In case src='propX', set {} or unspecified to copy 
            %             current property values.
            %
            % maxN      : Row cell vector of numbers. Default = {1}.
            %
            %             When src='markFirst' or 'markLast', 
            %             maxN is enforced to 1.
            %
            %             When src='markVec', maxN is a two element vector,
            %             [maxNSample nMarker].
            %
            % If tUnit, appendDim, defaultV, or maxN has only one element,
            % the value will apply to all names specified.
            %
            % e.g. init(me.log, 'prop', {'visOrd'}, 'fr', {}, 10);
            %
            %
            % init(me, Obj, [...])
            %
            % Obj       : Object to log properties from. Only one object can be
            %             specified.
            %             
            %             I recommend to construct PsyLogs on construction of the 
            %             parent obejct.
            
            if ~exist('names', 'var'),              return; end
            
            if ~exist('defaultV', 'var') || isequal(defaultV, {})
                
                switch src
                    case {'prop1', 'prop2', 'prop3', 'propCell'}
                    
                        for ii = length(names):-1:1
                            
                            defaultV{ii} = me.(names{ii});
                        end
                        
                    otherwise
                        defaultV = {[]};  %#ok<NASGU>
                end
            end
            
            if ~exist('maxN', 'var') || ...
                any(strcmp(src, {'markFirst', 'markLast'})),
            
                maxN = 1; %#ok<NASGU>
            else
                maxN = ceil(maxN); %#ok<NASGU>
            end
                
            n = 0;
            for ccField = {'src', 'tUnit', 'defaultV', 'maxN', 'n'}
                cField = ccField{1};
               
                
                me.([cField '_']) = copyFields(me.([cField '_']), ...
                                        cell2struct(cellVec(length(names), ...
                                                            eval(cField) ), ...
                                                    names, 2));
            end
        end
        
        
        function initTimeEntries(me, names, maxN)
            if ~exist('maxN', 'var'), maxN = 1; end
            
            maxN = ceil(maxN);
            
            for ii = 1:length(names)
                me.t_.(names{ii}) = nan(1, maxN(ii));
            end
        end
        
        
        %% Before each trial: InitLogTrial & subfunctions.
        function initLogTrial(me, varargin)
            % initLogTrial(me)
            %
            % Allocate memory & give default values.
            
            if isempty(varargin),
                cNames = me.names_; 
            else 
                cNames = varargin;
            end

            if ~isempty(cNames)
                for ccName = cNames
                    cName  = ccName{1};

                    me.initLogTrialEntry(cName);
                end
            end
            
            me.toLog = true;
        end
        
        
        function initLogTrialEntry(me, cName)
            
            me.n_.(cName) = 0;
            me.t_.(cName) = nan(1, me.maxN_.(cName));

            switch me.src_.(cName)
                case {'val1', 'prop1'}
                    me.v_.(cName) = repmat(me.defaultV_.(cName), ...
                                           [me.maxN_.(cName) 1]);

                case {'val2', 'prop2'}
                    me.v_.(cName) = repmat(me.defaultV_.(cName), ...
                                           [1 me.maxN_.(cName)]);

                case {'val3', 'prop3'}
                    me.v_.(cName) = repmat(me.defaultV_.(cName), ...
                                           [1 1 me.maxN_.(cName)]);

                case {'valCell', 'propCell'}
                    me.v_.(cName) = cell(1, me.maxN_.(cName));

                    % Fill with the same default value.
                    [me.v_.(cName){:}] = deal(me.defaultV_.(cName));
            end
        end
        
                
        %% During the trial: Add/Del.
        function addLog(me, names, t, vs)
            % ADDLOG  Adds log according to the value type.
            %
            % addLog(me, names, t, vs)
            %
            % names & vs: cell arrays.
            %
            % See also: ADDLOG1, ADDTIME, ADDTIME1.
            
            % Logs only when toLog is true.
            if ~me.toLog, return; end
            
            ixSamp = 1:length(t);
            
            for ii = 1:length(names)
                name = names{ii};
                
                switch me.src_.(name)
                    % case 'mark'    % Do nothing but recording t.
                        
                    case 'markFirst' % Record only the first t.
                        if isnan(me.t_.(name))
                            me.n_.(name)    = 1;
                            me.t_.(name)    = t(1); 
                        end
                        
                    case 'markLast'  % Record only the last t.
                        me.n_.(name)        = 1;
                        me.t_.(name)        = t(end);
                        
                    otherwise
                        
                        cN                  = me.n_.(name) + ixSamp;
                        me.n_.(name)        = cN(end);
                        me.t_.(name)(cN)    = t;
                        
                        switch me.src_.(name)
                            case 'val1'
                                me.v_.(name)(cN,:)  = vs{ii};

                            case 'val2'
                                me.v_.(name)(:,cN)  = vs{ii};

                            case 'val3'
                                me.v_.(name)(:,:,cN) = vs{ii};

                            case 'valCell'
                                me.v_.(name){cN}    = vs{ii};

                            case 'prop1'
                                me.v_.(name)(cN,:)  = me.(name);

                            case 'prop2'
                                me.v_.(name)(:,cN)  = me.(name);

                            case 'prop3'
                                me.v_.(name)(:,:,cN) = me.(name);

                            case 'propCell'
                                me.v_.(name){cN}    = me.(name);
                        end
                end
            end
        end
        
        
        function addLog1(me, name, t, v)
            % ADDLOG1  Adds one log according to the value type.
            %
            % addLog1(me, name, t, v)
            %
            % See also: ADDTIME1.
            
            % Logs only when toLog is true.
            if ~me.toLog, return; end
            
            ixSamp = 1:length(t);
            
            switch me.src_.(name)
                % case 'mark'    % Do nothing but recording t.

                case 'markFirst' % Record only the first t.
                    if isnan(me.t_.(name))
                        me.n_.(name)    = 1;
                        me.t_.(name)    = t(1); 
                    end

                case 'markLast'  % Record only the last t.
                    me.n_.(name)        = 1;
                    me.t_.(name)        = t(end);

                otherwise

                    cN                  = me.n_.(name) + ixSamp;
                    me.n_.(name)        = cN(end);
                    me.t_.(name)(cN)    = t;

                    switch me.src_.(name)
                        case 'val1'
                            me.v_.(name)(cN,:)  = v;

                        case 'val2'
                            me.v_.(name)(:,cN)  = v;

                        case 'val3'
                            me.v_.(name)(:,:,cN) = v;

                        case 'valCell'
                            me.v_.(name){cN}    = v;

                        case 'prop1'
                            me.v_.(name)(cN,:)  = me.(name);

                        case 'prop2'
                            me.v_.(name)(:,cN)  = me.(name);

                        case 'prop3'
                            me.v_.(name)(:,:,cN) = me.(name);

                        case 'propCell'
                            me.v_.(name){cN}    = me.(name);
                    end
            end
        end
        
        
        function addTime(me, names, t)
            % ADDTIME  Adds only timestamps, leaving contents untouched.
            %
            % addTime(me, names, t)
            %
            % See also: ADDTIME1, ADDLOG, ADDLOG1.
            
            if ~me.toLog, return; end
            
            for ii = 1:length(names)
                name = names{ii};
                
                cN           = me.n_.(name) + 1;
                me.n_.(name) = cN;
                me.t_.(name)(cN) = t;
            end
        end
        
        
        function addTime1(me, name, t)
            % ADDTIME1  Adds only timestamps, leaving contents untouched.
            %
            % addTime1(me, name, t)
            %
            % See also: ADDTIME, ADDLOG, ADDLOG1.
            
            if ~me.toLog, return; end
            
            cN           = me.n_.(name) + 1;
            me.n_.(name) = cN;
            me.t_.(name)(cN) = t;
        end
        
        
        function delLog(me, names)
            % DELLOG  Remove logged variables.
            %
            % delLog(me, names)
            
            for ii = 1:length(names)
                me.n_.(names{ii}) = max(me.n_.(names{ii}) - 1, 0);
            end
        end
        
        
        %% After each trial: CloseLog
        function closeLog(me)
            me.toLog = false;
        end
        
        
        %% Retrieval
        function [cV, t] = v(me, name, varargin)
            % Recorded portion of the contents (v_).
            %
            % [v, relS] = v(me, name) % all recorded contents
            % [v, relS] = v(me, name, ix)
            % [v, relS] = v(me, name, fromT, toT, tUnit)
            
            
            if nargin < 3
                ix = 1:me.n_.(name);
            else
                ix = parseIx(me, name, varargin{:});
            end
            
            if nargout >=2 
                t = relSec(me, name, ix);
            end
            
            switch me.src_.(name)
                case {'val1', 'prop1'}
                    cV = me.v_.(name)(ix,:);
                    
                case {'val2', 'prop2'}
                    cV = me.v_.(name)(:,ix);
                    
                case {'val3', 'prop3'}
                    cV = me.v_.(name)(:,:,ix);
                    
                case {'valCell', 'propCell'}
                    cV = me.v_.(name)(ix);
            end
        end
        
        
        function [cV, t] = vCell(me, name, varargin)
            % Recorded portion of the contents (v_) when
            % the content is valCell or propCell.
            %
            % [v, relS] = v(me, name) % all recorded contents
            % [v, relS] = v(me, name, ix)
            
            
            if nargin < 3
                ix = 1:me.n_.(name);
            else
                ix = parseIx(me, name, varargin{:});
            end
            
            if nargout >=2 
                t = relSec(me, name, ix);
            end
            
            % No input checking yet.
            cV = me.v_.(name){ix};
        end
        
        
        function varargout = vTrim(me, varargin)
            % vTrim: Alias for v.
            % 
            % See also PsyLogs.v.
            
            [varargout{1:nargout}] = v(me, varargin{:});
        end
        
        
        function varargout = tTrim(me, varargin)
            % tTrim: Alias for t.
            % 
            % See also PsyLogs.t.
            
            [varargout{1:nargout}] = t(me, varargin{:});
        end
        
        
        function cT = t(me, name, varargin)
            % Recorded portion of the timestamps (t_).
            %
            % t = tTrim(me, name, ix)
            %
            % See also: PARSEIX, RELSEC, ABSSEC, FR
            
            if nargin < 3
                ix = 1:me.n_.(name);
            else
                ix = parseIx(me, name, varargin{:});
            end
            
            cT = me.t_.(name)(ix);
        end
        
        
        function tf = logged(me, varargin)
            % tf = logged(me, varargin)
            
            if isempty(varargin)
                varargin = me.names_;
            end
            
            for ii = length(varargin):-1:1
                tf(ii) = me.n_.(varargin{ii}) > 0;
            end            
        end
        
        
        function v = lastV(me, name)
            v = me.vTrim(name, me.n_.(name));    
        end
        
        
        function t = lastT(me, name)
            t = me.tTrim(name, me.n_.(name));
        end
        
        
        function S = v2S(me)
            S = struct;
            
            for f = me.names_
                S.(f{1}) = me.v(f{1});
            end
        end
        
        %% Time
        function res = relSec(me, name, varargin)
            % res = relSec(me, [name, ix])
            % res = relSec(me, name, fromT, toT, tUnit)
            %
            % See also: PARSEIX, TTRIM;
            
            if (nargin < 2) || isempty(name)
                for cName = me.names_
                    res.(cName{1}) = relSec(me, cName{1}, varargin{:});
                end
            else
                if nargin < 3
                    ix = 1:me.n_.(name);
                else
                    ix = parseIx(me, name, varargin{:});
                end

                switch me.tUnit_.(name)
                    case 'absSec'
                        res = me.t_.(name)(ix) - me.Scr.t_.st;
                    case 'fr'
                        cfr = me.t_.(name)(ix);
                        if isnan(cfr)
                            res = cfr;
                        else
                            res = me.Scr.t_.frOn(cfr) - me.Scr.t_.st;
                        end
                end
            end
        end
        
        
        function res = absSec(me, name, varargin)
            % res = absSec(me, name, ix)
            % res = absSec(me, name, fromT, toT, tUnit)
            
            if nargin < 3
                ix = 1:me.n_.(name);
            else
                ix = parseIx(me, name, varargin{:});
            end
               
            switch me.tUnit_.(name)
                case 'absSec'
                    res = me.t_.(name)(ix);
                case 'fr'
                    res = me.Scr.t_.frOn(me.t_.(name)(ix));
            end
        end
        
        
        function res = fr(me, name, varargin)
            % res = fr(me, name, ix)
            % res = fr(me, name, fromT, toT, tUnit)
            %
            % In case the original tUnit is absSec, returns the last frame 
            % whose onset coincides with or precedes the given time.
            
            if nargin < 3
                ix = 1:me.n_.(name);
            else
                ix = parseIx(me, name, varargin{:});
            end
               
            switch me.tUnit_.(name)
                case 'absSec'
                    res = arrayfun(@(c) find(c <= me.Scr.t_.frOn, 1, 'last'), ...
                                             me.t_.(name)(ix));
                case 'fr'
                    res = me.t_.(name)(ix);
            end
        end
        
        
        function replaceT(me, name, t, tUnit, varargin)
            % replaceT Replace the timestamp(s) with the provided one.
            %
            % replaceT(me, name, t, tUnit, [tArgs])
            %
            % t     : New timestamps.
            % tUnit : 'fr', 'relSec', or 'absSec'.
            % tArgs : Existing timestamps to replace. Parsed by parseIx.
            %         Omit to replace all.
            %
            % See also: parseIx.
            
            ix = parseIx(me, name, varargin{:});
            
            if length(t) ~= length(ix)
                if isempty(varargin)
                    % Unmatched number may be allowed when replacing the whole
                    switch me.src_.(name)
                        case 'mark' 
                            % if it is time stamps only, it is fine.
                        case {'markFirst', 'markLast'}
                            if length(t) > 1
                                error('PsyLogs:replaceT:TooManyTimestamps', ...
                                      'markFirst and markLast can have one time stamp at maximum!');
                            end
                        otherwise
                            error('PsyLogs:replaceT:UnmatchedTimestampNumber', ...
                                  'Number of the new timestamps should match that of existing ones!');
                    end
                    % If no error so far, set n_ to length(t).
                    me.n_.(name) = length(t);
                    ix           = 1:length(t);
                else
                    error('PsyLogs:replaceT:UnmatchedTimestampNumber', ...
                          'Number of the new timestamps should match that of existing ones!');
                end
            end
            
            switch me.tUnit_.(name)
                case 'absSec'
                    me.t_.(name)(ix) = me.calcAbsSec(t, tUnit);
                case 'fr'
                    n = length(ix);
                    frOn = me.Scr.relSec('frOn');
                    for ii = 1:n
                        cix = ix(ii);
                        if isnan(t(ii))
                            cfr = nan;
                        else
                            cfr = find(frOn >= t(ii), 1, 'first');
                            if isempty(cfr), cfr = nan; end
                        end
                        me.t_.(name)(cix) = cfr;
                    end
            end
        end
        
        
        %% Subfunctions
        function ix = parseIx(me, name, varargin)
            % PARSEIX Returns the log's index range that includes fromT & toT.
            %
            % ix = parseIx(me, name) % All recorded entries.
            % ix = parseIx(me, name, ix)
            % ix = parseIx(me, name, fromT, toT, tUnit)
            % ix = parseIx(me, name, fun, tThres, tUnit)
            %
            % tUnit     : 'fr', 'relSec', 'absSec'
            %   fr      : Frame number, starting from 1 in each trial.
            %   relSec  : Second from the beginning of each trial.
            %   absSec  : Second returned by GetSecs.
            %
            % fun       : 'ge', 'gt', 'le', 'lt', 'eq', 'GE', 'GT','LE', 'LT'
            %   ge, gt  : the soonest entry after/at tThres.
            %   le, lt  : the latest entry before/at tThres.
            %   eq      : the cloest entry to tThres.
            %   GE, GT  : from the ge, gt entry to the last recorded entries.
            %   LE, LT  : from the le, lt entry to the first recorded entries.
            
            % ix = parseIx(me, name) % All recorded entries.
            if nargin == 2
                ix = 1:me.n_.(name);
                
            % ix = parseIx(me, name, ix)
            elseif nargin == 3
                ix = varargin{1};
                
            % ix = parseIx(me, name, fun, tThres, tUnit)
            elseif nargin == 5 && ischar(varargin{1}) 
            
                relS = relSec(me, name);
                relSThres = calcRelSec(me, varargin{2}, varargin{3});
                
                switch varargin{1}
                    case 'ge'
                        ix = find(relS >= relSThres, 1, 'first');
                    
                    case 'gt'
                        ix = find(relS > relSThres, 1, 'first');
                    
                    case 'le'
                        ix = find(relS <= relSThres, 1, 'last');
                    
                    case 'lt'
                        ix = find(relS < relSThres, 1, 'last');
                    
                    case 'GE'
                        ix = find(relS >= relSThres);
                    
                    case 'GT'
                        ix = find(relS > relSThres);
                    
                    case 'LE'
                        ix = find(relS <= relSThres);
                    
                    case 'LT'
                        ix = find(relS < relSThres);
                    
                    case 'eq'
                        [~, ix] = min(abs(relS - relSThres));
                        
                    otherwise
                        error('Unsupported function %d!', varargin{3});
                end
                
            % ix = parseIx(me, name, fromT, toT, tUnit)
            elseif nargin == 5 && ischar(varargin{3})
                    
                relS = relSec(me, name);

                relSRange = calcRelSec(me, [varargin{1}, varargin{2}], ...
                                            varargin{3});

                ix = find(relS >= relSRange(1), 1, 'first') ...
                    :find(relS <= relSRange(2), 1, 'last');

            else
                error('Unparseable index: see help parseIx!');
            end
        end
        
        
        function me2 = copyLogInfo(me, name1, name2, me2)
            % [me2 =] copyLogInfo(me, name1, [name2, me2])
            %
            % copy name1's info to name2.
            
            if ~exist('me2', 'var'), me2 = me; end
            if ~exist('name2', 'var') || isempty(name2), name2 = name1; end
            
            for ccField = {'src_', 'maxN_', 'tUnit_', 'defaultV_', 'v_', 'n_', 't_'}
                cField = ccField{1};
                
                try
                    me2.(cField).(name2) = me.(cField).(name1);
                catch
                    warning('No %s.%s to copy from!\n', ...
                        cField, name1);
                end
            end
        end
        
        
        function me2 = copyLogInfos(me, me2, names)
            % me2 = copyLogInfos(me, me2, names)
            
            for ii = 1:length(names)
                me2 = copyLogInfo(me, names{ii}, names{ii}, me2);
            end
        end
        
        
        function res = calcRelSec(me, t, tUnit)
            % res = calcRelSec(me, t, tUnit)
            
            switch tUnit
                case 'absSec'
                    res = t - me.Scr.t_.st;

                case 'fr'
                    res = me.Scr.t_.frOn(t) - me.Scr.t_.st;
                    
                case 'relSec'
                    res = t;
            end
        end
        
        
        function res = calcAbsSec(me, t, tUnit)
            % res = calcAbsSec(me, t, tUnit)
            
            res = calcRelSec(me, t, tUnit) + me.Scr.t_.st;
        end
        
        
        function res = calcFr(me, t, tUnit, op) % TODO
            error('Todo!');
        end
        
        
        function res = get.names_(me)
            % res = get.names_(me)
            
            res = fieldnames(me.src_)';
        end
        
        function me2 = saveobj(me)
            me2 = saveobj@PsyDeepCopy(me);
            
            fs = fieldnames(me.v_);
            n  = length(fs);
            
            for ii = 1:n
                f = fs{ii};
           
                % Save only recorded portions
                me2.v_.(f) = me.v(f);
                me2.t_.(f) = me.t(f);
            end
        end
    end
end