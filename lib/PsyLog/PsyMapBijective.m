classdef PsyMapBijective
    properties
        C = {};
    end
    
    methods
        function Bij = PsyMapBijective(C)
            % Bij = PsyMapBijective(C)
            %
            % C: N x 2 cell array
            %    (If N x 1 cell array, L is assumed to be a 1:N column
            %    vector)
            
            if size(C,2) == 1, C = [num2cell(1:length(C))', C]; end
            Bij.C = C;
        end
        
        function [R, tf] = L2R(Bij, L)
            % [R, tf] = L2R(Bij, L)
            tf = cellfun(@(v) isequal(v, L), Bij.C(:,1));
            
            if nnz(tf) == 1
                R  = Bij.C{tf,2};
            elseif ~any(tf)
                error('No corresponding L!');
                % R  = [];
            else
                error('Not bijective!');
            end
        end
        
        function [L, tf] = R2L(Bij, R)
            % [L, tf] = R2L(Bij, R)
            tf = cellfun(@(v) isequal(v, R), Bij.C(:,2));
            L  = Bij.C(tf,1);
            
            if nnz(tf) == 1
                L  = Bij.C{tf,1};
            elseif ~any(tf)
                error('No corresponding R!');
                % L  = [];
            else
                error('Not bijective!');
            end
        end
    end
    
    methods (Static)
        function Bij = test
            Bij = PsyMapBijective({
                0, 'N'
                90, 'E'
                180, 'S'
                270, 'W'
                });
        end
    end
end
