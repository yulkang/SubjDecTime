classdef PsyMapMultijective
    properties
        nam = {}
        C   = {}
    end
    
    methods
        function Map = PsyMapMultijective(C)
            Map.nam = C(1,:);
            Map.C   = C(2:end,:);
        end

        % Returns a cell array
        function [res, tf] = Q(Map, col_idx, idx, col_res)
            tf  = cellfun(@(v) isequal(v, idx), Map.C(:,Map.col(col_idx)));
            res = Map.C(tf, Map.col(col_res));
        end

        % Returns the contents of a cell
        function [res, tf] = q(Map, col_idx, idx, col_res)
            tf  = cellfun(@(v) isequal(v, idx), Map.C(:,Map.col(col_idx)));
            res = Map.C{tf, Map.col(col_res)};
        end

        % Returns a matrix
        function [res, tf] = qq(Map, col_idx, idx, col_res)
            tf  = cellfun(@(v) isequal(v, idx), Map.C(:,Map.col(col_idx)));
            res = [Map.C{tf, Map.col(col_res)}];
        end

        function tf = col(Map, s)
            tf = strcmp(s, Map.nam);
        end
    end
end