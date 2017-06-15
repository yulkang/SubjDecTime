classdef PsyPTBs < PsyVis
    properties (Abstract)
        c
    end
    
    methods
        function me = PsyPTBs(cScr, varargin)
            me.rootName = 'Scr';
            me.parentName = 'Scr';
            me.deepCpStructNames = {'c'};
            
            if nargin > 0, me.Scr = cScr; end
        end
        
        function res = draw(me, win)
            % res = draw(me, [win = 1])
            cc = me.c;
            
            if nargin < 2
                for f = fieldnames(cc)'
                    cc.(f{1}).draw;
                end
            else
                for f = fieldnames(cc)'
                    cc.(f{1}).draw(win);
                end
            end
            
            res = 1;
        end
    end
end