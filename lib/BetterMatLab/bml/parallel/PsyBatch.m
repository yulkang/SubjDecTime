classdef PsyBatch < handle
    properties
        S    = {};
        in   = {};
        f    = {};
        n    = 0;
        parallel = true;
    end
    
    methods
        function me = PsyBatch(f, varargin)
            me.f = f;
            
            if ~isempty(varargin)
                me = varargin2fields(me, varargin);
            end
        end
        
        function add(me, in, varargin)
            me.n = me.n + 1;
            
            for i_arg = 1:length(varargin)
                me.S{me.n, i_arg}  = substruct(varargin{i_arg}{:});
            end
            me.in{me.n} = in;
        end
        
        function varargout = run(me)
            c_out = cell(1, me.n);
            n_out = nargout;
            
            if me.parallel
                parfor ii = 1:me.n
                    [c_out{ii}{1:n_out}] = me.f(me.in{ii}{:});
                end
            else
                for ii = 1:me.n
                    [c_out{ii}{1:n_out}] = me.f(me.in{ii}{:});
                end
            end
            
            varargout = cell(1, max(n_out));
            
            if n_out > size(me.S, 2)
                for ii = 1:me.n
                    for jj = 1:n_out
                        varargout{jj} = subsasgn(varargout{jj}, me.S{ii, 1}, c_out{ii}{jj});
                    end
                end
            else    
                for ii = 1:me.n
                    for jj = 1:n_out
                        varargout{jj} = subsasgn(varargout{jj}, me.S{ii, jj}, c_out{ii}{jj});
                    end
                end
            end
        end
    end
end

