classdef PsyDistrib
%     Dist = PsyDistrib(dist, 'param1', param1, ...)
%     Dist = PsyDistrib('mix', {{dist1, ...}, {dist2, ...}}, [p1, p2, ...])
%
%     Dist.dist == 'con'|'constant'
%       param.vec
%
%     Dist.dist == 'dis'|'discrete'
%       param.vec
%       param.w    : weight. Defaults to uniform.
%     randSamp(Dist, n_row=1, with_replacement=true)
%
%     Dist.dist == 'uni'|'uniform'
%       param.min = 0
%       param.max = 1
%       param.int = false
%     randSamp(Dist, size)
% 
%     Dist.dist == 'exp'|'exponential'
%       param.min = 0
%       param.max = inf % truncated at max.
%       param.avg = 1   % lambda is avg - min.
%     randSamp(Dist, size)

    properties
        dist = '';
        
        min
        max
        avg
        
        int
        
        vec
        w
        
        n_bin   % Number of strata
        vec_min % Minimum of each stratum
        vec_max % Maximum of each stratum

        % Mixture distributions
        dist_mix = []; % probability to choose each distribution
        mix   = {}; % cell array of component distributions
    end
    
    properties (Constant)
        % Seed in the range accepted by rng().
        MATLAB_SEED_ARG = {'uni', 'min', 1, 'max', 4e9+1, 'int', true};
    end
    
    methods
        function me = PsyDistrib(dist, varargin)
            % Set defaults
            switch dist
                case {'mix', 'mixture'}
                    dist = 'mix';
                
                case {'con', 'constant'}
                    dist = 'con';
                    
                case {'dis', 'discrete'}
                    dist = 'dis';
                    
                case {'uni', 'uniform'}
                    dist = 'uni';
                    
                    me.min = 0;
                    me.max = 1;
                    me.int = false;
                    
                case {'str_uni', 'stratified_uniform'}
                    dist = 'str_uni';
                    
                    me.min = 0;
                    me.max = 1;
                    me.n_bin = 3;
                    
                case {'exp', 'exponential'}
                    dist = 'exp';
                    
                    me.min = 0;
                    me.max = inf;
                    me.avg = 1;
            end
            
            % Receive properties
            me.dist = dist;
            
            if strcmp(dist, 'mix')
                n = length(varargin{1});
                
                if length(varargin) >= 2
                    p = varargin{2};
                else
                    p = zeros(1,n) + 1 / n;
                end
                me.dist_mix = PsyDistrib('dis', 'vec', 1:n, 'w', p);
                
                for ii = n:-1:1
                    me.mix{ii} = PsyDistrib(varargin{1}{ii}{:});
                end
            else
                me = varargin2fields(me, varargin);

                % Postprocess properties. Calculate temporary variables
                switch dist
                    case 'str_uni'
                        v = linspace(me.min, me.max, me.n_bin + 1);
                        me.vec_min = v(1:(end-1));
                        me.vec_max = v(2:end);
                end
            end
        end
        
        function [res, me] = randSamp(me, varargin)
        % Dist.dist == 'con'|'constant'
        %   param.vec
        % 
        % Dist.dist == 'dis'|'discrete'
        %   param.vec
        %   param.w    : weight. Defaults to uniform.
        % randSamp(Dist, size, with_replacement=true)
        % 
        % Dist.dist == 'uni'|'uniform'
        %   param.min = 0
        %   param.max = 1
        %   param.int = false
        % randSamp(Dist, size)
        % 
        % Dist.dist == 'exp'|'exponential'
        %   param.min = 0
        %   param.max = inf
        %   param.avg = 1
        % randSamp(Dist, size)
            
            if ~isempty(varargin) && isa(varargin{1}, 'RandStream')
                r = varargin(1);
                varargin(1) = [];
            else
                r = {};
            end
            
            switch me.dist
                case {'con', 'constant'}
                    res = me.vec + zeros(varargin{:});
                    
                case {'dis', 'discrete'}
                    if length(varargin) < 1
                        siz = [1 1];
                        varargin{1} = 1;
                    elseif length(varargin{1}) == 1
                        siz = [varargin{1}, 1];
                    else
                        siz = varargin{1};
                        varargin{1} = prod(siz);
                    end
                    if length(varargin) < 2
                        varargin{2} = true;
                    end 
                    if length(varargin) > 2
                        error('Too many arguments!');
                    end
                    
                    if isscalar(me.vec)
                        res = me.vec + zeros(1,varargin{1});                        
                    else
                        if ~isprop(me, 'w')
                            res = randsample(r{:}, me.vec, varargin{:});
                        else
                            res = randsample(r{:}, me.vec, varargin{:}, me.w);
                        end
                    end
                    
                    res = reshape(res, siz);
                    
                case {'uni', 'uniform'}
                    res = me.min ...
                        + rand(r{:}, varargin{:}) .* (me.max-me.min);

                    if me.int
                        res = floor(res);
                    end
                    
                case {'exp', 'exponential'}
                    if isinf(me.max) && me.max > 0
                        res = exprnd(me.avg - me.min, varargin{:}) + me.min;
                    else % truncate
                        res = mod(...
                                  exprnd(me.avg - me.min, varargin{:}), ...
                                  me.max-me.min) ...
                              + me.min;
                    end
                    
                case 'str_uni'
                    error('Not implemented yet!');
                    % TODO
                    
                case 'mix'
                    distr_ix = me.dist_mix.randSamp(r{:}, varargin{:});
                    
                    res = arrayfun(@(ii) randSamp(me.mix{ii}, r{:}, 1, varargin{2:end}), distr_ix);
            end
        end
    end
    
    methods (Static)
        function me = MATLAB_seed
            me = PsyDistrib('uni', 'min', 1, 'max', 4e9+1, 'int', true);
        end
    end
end