classdef RandReplicable < DeepCopyable
    % Caches and yields replicable samples from RandStream.
    %
    % USAGE:
    % r = rand(Rep, ...)
    %
    % 2016 (c) Yul Kang. hk2699 at columbia dot edu.
properties
    R = [];
    seed = [];
    args_bef = [];
end
properties (Transient)
    samp = [];
end
methods
    function Rep = RandReplicable(varargin)
        Rep.add_deep_copy({'R'});
        varargin2props(Rep, varargin);
    end
    
    function R = get.R(Rand)
        if isempty(Rand.R)
            Rand.R = RandStream('mt19937ar', 'Seed', Rand.seed);
        end
        R = Rand.R;
    end
    
    function seed = get.seed(Rep)
        if isempty(Rep.seed)
            R0 = RandStream('mt19937ar', 'Seed', 'shuffle');
            Rep.seed = rand2seed(rand(R0));
        end
        seed = Rep.seed;
    end
    
    function shuffle(Rep)
        Rep.seed = [];
        Rep.samp = [];
        Rep.args_bef = [];
    end

    function v = rand(Rep, varargin)
        if isequal(Rep.args_bef, varargin)
            v = Rep.samp;
        else
            reset(Rep.R, Rep.seed);
            v = rand(Rep.R, varargin{:});
            Rep.args_bef = varargin;
            Rep.samp = v;
        end
    end
end
end