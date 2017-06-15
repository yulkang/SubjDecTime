classdef testFuncHandle < PsyDeepCopy
    % Avoid function handles if the repeated 'if' statement is simple.
    
    properties
        a
        v
        v2
    end
    
    
    methods
        function me = testFuncHandle
            me.a = @(arg) me.b1(arg);
        end
        
        function b1(me, arg)
            me.v = arg;
            
            me.a = @(arg) me.b2(arg);
        end
        
        function b2(me, arg)
            me.v = me.v + arg;
        end
        
        function c(me, arg)
            if isempty(me.v2)
                me.v2 = arg;
            else
                me.v2 = me.v2 + arg;
            end
        end
    end
    
    
    methods (Static)
        function test(nRep)
            if nargin<1, nRep = 1000; end
            
            me = testFuncHandle;
            
            tic;
            for ii = 1:nRep
                me.c(ii);
            end
            toc;
            disp(me.v2);
            
            
            tic;
            for ii = 1:nRep
                me.a(ii);
            end
            toc;
            disp(me.v);
            
            
            delete(me);
        end
    end
end