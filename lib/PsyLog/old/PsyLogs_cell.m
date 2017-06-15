classdef PsyLogs_cell < PsyDeepCopy
    
    properties
        Scr         = [];
        Obj         = [];
        
        names       = {};
        
        ns          = [];
        maxNs       = [];
        
        defaultVs   = {};
        vs          = {};
        ts          = {};
        tUnits      = {};
        
        appendDims  = [];
        srcs        = {};
    end
    
    
    methods
        %% Constructor
        function me = PsyLogs_cell(varargin)
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
        function ix = init(me, cSrc, cNames, cTUnits, cAppendDims, cDefaultVs, cMaxNs)
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
            % tUnit     : 'fr' or 'absSec'.
            %
            % appendDim : Numerical row vector that indicates which dimension
            %             to concatenate on successive log.
            %
            % defaultVer: Row cell vector.
            %             In case src='prop', leave empty or unspecified to copy 
            %             current property values.
            %
            % maxN      : Row vector of numbers. Default = 1.
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
                me.Obj  = cSrc;
                cSrc    = 'prop';
            end
            
            if nargin < 3, return; end
            
            if nargin < 5
                cAppendDims = 2;
            end
            if nargin < 6
                switch cSrc
                    case 'val'
                        cDefaultVs = {nan};
                    case 'prop'
                        cDefaultVs = {[]};
                end
            end
            if nargin < 7 || any(strcmp(cSrc, {'markFirst', 'markLast'}))
                cMaxNs = 1;
            end

            % Avoid [me.names,ix] = union() to ensure consistent behavior:
            % union()'s behavior will change.
            [me.names, ix] = unionAdd(me.names, cNames);
                
            nIx = length(ix);
                                                
            me.maxNs(ix)        = rep2fit(cMaxNs,       [1 nIx]);
            me.srcs(ix)         = cellVec(nIx, cSrc);
            me.tUnits(ix)       = cellVec(nIx, cTUnits);
            me.appendDims(ix)   = rep2fit(cAppendDims,  [1 nIx]);
            
            if ~strcmp(cSrc, {'mark', 'markFirst', 'markLast'})
                me.defaultVs(ix)    = cellVec(nIx, cDefaultVs);
            end
        end
        
        
        function initLog(me)
            me.ns(1:length(me.names))    = 0;
            
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
                % debug
%                 error(['Obj should either have a property .Scr of ' ...
%                        'a PsyScr object, or itself be a PsyScr object!']);
            end
            
            
            %% Allocate memory & give default values
            for ii = 1:length(me.ns)
                
                me.ts{ii}                = nan(1, me.maxNs(ii));
                
                if any(strcmp(me.srcs{ii}, {'val', 'prop'}))
                    toRep                    = ones(1,3);
                    toRep(me.appendDims(ii)) = me.maxNs(ii);

                    if strcmp(me.srcs{ii}, 'prop') && isempty(me.defaultVs{ii})
                        me.vs{ii}           = repmat(me.Obj.(me.names{ii}), toRep);
                    else
                        me.vs{ii}           = repmat(me.defaultVs{ii}, toRep);
                    end
                end
            end            
        end
        
        
        function add(me, names, t, vs)
            % add(me, names, vs, [t])
            %
            % names : either numeric, logical, or cellstr.
            % vs    : cell vector. Leave empty if mark or prop.
            % t     : scalar. 
            
            cNames = me.names;
            
            switch class(names(1))
                case 'double'
%             if isnumeric(names(1))
                    ix        = names;
                
                case 'logical'
%             elseif islogical(names(1))
                    ix        = find(names);
                
                case 'cell'
