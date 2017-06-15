function [res, dist] = randSamp(varargin)
% randSamp(r, dist)
%
%     dist.dist == 'dis'|'discrete'
%       dist.vec
%       dist.w    : weight. Defaults to uniform.
%
%     randSamp(dist, n_row=1, with_replacement=true)
%
%     dist.dist == 'uni'|'uniform'
%       dist.min
%       dist.max
%
%     randSamp(dist, size)
% 
%     dist.dist == 'exp'|'exponential'
%       dist.min
%       dist.max
%       dist.avg
%
%     randSamp(dist, size)
%
% randSamp(r, 'dist', dist, 'min', min, 'max', max, ['avg', avg])

if isa(varargin{1}, 'RandStream') || isempty(varargin{1})
    r_cell = varargin(1);
    varargin = varargin(2:end);
else
    r_cell = {};
end

if isstruct(varargin{1})
    dist = varargin{1};
elseif iscell(varargin{1})
    dist = varargin2S(varargin{1});
else
    dist = varargin2S(varargin);
    varargin = {};
end

switch dist.dist
    case {'dis', 'discrete'}
        if ~isfield(dist, 'w')
            dist.w = ones(1, length(dist.vec));
        end
        if length(varargin) < 2
            varargin{2} = 1;
        end
        if length(varargin) < 3
            varargin{3} = true;
        end
        
        res = randsample(r_cell{:}, dist.vec, varargin{2:3}, dist.w);
        
    case {'uni', 'uniform'}
        res = dist.min + rand(r_cell{:}, varargin{2:end}) .* (dist.max-dist.min);
        
    case {'exp', 'exponential'}
        res          = inf + zeros(varargin{2:end});
        res_over_max = @(c_res) c_res > dist.max;
        
        while any(res_over_max(res))
            res(res_over_max(res)) = ...
                dist.min + exprnd(dist.avg - dist.min, varargin{2:end});
        end
end