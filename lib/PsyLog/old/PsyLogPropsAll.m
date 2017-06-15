classdef PsyLogPropsAll < PsyLogProps
    % Always logs all propToLog at once.
    % Consequently, n, maxN, and update are scalar numbers rather than structs,
    % and absSec or fr are vectors rather than structs, unlike PsyLogProps.
    %
    % Much faster when logging multiple properties at once,
    % than calling PsyLogScalarPropFr.add multiple times.
    %
    % Even faster is to have a struct having all the properties to log at once,
    % and call PsyLogScalarPropFr.add for that property, but it will be inflexible.
    % (e.g., when I decide to log properties other than I was logging,
    %  I have to include that property into the struct, 
    %  and change the way I refer to that property in every program.)
    
    methods
        function me = PsyLogPropsAll(varargin)
            me.tag      = 'LogPropsAll'; 
            
            me.tUnit    = 'fr';
            me.maxN     = 1;
            
            if nargin > 0
                init(me, varargin{:});
            end
        end
        
        
        % Inherited:
        % init(me, obj, propToLog, appendDim, [tUnit = 'fr'], [defaultVer, maxN])
            %
            % .appendDim (required):  A row vector that indicates which dimension
            %                         to concatenate on successive log.
            %
            % Leave entries empty to preserve current value.
        
            
        function initTUnit(me, tUnit)
            if ~isempty(tUnit)
                me.tUnit = tUnit;
            end
        end
        
        
        function initMaxN(me, maxN)
            if ~isempty(maxN)
                me.maxN = maxN;
            end
        end
        
        
        function initVer(me)            
            me.n = 0;
            me.updated = false;
            me.(me.tUnit) = zeros(1, me.maxN);
                
            for cProp = me.propToLog
                ccProp = cProp{1};

                toRep = ones(1,3);
                toRep(me.appendDim.(ccProp)) = me.maxN;
                me.ver.(ccProp) = repmat(me.defaultVer.(ccProp), toRep);
            end
        end
        
        
        function add(me) % , absSec)
%             if nargin < 2 && strcmp(me.tUnit, 'absSec'), absSec = GetSec; end
            
            me.n = me.n + 1;
            
%             if strcmp(me.tUnit, 'absSec')
%             switch me.tUnit
%                 case 'fr'
%                     me.fr(1,me.n) = me.Scr.cFr;
% 
%                 case 'absSec'
%                     me.absSec(1,me.n) = absSec;
%             end

            for cProp = me.propToLog 
                ccProp = cProp{1};
                
                switch me.appendDim.(ccProp)
                    case 1
                        me.ver.(ccProp)(me.n, :) = me.obj.(ccProp);
                        
                    case 2
                        me.ver.(ccProp)(:, me.n) = me.obj.(ccProp);
                        
                    case 3
                        me.ver.(ccProp)(:,:, me.n) = me.obj.(ccProp);
                end
            end
        end
        
        
        % Inherited:
        % val = retrieve(propName, vers)
    end
end