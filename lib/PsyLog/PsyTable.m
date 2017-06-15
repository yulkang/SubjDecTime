classdef PsyTable < matlab.mixin.Copyable
    properties
        val
        names
    end
    
    methods
        function me = PsyTable(val, names)
            % me = PsyTable(val, names)
            
            me.names = hVec(names);
            
            if ~iscell(val) || ~ismatrix(val)
                error('Only two-dimensional cell array is allowed!');
            end
            
            if size(val,2) ~= length(me.names)
                error('Number of column should match number of names!');
            end
            
            me.val = val;
        end
        
        function res = s(me, ix)
            res = cell2struct(me.val(ix,:), me.names, 2);
        end        

        function res = c(me, ix, name)
            ix = me.parseIx(ix);
            
            res = me.val(ix, strcmp(name, me.names));
        end

        function res = m(me, ix, name)
            ix = me.parseIx(ix);
            
            res = cell2mat(me.c(ix, name));
        end

        function me = setC(me, ix, name, v)
            ix = me.parseIx(ix);
            
            if ~any(strcmp(name, me.names))
                me.names{end+1} = name;
            end    
            
            me.val(ix, strcmp(name, me.names)) = v;
        end
        
        function me = setN(me, ix, name, v)
            ix = me.parseIx(ix);
            
            if ~any(strcmp(name, me.names))
                me.names{end+1} = name;
            end    
            
            if length(ix) > 1 && numel(v) == 1
                me.val(ix, strcmp(name, me.names)) = repmat({v},length(ix),1);
            else
                me.val(ix, strcmp(name, me.names)) = num2cell(v(:));
            end
        end
        
        function me = setM(me, ix, name, v, iDim)
            ix = me.parseIx(ix);
            
            if ~any(strcmp(name, me.names))
                me.names{end+1} = name;
            end    
            
            if ~exist('iDim', 'var')
                siz  = size(v);
                iDim = find(siz == length(ix));
                
                if length(iDim) ~= 1
                    if all(siz == 1)
                        iDim = 1;
                    else
                        error('More than one dimension matches index length!');
                    end
                end
            end
            
            cIx = forMat2Cell(v, iDim);
            
            me.val(ix, strcmp(name, me.names)) = mat2cell(v, cIx{:});
            
            function cIx = forMat2Cell(v, iDim)
                cIx = num2cell(size(v));
                cIx{iDim} = ones(1, cIx{iDim});
            end
        end
        
        function me = calC(me, ix, name, fun)
            ix = me.parseIx(ix);
            
            me.val(ix, strcmp(name, me.names)) = ...
                cellfun(fun, me.c(ix, name), ...
                        'UniformOutput', false);
        end
        
        function me = calM(me, ix, name, fun)
            ix = me.parseIx(ix);
            
            me.val(ix, strcmp(name, me.names)) = ...
                mat2cell(fun(me.m(ix, name)), me.siz(ix, name, 1));
        end
        
        function me = calN(me, ix, name, fun)
            ix = me.parseIx(ix);
            
            me.val(ix, strcmp(name, me.names)) = ...
                num2cell(fun(cell2mat(me.val(ix,strcmp(name, me.names)))));
        end
        
        function res = siz(me, ix, name, d)
            res = cellfun(@(c) size(c,d), me.c(ix,name));
        end
        
        function me = delName(me, name)
            remIx = ~strcmp(name, me.names);
            
            me.names = me.names(remIx);
            me.val   = me.val(:,remIx);
        end
        
        function ix = parseIx(me, ix)
            if ischar(ix) && strcmp(':', ix), ix = 1:size(me.val, 1); end
            if islogical(ix), ix = find(ix); end
        end
        
        function disp(me)
            disp(me.names);
            disp(me.val);
            
            disp@matlab.mixin.Copyable(me);
        end
    end
end