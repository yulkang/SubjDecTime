classdef PsyTargCoM < PsyTargAns
    methods
        function me = PsyTargAns(varargin)
            me = me@PsyTargAns(varargin{:});
            
            me.initLogEntries('mark', ... % Allow multiple entry/exit
                              [me.enterMarks, me.exitMarks, me.holdMarks], ...
                              'absSec');
            
            me.tag = 'TargCoM';
        end
    end
end