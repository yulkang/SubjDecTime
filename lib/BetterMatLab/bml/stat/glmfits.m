function S = glmfits(x, yAll, varargin)
% S = glmfits(x, yAll, varargin)
%
% yAll: one y per column.
% S: an array of output struct from glmwrap. Contains b, dev, stats, p, se.
%
% See also: glmfit

% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

n = size(yAll, 2);
if n > 100 && ~is_in_parallel
    pool = gcp;
    nw = pool.NumWorkers;
    for ii = nw:-1:1
        ix = floor((0:(n - 1)) / n * nw) == (ii - 1);
        ys{ii} = yAll(:, ix);
    end
    parfor jj = 1:nw
        Ss{jj} = arrayfun(@(ii) ...
            glmwrap(x, ys{jj}(:,ii), varargin{:}), 1:size(ys{jj},2));
    end
    S = hVec([Ss{:}]);
else
    S = arrayfun(@(ii) glmwrap(x, yAll(:,ii), varargin{:}), 1:size(yAll,2));
end