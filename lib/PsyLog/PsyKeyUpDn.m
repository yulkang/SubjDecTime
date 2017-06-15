classdef PsyKeyUpDn < PsyKey
    % PsyKey
    
    properties
        keyUp   = false;
        cKeyNamesUp
    end
    
    methods
        function me = PsyKeyUpDn(varargin)
            me = me@PsyKey(varargin{:});
        end
        
        function init(me, varargin)
            % init(me, cKeyNames, varargin)

            me.init@PsyKey(varargin{:});

            if nargin > 1
                cKeyNames = varargin{1};
                
                me.keyNames = unionCellStr(me.keyNames, cKeyNames);
                
                % key names, e.g., 'leftarrow': Timestamp for the keyDown.
                initLogEntries(me, 'mark', csprintf('%s_up', cKeyNames),  'absSec');
            end            
        end
        
        function get(me)
            [~, c_sampledAbsSec, c_keyCode] = KbCheck;
            
            pp_keyCode     = me.p_keyCode;
            c_keyCode_filt = me.keyCode_filt;
            
            cc_keyCode   = c_keyCode & ~pp_keyCode & c_keyCode_filt;
            cc_keyCodeUp = pp_keyCode & ~c_keyCode & c_keyCode_filt;
            
            cKeyDown     = any(cc_keyCode);
            cKeyUp       = any(cc_keyCodeUp);
            
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
                
                % mark.
                addLog(me, c_KeyNames, c_sampledAbsSec);
                
                me.cKeyNames = c_KeyNames;
                
            else
                me.keyDown = false;
                me.cKeyNames = {};
            end
            
            if cKeyUp
                % ignore case of key names.
                [~, c_KeyNames] = strcmpfinds(psyKbName(cc_keyCodeUp), me.keyNames, ...
                                             true);
                                      
                % enforce cell
                if ~iscell(c_KeyNames)
                    c_KeyNames = {c_KeyNames};
                end
                    
                me.keyUp = true;
                
                % mark.
                addLog(me, csprintf('%s_up', c_KeyNames), c_sampledAbsSec);
                
                me.cKeyNamesUp = c_KeyNames;
                
            else
                me.keyUp = false;
                me.cKeyNamesUp = {};
            end
        end
    end
    
end