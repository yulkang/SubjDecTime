function testBaseCaller
    test2
    
    function test2
        test3
        
        function test3
            
            %% Exclude testBaseCaller from baseCaller
            [res, callStack, ix] = baseCaller({'testBaseCaller'});
            disp(res);
            disp({callStack.file}');
            disp(ix);

            %%
            baseCaller
            
            %%
            baseCaller({'testBaseCaller'}, 'base_fallback', 'base')
            
            %%
            baseCaller({'testBaseCaller'}, 'base_fallback', 'pwd')
            
            %%
            baseCaller({'testBaseCaller'}, 'base_fallback', 'guess')
            
        end
    end
end