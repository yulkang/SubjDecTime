classdef PsyDataset
    properties
        d = struct;
        len = 0;
        default = struct;
    end

    methods
        function me = subsasgn(me, S, val)
            % ds(numeric, numeric_scalar) = val
            % ds(numeric, char) = val
            % ds(numeric, :) = val
            % ds.(char)(numeric) = val
            % ds.(char) = val
            
            switch S(1).type
                case '.'
                    if length(S) == 1
                        me.d.(S(1).subs) = val;
                        if size(val,1) > me.len
%                             lengthen(me, size(val,1), S(1).subs);
                        else
                        end
                    else
                    end
                case '()'
                otherwise
                    error('First index should be () or dot');
            end
        end
        
        function disp(me)
            f = fieldnames(me.d);
            disp_cell = cell(me.len+1, length(f));
            
            disp_cell(1,:) = f;
            disp_cell(2:end,:) = [];
            
            disp(disp_cell);
        end
    end
end