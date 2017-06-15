classdef testHandle < handle
    % Handle class performance test
    
    properties
        a = magic(100);
        bbbbb = 1;
        c = struct;
    end
    
    methods
        function inc(me)
            me.a = me.a + 1;
        end
    end    
    
    methods (Static)
        function h = test_handle_obj
            h = testHandle;
            
            % Handle objects
            disp('Pre-assigning big handle objects');
            for ii = 'a':'z', h.c.(ii) = testHandle; end
            
            tic; for ii = 1:1000, cc = h.c; for jj = 'a':'z', k = cc.(jj); end; end; toc;
            tic; for ii = 1:1000, for jj = 'a':'z', k = h.c.(jj); end; end; toc;
            
            tic; for ii = 1:1000, cc = h.c; for jj = 'a':'b', k = cc.(jj); end; end; toc;
            tic; for ii = 1:1000, for jj = 'a':'b', k = h.c.(jj); end; end; toc;
            
            tic; for ii = 1:1000, cc = h.c; for jj = 'a', k = cc.(jj); end; end; toc;
            tic; for ii = 1:1000, for jj = 'a', k = h.c.(jj); end; end; toc;
            
            disp('Pre-assignment is better when >1 references to handle objects are made.');
            disp(' ');
        end
        
        function h = test_fun_handle
            h = testHandle;
            
            % Function handles
            disp('Pre-assigning big function handles');
            for ii = 'a':'z', h.c.(ii) = @(a) a+magic(ii+100); end
            
            tic; for ii = 1:1000, cc = h.c; for jj = 'a':'z', k = cc.(jj); end; end; toc;
            tic; for ii = 1:1000, for jj = 'a':'z', k = h.c.(jj); end; end; toc;
            
            tic; for ii = 1:1000, cc = h.c; for jj = 'a':'b', k = cc.(jj); end; end; toc;
            tic; for ii = 1:1000, for jj = 'a':'b', k = h.c.(jj); end; end; toc;
            
            tic; for ii = 1:1000, cc = h.c; for jj = 'a', k = cc.(jj); end; end; toc;
            tic; for ii = 1:1000, for jj = 'a', k = h.c.(jj); end; end; toc;
            
            disp('Pre-assignment is better when >1 references to function handles are made.');
        end
        
        function h = test_for_range
            h = testHandle;
            
            % Range for 'for' loops
            disp('Pre-assigning the range for ''for'' loops');
            
            h.c = num2cell('a':'z');
            tt = 0;
            tic; for ii = 1:1000, cc = h.c; for jj = cc, tt = tt + double(jj{1}); end; end; toc;
            tt = 0;
            tic; for ii = 1:1000, for jj = h.c; tt = tt + double(jj{1}) ;end; end; toc;
            
            h.c = num2cell('a':'b');
            tt = 0;
            tic; for ii = 1:1000, cc = h.c; for jj = cc, tt = tt + double(jj{1}); end; end; toc;
            tt = 0;
            tic; for ii = 1:1000, for jj = h.c; tt = tt + double(jj{1}) ;end; end; toc;
            
            h.c = num2cell('a');
            tt = 0;
            tic; for ii = 1:1000, cc = h.c; for jj = cc, tt = tt + double(jj{1}); end; end; toc;
            tt = 0;
            tic; for ii = 1:1000, for jj = h.c; tt = tt + double(jj{1}) ;end; end; toc;
            
            disp('It does NOT help to pre-assign for-loop range');
        end
    end
end

