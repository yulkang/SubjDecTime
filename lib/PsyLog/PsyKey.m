classdef PsyKey < PsyInp & PsyLogs
    % PsyKey
    
    properties
        Scr
        
        keyDown = false;
        keyCode
        cKeyNames
        
        keyNames
        
        keyCode_filt
        p_keyCode
        
    end
    
    
    properties (Dependent)
        relS % Structure containing keystroke relSecs.
    end
    
    
    methods
        function me = PsyKey(cScr, varargin)
            
            %% PsyDeepCopy interface
            me = me@PsyInp;
            me.tag = 'Key';
            
            if nargin > 0, me.Scr = cScr; end
            
            fprintf('Will use alphanumeric key names regardless of the platform.\n');
            psyKbName('UnifyToAlphaNumeric');
                
            %% Other properties
            if nargin > 1
                init(me, varargin{:});
            end
            
            me.p_keyCode = zeros(1,256);
        end
        
        
        function init(me, cKeyNames, varargin)
            % init(me, cKeyNames, varargin)

            if nargin >= 3
                me = varargin2fields(me, varargin);
            end
            
            if isempty(me.freq)
                try
                    if ~isempty(me.Scr.info.refreshRate)
                        me.freq = me.Scr.info.refreshRate;
                    end
                catch
                    me.freq = 60;
                end
            else
                me.freq = 60;
            end
            
            if isempty(me.maxSecAtLowFreq)
                try 
                    me.maxSecAtLowFreq = me.Scr.info.maxSec; 
                catch
                    me.maxSecAtLowFreq = 7;
                end; 
            end
            
            if nargin > 1
                me.keyNames = unionCellStr(me.keyNames, cKeyNames);
                
                % key names, e.g., 'leftarrow': Timestamp for the keyDown.
                initLogEntries(me, 'mark', cKeyNames,  'absSec');
            end
            me.keyCode_filt = zeros(1,256);
            me.keyCode_filt(psyKbName(me.keyNames)) = 1;
                        
            % 'sampled': Timestamp for sampling.
%             initLogEntries(me, 'mark', {'sampledAbsSec'}, 'absSec', {}, ...
%                            me.maxNSample);
            
        end
        
        function activate(me)
%             global ptb_kbcheck_enabledKeys
%             ptb_kbcheck_enabledKeys = zeros(1,256);
%             ptb_kbcheck_enabledKeys(psyKbName(me.keyNames)) = 1;
%             
            activate@PsyInp(me);
        end

        function deactivate(me)
%             global ptb_kbcheck_enabledKeys
%             ptb_kbcheck_enabledKeys = [];
%             
            deactivate@PsyInp(me);
        end        
        
        function get(me)
            [~, c_sampledAbsSec, c_keyCode] = KbCheck;
            
            cc_keyCode   = c_keyCode & ~me.p_keyCode & me.keyCode_filt;
            cKeyDown     = any(cc_keyCode);
            me.p_keyCode = c_keyCode;
            
            me.sampledAbsSec = c_sampledAbsSec;
%             % If nothing's pressed, just record the timestamp for sampling.
%             addLog(me, {'sampledAbsSec'}, me.sampledAbsSec);
            
            if cKeyDown
                % ignore case of key names.
                [~, c_KeyNames] = strcmpfinds(psyKbName(cc_keyCode), me.keyNames, ...
                                             true);
                                      
                % enforce cell
                if ~iscell(c_KeyNames)
                    c_KeyNames = {c_KeyNames};
                end
                    
                me.keyDown = true;
                
                % mark if first.
                addLog(me, c_KeyNames, c_sampledAbsSec);
                
                me.cKeyNames = c_KeyNames;
                
            else
                me.keyDown = false;
                me.cKeyNames = {};
            end
        end
        
        
        function tf = logged(me, varargin)
            % tf = logged(me, varargin)
            % 
            % If varargin is omitted, return key states, i.e., 
            % exclude logged('sampledAbsSec').
            
            if isempty(varargin)
                tf = logged@PsyLogs(me, me.keyNames{:});
            else
                tf = logged@PsyLogs(me, varargin{:});
            end
        end
        
        
        function strCell = loggedNames(me)
            % strCell = loggedNames(me)
            
            strCell = me.keyNames(me.logged);
        end
        
        
        function s = get.relS(me)
            for cKey = me.keyNames
                s.(cKey{1}) = me.relSec(cKey{1});
            end
        end        
    end
    
end