classdef PsyVis < PsyLogs;
    properties
        Scr         = [];
        
        Log;
        
        visible     = false;
        updateOn    = {}; % 'befDraw', 'Key', 'Mouse', 'Eye', etc.
        
        showAtAbsSec = inf;
        hideAtAbsSec = inf;
        
        shownAtAbsSec = true;
        hiddenAtAbsSec = true;
    end
    
    properties (Transient)
        h = []; % Handles for plot()
    end
    
    
    methods (Abstract)
        update(me, from) % update & Log internal features (on (entered), off, maintained)
        res = draw(me, win) % draw & log visual features.
    end
    
    
    methods
        function me = PsyVis
            me.tag = 'Vis';
            me.rootName = 'Scr';
            me.parentName = 'Scr';
            
            me.initLogEntries('mark', {'on', 'off'}, 'fr');
        end
        
        
        function add2Scr(me)
            me.Scr.addObj('Vis', me);
        end
        
        
        function init(me, varargin)
            varargin2fields(me, varargin, false);
        end
        
        
        function initTrial(me)
            me.showAtAbsSec = nan;
            me.hideAtAbsSec = nan;
        end
        
        
        function initLogTrial(me)
            initTrial(me);
            
            initLogTrial@PsyLogs(me);
        end
        
        
        function show(me)
            if ~me.visible
                me.visible = true;
                addLog(me, {'on'}, me.Scr.cFr);
            end
        end
        
        function showAt(me, t, t_unit)
            if nargin < 3, t_unit = 'absSec'; end

            switch t_unit
                case 'absSec'
                    me.showAtAbsSec = t;
                    me.shownAtAbsSec = false;
                otherwise
                    error('t_unit other than absSec unsupported yet!');
            end
        end
        
        function hide(me)
            if me.visible
                me.visible = false;
                addLog(me, {'off'}, me.Scr.cFr);
            end
        end
        
        function hideAt(me, t, t_unit)
            if nargin < 3, t_unit = 'absSec'; end

            switch t_unit
                case 'absSec'
                    me.hideAtAbsSec = t;
                    me.hiddenAtAbsSec = false;
                otherwise
                    error('t_unit other than absSec unsupported yet!');
            end
        end
        
        
        function varargout = toggleShow(me, varargin)
            if me.visible
                varargout{1:nargout} = me.show(varargin{:});
            else
                varargout{1:nargout} = me.hide(varargin{:});
            end 
        end
        
        
        function retrieve(me, fr)
            me = copyFields(me, retrieve(me.Log, fr)); %#ok<NASGU>
        end
    end
    
    methods (Static)
        tf = onnow(t, on, off);
    end
end