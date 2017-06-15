%% JSON
obj = struct('a', {{}}, ...
             'd', {'a'}, ...
             'e', {{'', [], {}, struct}});
         
savejson('', obj, 'test.json')
obj2 = loadjson('test.json')

isequal(obj, obj2)

%% JSON-yk
obj = struct('a', {{}}, ...
             'd', {'a'}, ...
             'e', {{'abc', '', '', struct('a', 2)}});
         
savejson_yk('', obj, 'test.json')
obj2 = loadjson_yk('test.json')

isequal(obj, obj2)

%% JSON-cell
obj = struct('a', {{}}, ...
             'd', {'a'}, ...
             'e', {{'', [], {}, struct, {[], struct, struct('a', [], 'b', 3)}}});
         
savejson_cell('', obj, 'test.json')
obj2 = loadjson_struct('test.json')

isequal(obj, obj2)

%% JSON-2
obj = [];
         
savejson_cell('', obj, 'test.json')
obj2 = loadjson_struct('test.json')

isequal(obj, obj2)

%% JSON-3
obj = {[], struct, [3 4 5]};
         
savejson_cell('', obj, 'test.json')
obj2 = loadjson_struct('test.json')

isequal(obj, obj2)

