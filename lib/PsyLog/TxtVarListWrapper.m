classdef TxtVarListWrapper < handle
    properties
        L_ = [];
    end
    
    methods
        function Lst = TxtVarListWrapper(List)
            % Gives a wrapper of a TxtVarList so that
            % the values can be referred to and be changed like
            % a regular struct.
            %
            % Lst = TxtVarListWrapper(List)
            %
            % See also: TxtVarList
            
            Lst.L_ = List;
        end
        
        function v = subsref(Lst, S)
            assert(isequal(S(1).type, '.'), 'First reference should be .');
            
            if length(S) == 1
                v = Lst.L_.L.(S(1).subs).v;
            else
                v = subsref(Lst.L_.L.(S(1).subs).v, S(2:end));
            end
        end
        
        function Lst = subsasgn(Lst, S, v)
            assert(isequal(S(1).type, '.'), 'First reference should be .');
            
            c_L_ = Lst.L_;
                
            if length(S) == 1
                assert(isfield(c_L_.L, S(1).subs), 'No rows with the name %s!', S(1).subs);
                change_var(c_L_, 'set', S(1).subs, v);
            else
                c_L_ = Lst.L_;
                
                change_var(c_L_, 'set', S(1).subs, ...
                    subsasgn(c_L_.L.(S(1).subs).v, S(2:end), v));
            end
        end
        
        function disp(Lst)
            disp(v2S(Lst));
        end
        
        function S = v2S(Lst)
            % Gives a struct of v's.
            
            C = cell2mat(struct2cell(Lst.L_.L));
            S = cell2struct({C.v}, {C.name}, 2);
        end
        
        function S2v(Lst, S)
            % Assigns struct fields to Lst
            
            copyFields(Lst, S);
        end
    end
    
    methods (Static)
        function Lst = test
            Lst = TxtVarListWrapper(TxtVarList.test(true));
        end
    end
end