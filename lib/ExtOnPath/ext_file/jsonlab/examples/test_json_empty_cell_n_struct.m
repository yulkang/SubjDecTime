obj = struct('a', {{}}, ...
             'b', {{[], struct}})
         
%% 1.0 alpha
savejson('', obj, 'test.json')
obj2 = loadjson('test.json')

%% updated
savejson_cell('', obj, 'test.json')
obj3 = loadjson_struct('test.json')