%             elseif iscell(names(1))
                
                    ix        = zeros(1, length(names));
                    for ii = 1:length(names)
                        ix(ii)= find(strcmp(names{ii}, cNames));
                    end
                    
                otherwise
                    ix = find(strcmp(names, cNames));
            end
            
            
            if nargin < 3
                if strcmp('fr', me.tUnits{ix(1)})
                    t = me.Scr.cFr;
                else
                    t = GetSecs;
                end
            end
            
            
            me.ns(ix)   = me.ns(ix) + 1;
            cNs         = me.ns;

            cAppendDims = me.appendDims;
            cSrc        = me.srcs;
            cObj        = me.Obj;
            
            
            for ii  = 1:length(ix)
                cIx = ix(ii);
                
                switch cSrc{cIx}
                    case 'mark'
                        me.ts{cIx}(1, cNs(cIx)) = t;
                        
                    case 'markFirst'
                        if isnan(me.ts{cIx}), me.ts{cIx} = t; end
                            
                    case 'markLast'
                        me.ts{cIx} = t;
                        
                    case 'val'
                        me.ts{cIx}(1, cNs(cIx)) = t;
                        
                        switch cAppendDims(cIx)
                            case 1
                                me.vs{cIx}(cNs(cIx),:) = vs{ii};
                                
                            case 2
                                me.vs{cIx}(:,cNs(cIx)) = vs{ii};
                                
                            case 3
                                me.vs{cIx}(:,:,cNs(cIx)) = vs{ii};
                        end
                        
                    case 'prop'
                        me.ts{cIx}(1, cNs(cIx)) = t;
                        
                        switch cAppendDims(cIx)
                            case 1
                                me.vs{cIx}(cNs(cIx),:) = cObj.(cNames{cIx});
                                
                            case 2
                                me.vs{cIx}(:,cNs(cIx)) = cObj.(cNames{cIx});
                                
                            case 3
                                me.vs{cIx}(:,:,cNs(cIx)) = cObj.(cNames{cIx});
                        end
                end     
            end
        end
        
        
        %% Retrieval
        function v = getV(me, name, varargin)
            % v = getV(me, name)
            % v = getV(me, name, ix)
            % v = getV(me, name, ix1, ix2, ...)
            
            iName = find(strcmp(name, me.names));
            
            switch nargin
                case 2
                    v = me.vs{iName};
                
                case 3
                    switch me.appendDims(iName)
                        case 1
                            v = me.vs{iName}(varargin{1},:);
                        case 2
                            v = me.vs{iName}(:,varargin{1});
                        case 3
                            v = me.vs{iName}(:,:,varargin{1});
                    end
                    
                otherwise
                    v = subsref(me.vs{iName}, struct('type', '()', ...
                                                     'subs', varargin));
            end
        end
        
        
        function t = getT(me, name, ix)
            % t = getT(me, name, [ix])
            
            if nargin < 3
                t = me.ts{ strcmp(name, me.names) };
            else
                t = me.ts{ strcmp(name, me.names) }(ix);
            end
        end
        
        
        function v = get(me, name, field, varargin)
            % v = get(me, name, field, [ix1, ix2, ...])
            
            iName = strcmp(name, me.names);
            
            if iscell(me.(field))
                if nargin == 3
                    v = me.(field){iName};
                else
                    v = subsref(me.(field){iName}, ...
                                struct('type', '()', 'subs', varargin));
                end
            else
                if nargin == 3
                    v = me.(field)(iName);
                else
                    v = subsref(me.(field)(iName), ...
                                struct('type', '()', 'subs', varargin));
                end
            end
        end
        
        
        function names = findNames(me, field, v)
            % names = findNames(me, field, v)
            
            if iscell(me.(field))
                ix = cellfun(@(c) isequal(c,v), me.(field));
            else
                ix = arrayfun(@(c) isequal(c,v), me.(field));
            end
            
            names = me.names(ix);
        end
        
        
        function ix = findIx(me, names)
            % ix = findIx(me, names)
            
            if iscell(names)
                ix = strcmpfinds(names, me.names);
            else
                ix = find(strcmp(names, me.names));
            end
        end
        
        
        function set(me, names, field, v)
            % set(me, name, field, v)
            
            if ischar(names)
                iNames = find(strcmp(names, me.names));
            else
                iNames = strcmpfinds(names, me.names);
            end
            
            for iName = iNames
                if iscell(me.(field))
                    me.(field){iName} = v;
                else
                    me.(field)(iName) = v;
                end
            end
        end
    end
end