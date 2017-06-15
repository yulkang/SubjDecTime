function est = bayesLeastSq(src, varargin)
% est = bayesLeastSq(src, varargin)
%
% Implements a variant of Jazayeri & Shadlen 2010's Bayes least square.
% Assumes bayesLeastSq in the sensory estimation, and MAP in the motor production.
% 
% 2015. Implemented by YK.

%% Test
if nargin == 0 || (ischar(src) && strcmp(src, 'test'))
    dv  = 0.005;
    v   = (0:dv:1)';
    sd  = 0.1;
    src = repmat([normpdf(v, 0.1, sd), normpdf(v, 0.3, sd)], [1 1]); %  [1 20]); % 
    src = bsxfun(@rdivide, src, sum(src));
    es = bayesLeastSq(src, 'v', v, 'sd', sd, 'sd_prod', dv*30); % 0); %  0.05);
    
    plot(v, src, 'b');
    hold on;
    plot(v, es, 'r');
    disp(sum(es) ./ sum(src))
    legend({'src', 'est'});
    hold off;
    
    if nargout >= 1, est = es; end
    return;
end    

%% Handle arrays
if ~isvector(src)
    siz = size(src);
    n = siz(1);
    m = numel(src) / n;
    
    est = zeros(siz);
    for ii = 1:m
        est(:,ii) = bayesLeastSq(src(:,ii), varargin{:});
    end
    
    % cellfun is not faster
%     src = mat2cell(reshape(src, n, []), n, ones(1, m));
%     est = cellfun(@(v) bayesLeastSq(v, varargin{:}), src, 'UniformOutput', false);
%     est = cell2mat(est);
%     est = reshape(est, siz);
    return;
end

%% Vectors
S = varargin2S(varargin, {
    'v',     []
    'mean',  0
    'sd',    1
    'mean_prod', 0
    'sd_prod', [] % production error
    'vectorize', true % false % 
    });
assert(isscalar(S.sd));

if isrow(src)
    permuted = true;
    src = src';
else
    permuted = false;
end

n = length(src);
if isempty(S.v)
    v = (1:n)';
else
    v = S.v(:);
end
dv = v(2) - v(1);
if isempty(S.sd_prod)
    S.sd_prod = dv; % 0 is faster but has more discretization error.
end

if S.vectorize % >10x faster
    assert(v(1) == 0);
    v  = v(:);
    dv = v(2) - v(1);
    v2 = [flipud(-v); v(2:end)];
    nv = length(v);
    
    p0 = pmf(@normcdf, v2(:), S.mean, S.sd);
    
    % arrayfun is actually slower
%     es = arrayfun(@(ii) use(p0(nv - ii + (1:nv)), @(p) sum(v .* p) ./ sum(p)), (1:n)');
    es = zeros(size(src));
    for ii = 1:n
        p = p0(nv - ii + (1:nv));
        es(ii) = sum(v .* p) / sum(p);
    end
    es(isnan(es)) = 0; % DEBUG, FIXIT
    
    lv = bsxfun(@minus, v, es(:)');
    l  = normpdf(lv, S.mean_prod, S.sd_prod) * dv;
%     l  = exp(-(lv / (2 * S.sd_prod)).^2); % Not faster
%     l  = pmf(@normcdf, lv, S.mean_prod, S.sd_prod); % Slower
    l  = bsxfun(@times, l, src(:)' ./ sum(l));
    est = sum(l, 2);
    
else
    est = zeros(size(src));
    for ii = 1:n
        p = pmf(@normcdf, v(:), v(ii), S.sd); % diff(normcdf([v(1) - dv/2, v(:)' + dv/2], v(ii), S.sd));
    %     p  = normpdf(v, v(ii), S.sd);
        es = sum(v .* p) / sum(p);

        if S.sd_prod == 0
            % Delta function
            ix = find(v < es, 1, 'last');
            d1 = es - v(ix);
            d2 = v(ix + 1) - es;
            est(ix - 1) = est(ix - 1) + src(ii) * d2 / (d1 + d2);
            est(ix)     = est(ix)     + src(ii) * d1 / (d1 + d2);
        else
            l = pmf(@normcdf, v, es, S.sd_prod);
            est = est + l / sum(l) * src(ii);
        end
    end
end

if permuted
    est = est';
end
