classdef PsyCell < PsyMat
    methods
        function me = PsyCell(fields, n)
            me = me@PsyMat(fields, n);
        end
        
        function setVDefault(me, n)
            me.v = cell(n, me.nCol);
        end
        
        function me = addCol(me, col)
            me.fields = [me.fields, {col}];
            me.v(me.n, me.nCol) = [];
        end
        
        function res = getPsyCell(me, varargin)
            % Mat.getPsyCell
            % Mat.getPsyCell(rowIndices);
            % Mat.getPsyCell(fieldIndices);
            % Mat.getPsyCell(rowIndices, fieldIndices)
            %
            % rowIndices   : either numeric or logical indices.
            % fieldIndices : string or cell vector of strings.
            
            if nargin < 2
                res = copy(me);
                return;
            end
            
            [ixRow, ixCol] = getIx(me, varargin{:});
            
            res = PsyCell(me.fields(ixCol), me.v(ixRow, ixCol));
        end
    end
end