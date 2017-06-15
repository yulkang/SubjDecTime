classdef PsyTargAnsOnly < PsyTargAns
    % Remove Mouse evenet from PsyTargAns.
    
    methods
        function me = PsyTargAnsOnly(varargin)
            me = me@PsyTargAns(varargin{:});
            
            me.tag = 'TargAnsOnly';
            
            %% Remove Mouse event.
            tfMouse = strcmp('Mouse', me.updateOn);
            me.updateOn = me.updateOn(~tfMouse);
        end
    end
end