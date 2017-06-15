classdef PsyMat < matlab.mixin.Copyable
    properties (SetObservable)
        v       = [];
    end
    
    properties (SetAccess = protected)
        fields  = {};
        vListen
    end
    
    
    methods
        function me = PsyMat(fields, n)
            % Creates a PsyMat object.
            %
            % Mat = PsyMat({'field1', 'field2', ...}, nRow, [isCell=false]);
            %
            %     : The value is set to zeros(nRow, numField)
            %
            % Mat = PsyMat({'field1', 'field2', ...}, mat);
            %
            %     : The value is set to mat (vector or matrix).
            
            if iscell(fields)
                me.fields = fields;
            
            elseif ischar(fields)
                me.fields = {fields};
                
            else
                error('fields must be either cell or char!');
            end
            
            me.vListen = addlistener(me, 'v', 'PostSet', @me.PostSetV);
            
            if numel(n) > 1
                if size(n, 2) ~= me.nCol
                    error('Number of column inconsistent between fields and mat!');
                end
                
                me.v = n;
                
            else
                setVDefault(me, n);
            end
        end
        
        
        function setVDefault(me, nRow, nCol)
            me.v = zeros(nRow, nCol);
        end
        
        
        function res = nCol(me)
            res = length(me.fields);
        end
        
        
        function res = n(me)
            res = size(me.v, 1);
        end
        
        
        function PostSetV(me, ~, ~)
            siz = size(me.v);
            
            if length(siz) > 2, 
                error('ndims cannot go over 2!'); 
            end
            
            if siz(2) ~= length(me.fields), 
                error('add/remove column through add/rmCol!');
            end
        end
        
        
        function me = addCol(me, col)
            me.fields = [me.fields, {col}];
            me.v(me.n, me.nCol) = 0;
        end
        
        
        function me = rmCol(me, col)
            restCol = ~strcmp(me.fields, col);
            
            me.v = me.v(:,restCol);
            me.fields = me.fields(restCol);
        end
        
        
        function me = renameCol(me, src, dst)
            me.fields{ find(strcmp(src, me.fields)) } = dst;
        end
        
        
        function me = reorderCol(me, order)
            me.fields = me.fields(order);
            me.v      = me.v(:,order);
        end
        
        
        function [ixRow, ixCol, nRow, nCol] = getIx(me, varargin)
            % Mat.getIx
            % Mat.getIx(rowIndices);
            % Mat.getIx(fieldIndices);
            % Mat.getIx(rowIndices, fieldIndices)
            
            switch length(varargin)
                case 0
                    nRow  = me.n;
                    ixRow = 1:nRow;
                    nCol  = me.nCol;
                    ixCol = 1:nCol;
                    
                case 1
                    if ischar(varargin{1}) || iscell(varargin{1})
                        nRow  = me.n;
                        ixRow = 1:nRow;
                        ixCol = strcmpfinds(varargin{1}, me.fields);
                        nCol  = length(ixCol);
                    else
                        if islogical(varargin{1})
                            ixRow = find(varargin{1});
                        else
                            ixRow = varargin{1};
                        end
                        nRow = length(ixRow);
                        
                        nCol  = me.nCol;
                        ixCol = 1:nCol;
                    end
                    
                case 2
                    if islogical(varargin{1})
                        ixRow = find(varargin{1});
                    else
                        ixRow = varargin{1};
                    end
                    nRow = length(ixRow);
                    
                    ixCol = strcmpfinds(varargin{2}, me.fields);
                    nCol  = length(ixCol);
            end
        end
        
        
        function [res ixCol] = get(me, varargin)
            % Mat.get
            % Mat.get(rowIndices);
            % Mat.get(fieldIndices);
            % Mat.get(rowIndices, fieldIndices)
            %
            % rowIndices   : either numeric or logical indices.
            % fieldIndices : string or cell vector of strings.
            
            if nargin < 2
                res = me.v;
                return;
            end
            
            [ixRow, ixCol] = getIx(me, varargin{:});
            
            res = me.v(ixRow, ixCol);
        end
        
        
        function res = getPsyMat(me, varargin)
            % Mat.getPsyMat
            % Mat.getPsyMat(rowIndices);
            % Mat.getPsyMat(fieldIndices);
            % Mat.getPsyMat(rowIndices, fieldIndices)
            %
            % rowIndices   : either numeric or logical indices.
            % fieldIndices : string or cell vector of strings.
            
            if nargin < 2
                res = copy(me);
                return;
            end
            
            [ixRow, ixCol] = getIx(me, varargin{:});
            
            res = PsyMat(me.fields(ixCol), me.v(ixRow, ixCol));
        end
        
        
        function me = set(me, varargin)
            % Mat.set(mat);
            % Mat.set(rowIndices, mat);
            % Mat.set(fieldIndices, mat);
            % Mat.set(rowIndices, fieldIndices, mat)
            %
            % rowIndices   : either numeric or logical indices.
            % fieldIndices : string or cell vector of strings.
            % mat          : scalar, 1 x numField vector, or matrix.
            
            [ixRow, ixCol, nRow, nCol] = getIx(me, varargin{1:(end-1)});
            
            siz = size(varargin{end});
            
            if all([nRow nCol] == siz)
                me.v(ixRow, ixCol) = varargin{end};
                
            elseif (siz(1) == 1) && ((siz(2) == 1) || (siz(2) == nCol))
                me.v(ixRow, ixCol) = rep2fit(varargin{end}, [nRow, nCol]);
            else
                error(['mat should be either scalar, 1 x numfield vector, or ' ...
                       'matrix of a matching size!']);
            end
        end
        
        
        function ix = ixCol(me, fields)
            ix = strcmpfinds(fields, me.fields);
        end
        
        
        function tf = tfCol(me, fields)
            tf = strcmps(fields, me.fields);
        end
        
        
        function disp(me)
            disp(me.fields);
            disp(me.v);
        end
    end
end