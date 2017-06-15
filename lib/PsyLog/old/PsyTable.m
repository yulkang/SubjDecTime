classdef PsyTable < matlab.mixin.Copyable
    properties
        v           = struct;
        defaultV    = struct;
    end
    
    
    properties (Dependent)
        n
        nCol
        fields
    end
    
    
    methods
        function me = PsyTable(fields, n, defaultV)
            if nargin < 3
                defaultV = nan(1, length(fields));
            else
                defaultV = rep2fit(defaultV, [1, length(fields)]);
            end
            
            if numel(n) > 1
                if size(n, 2) ~= length(fields)
                    error('Number of column inconsistent between fields and mat!');
                end
                
                mat = n;
                n   = size(mat,1); %#ok<NASGU>
            else    
                mat = rep2fit(defaultV, [n, length(fields)]);
            end
            
            for iField = 1:length(fields)
                me.defaultV.(fields{iField}) = defaultV(iField);
                me.v.(fields{iField})        = mat(:,iField);
            end
        end

        
        function addCol(me, field, initVal)
            me.v.(field) = rep2fit(initVal, [me.n, 1]);
        end
        
        
        function addRow(me, n)
            cN = me.n;
            
            for cField = me.fields
                me.v.(cField{1})((cN+1):n) = me.defaultV.(cField{1});
            end
        end
        
        
        function res = get(me, ix, field)
            if nargin < 2, 
                res = cell2mat(struct2cell(me.v)');
                return;
            end
            if ischar(ix) && ix == ':', ix = 1:me.n; end
            if nargin < 3, field = me.fields; end
            
            res = zeros(length(ix), length(field));
            
            for iField = 1:length(field)
                res(:,iField) = me.v.(field{iField})(ix);
            end
        end
        
        
        function res = getTable(me, ix, field)
            if nargin < 2,
                res = copy(me);
                return;
            end
            if ischar(ix) && ix == ':', ix = 1:me.n; end
            if nargin < 3, field = me.fields; end
            
            res = PsyTable(field, me.get(ix, field));
        end
        
        
        function me = set(me, mat, ix, field)
            if nargin < 4, field = me.fields; end
            
            siz  = size(mat);
            n    = length(ix);
            nCol = length(field);
            
            if (siz(1) == n) && (siz(2) == nCol)
                for iField = 1:length(field)
                    me.v.(field{iField})(ix) = mat(:, iField);
                end
                
            elseif (siz(1) == 1) && ...
                  ((siz(2) == 1) || (siz(2) == length(field)))
                
                mat = rep2fit(mat, [length(ix), length(field)]);
                
                for iField = 1:length(field)
                    me.v.(field{iField})(ix) = mat(:,iField);
                end
                
            else
                error('Size mismatch betwen mat, ix, and field!');
            end
        end
        
        
        function disp(me)
            disp(me.fields);
            disp(me.get);
        end


        function res = get.n(me)
            res = length(me.v.(me.fields{1}));
        end
        
        
        function res = get.nCol(me)
            res = length(me.fields);
        end
        
        
        function res = get.fields(me)
            res = fieldnames(me.v)';
        end
    end
end