classdef PsyLogs < PsyDeepCopy
    % A general logging class that logs timestamps, with or without attached
    % values and properties of the parent object.
    
    properties
        Scr         = [];
        Obj         = [];
        
        names       = {};
        
        n           = [];
        maxN        = [];
        
        fr          = [];
        absSec      = [];
        relSec      = [];
        ver         = [];
        
        appendDim   = [];
        updated     = [];
        defaultVer  = [];
        
        src         = [];
        tUnit       = [];
    end
    
    
    methods
        %% Constructor
        function me = PsyLogs(varargin)
            % me = PsyLogs([Obj, ...])
            %
            % Obj       : Object to log properties from. Only one object can be
            %             specified.
            %             
            %             I recommend to construct PsyLogs on construction of the 
            %             parent obejct.
            %
            % Additional values can be specified. See PsyLogs.init() for details.
            
            %% PsyDeepCopy interface
            me.rootName     = 'Scr';
            me.parentName   = 'Obj';
            me.tag          = 'Logs';
           
            %% Other properties
            if nargin > 0
                init(me, varargin{:});
            end
        end
        
        
        %% Init & subfunctions: At the beginning of an experiment.
        function init(me, cSrc, names, tUnit, appendDim, defaultVer, maxN)
            % init(me, src, names, tUnit, [appendDim=2, defaultVer, maxN])
            %
            % src       : 'prop', 'val', 'mark', 'markFirst', 'markLast', 
            %             or 'makrVec'.
            %
            % names     : Row cell vector of strings.
            %             Should be unique within a PsyLogs object.
            %             In case src='prop', the name should match the
            %             property to log from.
            %
            % tUnit     : Row cell vector of 'fr' or 'absSec'.
            %
            % appendDim : Numerical row vector that indicates which dimension
            %             to concatenate on successive log.
            %
            % defaultVer: Row cell vector.
            %             In case src='prop', leave empty or unspecified to copy 
            %             current property values.
            %
            % maxN      : Row cell vector of numbers. Default = {1}.
            %
            %             When src='markFirst' or 'markLast', maxN is enforced to 1.
            %
            %             When src='markVec', maxN is a two element vector,
            %             [maxNSample nMarker].
            %
            % If tUnit, appendDim, defaultVer, or maxN has only one element,
            % the value will apply to all names specified.
            %
            % e.g. init(me.log, 'prop', {'visOrd'}, 'fr', 1, {}, 10);
            %
            %
            % init(me, Obj, [...])
            %
            % Obj       : Object to log properties from. Only one object can be
            %             specified.
            %             
            %             I recommend to construct PsyLogs on construction of the 
            %             parent obejct.
            
            
            if ~ischar(cSrc)
                me.Obj = cSrc;
                cSrc = 'prop';
            end
            
            if nargin < 3,                          return; end
            if nargin < 5 || isempty(appendDim),    appendDim = {2}; end 
            if nargin < 6,                          defaultVer = {}; end 
            if nargin < 7,                          maxN = 1; end
            
            switch cSrc
                case {'markFirst', 'markLast'}
                    maxN = {1};
            end
            
            me.src   = copyFields(me.src, ...
                            cell2struct(cellVec(length(names), cSrc  ), ...
                                        names, 2));
            
            me.names = union(me.names, names);
                                    
            me.tUnit = copyFields(me.tUnit, ...
                            cell2struct(cellVec(length(names), tUnit), ...
                                        names, 2));
            
            if any(strcmp(cSrc, {'prop', 'val'})) % those that record 'ver'.
                
                %% appendDim
                me.appendDim = copyFields(me.appendDim, ...
                                    cell2struct(cellVec(length(names), appendDim), ...
                                                names, 2));
                            
                %% defaultVer
                initDefaultVer(me, names, defaultVer);
            end
            
            initMaxN(me, names, maxN);
        end
        
        
        function initDefaultVer(me, names, defaultVer)
            % initDefaultVer(me, {name1, name2, ...}, ...
            %                    {defaultVer1, defaultVer2, ...}, ...
            %
            % All names should have the same sources (either 'prop' or 'val').
            
            if strcmp(me.src.(names{1}), 'prop')
                if isempty(defaultVer)
                    copyDefaultProp(me);
                else
                    defaultVer = cellVec(length(names), defaultVer);
                    
                    emptyNames = cellfun(@isempty, defaultVer);

                    me.defaultVer = copyFields(me.defaultVer, ...
                                    cell2struct(defaultVer(~emptyNames), ...
                                                names(~emptyNames), 2));

                    copyDefaultProp(me, names(emptyNames));
                end
            else
                me.defaultVer = copyFields(me.defaultVer, ...
                                cell2struct(cellVec(length(names), ...
                                                    defaultVer), ...
                                            names, 2));
            end
        end
        
        
        function copyDefaultProp(me, names)
            % copyDefaultProp(me, names)
            
            if nargin < 2, names = findNames(me, 'src', {'prop'}); end
            
            for cProp = names
                if ~isfield(me.defaultVer, cProp{1}) ...
                 || isempty(me.defaultVer.(cProp{1}))
             
                    me.defaultVer.(cProp{1}) = me.Obj.(cProp{1});
                end
            end
        end

        
        function initMaxN(me, names, maxN)
            % initMaxN(me, names, maxN)
            
            me.maxN = copyFields(me.maxN, ...
                            cell2struct(cellVec(length(names), maxN), ...
                                        names, 2));
        end
           
        
        %% InitLog & subfunctions: At the beginning of each trial.
        function initLog(me)
            % initLog(me)
            
            %% Shortcut variables
            if isprop(me.Obj, 'Scr')
                if isa(me.Obj.Scr, 'PsyScr')
                    me.Scr = me.Obj.Scr;
                else
                    error('Obj.Scr should be a PsyScr object!');
                end
            elseif isa(me.Obj, 'PsyScr')
                me.Scr = me.Obj;
            else
                error(['Obj should either have a property .Scr of ' ...
                       'a PsyScr object, or itself be a PsyScr object!']);
            end
            
            %% Allocate memory & give default values.
            me.n       = cell2struct(num2cell(zeros(1, length(me.names))), ...
                                     me.names,   2);
            me.absSec  = cell2struct(num2cell(nan(1, length(me.absSecNames))), ...
                                     me.absSecNames, 2);
            me.fr      = cell2struct(num2cell(nan(1, length(me.frNames))), ...
                                     me.frNames, 2);
            me.updated = cell2struct(num2cell(false(1, length(me.verNames))), ...
                                     me.verNames, 2);
            
            initVer(me);
            initT(me);
        end
        
        
        function initVer(me)
            % initVer(me)            
            
            for cProp = me.verNames
                ccProp = cProp{1};
                
                toRep                        = ones(1,3);
                toRep(me.appendDim.(ccProp)) = me.maxN.(ccProp);

                me.ver.(ccProp)      = repmat(me.defaultVer.(ccProp), toRep);
            end
        end
        
        
        function initT(me)
            % initT(me)
            
            for cName = me.names
                ccName = cName{1};
                
                switch me.src.(ccName)
                    case 'markVec'
                        me.(me.tUnit.(ccName)).(ccName) ...
                            = nan(me.maxN.(ccName));
                    otherwise
                        me.(me.tUnit.(ccName)).(ccName) ...
                            = nan(1, me.maxN.(ccName));
                end
            end
        end
        
        
        %% Add: during the trial.
        function add(me, names, t, tUnit, newValOnly, vals)
            % add(me, names, t, tUnit, newValOnly = false, vals)
            %
            % names       : row cell vector of names.
            % tUnit       : either 'fr' or 'absSec'.
            % t           : time.
            % newValOnly  : If true,
            %               prop & val : add only when updated.(name) = true.
            % vals        : row cell vector of values, 
            %               where applicable (src = 'val').
            %
            % Caution: tUnit should be common to all names. For performance,
            %          add() does not check it.
            
            if nargin < 5 || isempty(newValOnly),
                newValOnly = false; 
            end
            if nargin < 4 || isempty(tUnit), 
                tUnit = me.tUnit.(names{1}); 
            end
            if nargin < 3 || isempty(t), 
                switch tUnit
                    case 'fr'
                        t = me.Scr.cFr;
                    case 'absSec'
                        t = GetSecs;
                end
            end    
            
            
            for ii = 1:length(names)
                cName = names{ii};
                
                switch me.src.(cName)
                    
                    case 'mark'
                        me.n.(cName) = me.n.(cName) + 1;
                        me.(tUnit).(cName)(me.n.(cName)) = t;
   
                    case 'markVec'
                        me.n.(cName)(vals{ii}) = me.n.(cName)(vals{ii}) + 1;
                        
                        for jj = find(vals{ii})
                            me.(tUnit).(cName)(me.n.(cName)(jj), jj) = t;
                        end
%                         me.(tUnit).(cName)(sub2ind(size(me.(tUnit).(cName)), ...
%                                                    me.n.(cName)(vals{ii}), ...
%                                                    vals{ii})) ...
%                                                    = t;
                        
                    case 'markFirst'
                        if isnan(me.(tUnit).(cName))
                            me.(tUnit).(cName) = t;
                        end
                        
                    case 'markLast'
                        me.(tUnit).(cName) = t;
                        
                    case 'val'
                        if ~newValOnly || me.updated.(cName)
                            me.n.(cName) = me.n.(cName) + 1;
                            me.(tUnit).(cName)(me.n.(cName)) = t;
                            
                            switch me.appendDim.(cName)
                                case 1
                                    me.ver.(cName)(me.n.(cName),:) = vals{ii};
                                    
                                case 2
                                    me.ver.(cName)(:,me.n.(cName)) = vals{ii};
                                    
                                case 3
                                    me.ver.(cName)(:,:,me.n.(cName)) = vals{ii};
                            end
                        end
                        
                    case 'prop'
                        if ~newValOnly || me.updated.(cName)
                            me.n.(cName) = me.n.(cName) + 1;
                            me.(tUnit).(cName)(me.n.(cName)) = t;
                            
                            switch me.appendDim.(cName)
                                case 1
                                    me.ver.(cName)(me.n.(cName),:) = me.Obj.(cName);
                                    
                                case 2
                                    me.ver.(cName)(:,me.n.(cName)) = me.Obj.(cName);
                                    
                                case 3
                                    me.ver.(cName)(:,:,me.n.(cName)) = me.Obj.(cName);
                            end
                        end
                end
            end
        end
        
        
        %% Postprocesses: Retrieving, RelSec...
        function copyLogInfo(me, name1, name2)
            cTUnit  = me.tUnit.(name1);
            
            me.n.(name2)        = me.n.(name1);
            me.maxN.(name2)     = me.maxN.(name1);
            
            me.(cTUnit).(name2) = me.(cTUnit).(name1);
            
            me.appendDim.(name2)= me.appendDim.(name1);
            me.updated.(name2)  = me.updated.(name1);
        end
        
        
        function val = retrieve(me, name, vers, tUnit)
            % val = retrieve(propName, [t, tUnit])
            %
            % t:     Vector of time points or version indices. 
            %        Omit to retrieve every version recorded.
            %
            % tUnit: 'fr', 'absSec', or 'relSec'. Leave empty to use
            %        the raw version indices.
            
            if nargin < 3
                vers = 1:me.n.(name); 
                
            elseif nargin >= 4 && ~isempty(tUnit)
                [~, cVers] = intersect(me.(tUnit).(name), vers);
                
                if length(cVers) ~= length(vers)
                    error('Tried to retrieve unrecorded time points!');
                else
                    vers = cVers;
                end
            end
            
            switch me.appendDim.(name)
                case 1
                    val = me.ver.(name)(vers, :);
                    
                case 2
                    val = me.ver.(name)(:, vers);
                    
                case 3
                    val = me.ver.(name)(:,:,vers);
            end
        end
        
        
        function calcRelSec(me, from, names)
            switch from
                case 'absSec'
                    for cName = names
                        me.relSec.(cName{1}) = me.absSec.(cName{1}) - me.Scr.stAbsSec;
                    end
                    
                case 'fr'
                    for cName = names
                        me.relSec.(cName{1}) = me.Scr.frOnAbsSec(me.fr.(cName{1})) ...
                                             - me.Scr.stAbsSec;
                    end
            end
        end
        
        
        %% Collective names
        function [names in] = findNames(me, varargin)
            in = true(1, length(me.names));
            
            for iProp = 1:(length(varargin) - 1)
                cProp = varargin{iProp};
                cCriteria = varargin{iProp+1};
                
                cIn = false(1, length(me.names));
                
                for cCriterion = cCriteria
                    for iName = 1:length(me.names)
                        cName = me.names{iName};
                        
                        if isequal(cCriterion{1}, me.(cProp).(cName)), 
                            cIn(iName) = true;
                        end
                    end
                end
                
                in = in & cIn;
            end
            
            names = me.names(in);
        end
        
        
        function names = verNames(me)
            names = me.findNames('src', {'prop', 'val'});
        end
        
        
        function names = propNames(me)
            names = me.findNames('src', {'prop'});
        end
        
        
        function names = frNames(me)
            names = me.findNames('tUnit', {'fr'});
        end
        
        
        function names = absSecNames(me)
            names = me.findNames('tUnit', {'absSec'});
        end
    end
end