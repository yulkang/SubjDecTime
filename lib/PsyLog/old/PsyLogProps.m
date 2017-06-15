classdef PsyLogProps < PsyLogProp
    % Much faster when logging multiple properties at once,
    % than calling PsyLogScalarPropFr.add multiple times.
    %
    % Even faster is to have a struct having all the properties to log at once,
    % and call PsyLogScalarPropFr.add for that property, but it will be inflexible.
    % (e.g., when I decide to log properties other than I was logging,
    %  I have to include that property into the struct, 
    %  and change the way I refer to that property in every program.)
    
    properties
        propToLog   = {};
        
        tUnit       = [];
        
        n           = [];
        maxN        = [];
        
        absSec      = [];
        fr          = [];
        
        appendDim   = [];
        defaultVer  = [];
        updated     = [];
    end
    
    
    methods
        function me = PsyLogProps(varargin)
            me.tag  = 'LogProps';
            
            if nargin > 0
                init(me, varargin{:});
            end
        end
        
        
        function init(me, obj, propToLog, appendDim, tUnit, varargin)
            % init(me, obj, propToLog, appendDim, [tUnit = 'fr'], [defaultVer, maxN])
            %
            % .appendDim (required):  A row vector that indicates which dimension
            %                         to concatenate on successive log.
            %
            % Leave entries empty to preserve current value.
            
            me.obj = obj;
            
            if ~exist('propToLog', 'var'), propToLog = []; end
            if ~exist('appendDim', 'var'), appendDim = []; end
            if ~exist('tUnit', 'var'), tUnit = 'fr'; end
            
            propToLogUpdated = initPropToLog(me, propToLog);
            
            initAppendDim(me, appendDim, propToLogUpdated);
            initTUnit(me, tUnit);

            initLog(me, varargin{:});
        end
        
        
        function propToLogUpdated = initPropToLog(me, propToLog)
            propToLogUpdated = false;

            if ~isempty(propToLog)
                if ~iscell(propToLog)
                    error('propToLog should be a cell array of property names!');

                elseif ~isequal(me.propToLog, propToLog)
                    me.propToLog    = propToLog;
                    propToLogUpdated= true;
                end
            end
        end 
        
        
        function initTUnit(me, tUnit)
            if ~isempty(tUnit)
                if ischar(tUnit)
                    tUnit = repmat({tUnit}, [1 length(me.propToLog)]);

                elseif iscell(tUnit) && (length(tUnit) == 1)
                    tUnit = repmat(tUnit, [1 length(me.propToLog)]);

                elseif iscell(tUnit) && (length(tUnit) ~= length(me.propToLog))
                    error(['tUnit should be either a string or ' ...
                           'a row cell vector of strings ' ...
                           'of the same length as propToLog!']);
                end

                me.tUnit = cell2struct(tUnit, me.propToLog, 2);
            end
        end
        
        
        function initAppendDim(me, appendDim, propToLogUpdated)
            if ~isempty(appendDim)
                if length(appendDim) == 1
                    appendDim = appendDim * ones(1, length(me.propToLog));

                elseif length(appendDim) ~= length(me.propToLog)
                    error(['appendDim should be either scalar or a row vector of ' ...
                           'the same length as propToLog!']);
                end

                me.appendDim = cell2struct(num2cell(appendDim), me.propToLog, 2);

            elseif propToLogUpdated
                error('Specify .appendDim when updating .propToLog!');
            end
        end
        
        
        function initLog(me, defaultVer, maxN)
            % initLog(me, defaultVer, maxN)
            %
            % dafaultVer: If unspecified or empty, will copy current value.
            
            if ~exist('defaultVer', 'var'), defaultVer = []; end
            if ~exist('maxN', 'var'), maxN = []; end
            
            initDefaultVer(me, defaultVer);
            initMaxN(me, maxN);
            
            initVer(me);
        end
        
        
        function initDefaultVer(me, defaultVer)
            if ~isempty(defaultVer)
                me.defaultVer = cell2struct(defaultVer, me.propToLog, 2);
            else
                for cProp = me.propToLog
                    me.defaultVer.(cProp{1}) = me.obj.(cProp{1});
                end
            end
        end

        
        function initMaxN(me, maxN)
            if exist('maxN', 'var') && ~isempty(maxN)
                if length(maxN) == 1
                    maxN         = maxN * ones(size(me.propToLog));
                elseif length(maxN) ~= length(me.propToLog)
                    error(['maxN should be either scalar or a row vector of ' ...
                           'the same length as propToLog!']);
                end

                me.maxN = cell2struct(num2cell(maxN), me.propToLog, 2);
            end
        end
           
        
        function initVer(me)            
            for cProp = me.propToLog
                ccProp = cProp{1};

                toRep = ones(1,3);
                toRep(me.appendDim.(ccProp)) = me.maxN.(ccProp);
                me.n.(ccProp) = 0;
                me.(me.tUnit.(ccProp)).(ccProp) = zeros(1, me.maxN.(ccProp));
                me.ver.(ccProp) = repmat(me.defaultVer.(ccProp), toRep);
                
                me.updated.(ccProp) = false;
            end
        end
        
        
        function add(me, updatedOnly, absSec, varargin)
            % add([updatedOnly], [absSec], propName1, propName2, ...)
            
            if nargin < 2 || isempty(updatedOnly)
                updatedOnly = false;
            end
            if nargin < 3 || isempty(absSec)
                absSec   = GetSecs;   
            end
            if nargin < 4,      
                varargin = me.propToLog; 
            end
            
            
            for cProp = varargin
                ccProp = cProp{1};

                % updatedOnly
                if updatedOnly && ~me.updated.(ccProp), continue; end
                me.updated.(ccProp) = false;
                
                % n
                me.n.(ccProp) = me.n.(ccProp) + 1;

                % tUnit, fr, absSec
                switch me.tUnit.(ccProp)
                    case 'fr'
                        me.fr.(ccProp)(1,me.n.(ccProp)) = me.Scr.cFr;

                    case 'absSec'
                        me.absSec.(ccProp)(1,me.n.(ccProp)) = absSec;
                end

                % appendDim, ver
                switch me.appendDim.(ccProp)
                    case 1
                        me.ver.(ccProp)(me.n.(ccProp), :) = me.obj.(ccProp);
                        
                    case 2
                        me.ver.(ccProp)(:, me.n.(ccProp)) = me.obj.(ccProp);
                        
                    case 3
                        me.ver.(ccProp)(:,:, me.n.(ccProp)) = me.obj.(ccProp);
                end
            end
        end
        
        
        function val = retrieve(prop, vers)
            % val = retrieve(propName, vers)
            
            switch me.appendDim.(prop)
                case 1
                    val = me.ver.(prop)(vers, :);
                    
                case 2
                    val = me.ver.(prop)(:, vers);
                    
                case 3
                    val = me.ver.(prop)(:,:,vers);
            end
        end
    end
end