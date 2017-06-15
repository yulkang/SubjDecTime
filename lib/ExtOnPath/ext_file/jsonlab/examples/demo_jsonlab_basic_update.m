%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         Demonstration of Basic Utilities of JSONlab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

delete demo_jsonlab_basic_update.txt
diary demo_jsonlab_basic_update.txt

rngstate = rand ('state');
randseed=hex2dec('623F9A9E');
clear data2json json2data

fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  a simple scalar value \n')
fprintf(1,'%%=================================================\n\n')

data2json=pi
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data), maxdiff = max(abs(data2json(:) - json2data(:)))


fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  a complex number\n')
fprintf(1,'%%=================================================\n\n')

clear i;
data2json=1+2*i
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data), maxdiff = max(abs(data2json(:) - json2data(:))) 

fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  a complex matrix\n')
fprintf(1,'%%=================================================\n\n')

data2json=magic(6);
data2json=data2json(:,1:3)+data2json(:,4:6)*i
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data), maxdiff = max(abs(data2json(:) - json2data(:)))

%%
fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  MATLAB special constants\n')
fprintf(1,'%%=================================================\n\n')

data2json=[NaN Inf -Inf]
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data)

%%
fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  a real sparse matrix\n')
fprintf(1,'%%=================================================\n\n')

data2json=sprand(10,10,0.1)
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data), maxdiff = max(abs(data2json(:) - json2data(:)))

%%
fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  a complex sparse matrix\n')
fprintf(1,'%%=================================================\n\n')

data2json=data2json-data2json*i
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data), maxdiff = max(abs(data2json(:) - json2data(:)))

fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  an all-zero sparse matrix\n')
fprintf(1,'%%=================================================\n\n')

data2json=sparse(2,3);
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data), maxdiff = max(abs(data2json(:) - json2data(:)))

fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  an empty sparse matrix\n')
fprintf(1,'%%=================================================\n\n')

data2json=sparse([]);
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data)

fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  an empty 0-by-0 real matrix\n')
fprintf(1,'%%=================================================\n\n')

data2json=[];
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data)

fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  an empty 0-by-3 real matrix\n')
fprintf(1,'%%=================================================\n\n')

data2json=zeros(0,3);
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data)

fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  a sparse real column vector\n')
fprintf(1,'%%=================================================\n\n')

data2json=sparse([0,3,0,1,4]');
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data), maxdiff = max(abs(data2json(:) - json2data(:)))

fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  a sparse complex column vector\n')
fprintf(1,'%%=================================================\n\n')

data2json=data2json-1i*data2json;
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data), maxdiff = max(abs(data2json(:) - json2data(:)))

fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  a sparse real row vector\n')
fprintf(1,'%%=================================================\n\n')

data2json=sparse([0,3,0,1,4]);
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data), maxdiff = max(abs(data2json(:) - json2data(:)))

fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  a sparse complex row vector\n')
fprintf(1,'%%=================================================\n\n')

data2json=data2json-1i*data2json;
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data), maxdiff = max(abs(data2json(:) - json2data(:)))

%%
fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  a structure\n')
fprintf(1,'%%=================================================\n\n')

data2json=struct('name','Think Different','year',1997,'magic',magic(3),...
                 'misfits',[Inf,NaN],'embedded',struct('left',true,'right',false))
savejson_cell('',data2json,struct('ParseLogical',1))
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data)

%% Unresolved: savejson_cell still saves a struct array as a cell array, like savejson.
fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  a structure array\n')
fprintf(1,'%%=================================================\n\n')

data2json=struct('name','Nexus Prime','rank',9);
data2json(2)=struct('name','Sentinel Prime','rank',9);
data2json(3)=struct('name','Optimus Prime','rank',9);
savejson_cell('',data2json)
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data)

%%
fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  a cell array\n')
fprintf(1,'%%=================================================\n\n')

data2json=cell(1,3);
data2json{1}=struct('buzz',1.1,'rex',1.2,'bo',1.3,'hamm',2.0,'slink',2.1,'potato',2.2,...
              'woody',3.0,'sarge',3.1,'etch',4.0,'lenny',5.0,'squeeze',6.0,'wheezy',7.0);
data2json{2}=struct('Ubuntu',['Kubuntu','Xubuntu','Lubuntu']);
data2json{3}=[10.04,10.10,11.04,11.10]
savejson_cell('',data2json,struct('FloatFormat','%.2f'))
json2data=loadjson_struct(ans), iseq = isequal(data2json, json2data)

%%
fprintf(1,'\n%%=================================================\n')
fprintf(1,'%%  invalid field-name handling\n')
fprintf(1,'%%=================================================\n\n')

json2data=loadjson_struct('{"ValidName":1, "_InvalidName":2, ":Field:":3, "项目":"绝密"}')

rand ('state',rngstate);

diary off;
