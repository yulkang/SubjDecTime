function S = glmwrap(X, y, distr, varargin)
% S = glmwrap(X, y, varargin)
%
% S: has b, dev, stats, p, se, nll

if isempty(y)
    m = size(X, 2) + 1;
    b = nan(1,m);
    p = nan(1,m);
    se = nan(1,m);
    stats = packStruct(p, se);
    dev = nan;
    nll = nan;
    bic = nan;
else
    [b, dev, stats] = glmfit(X, y, distr, varargin{:});
    p = stats.p;
    se = stats.se;

    switch distr
        case 'binomial'
            pred = glmval(b, X, 'logit', stats);
            if isvector(y)
                try
                    nll  = -sum(log(binopdf(y, 1, pred)));
                catch err
                    warning(err_msg(err));
                    nll  = nan;
                end
            else
                nll = nan;
            end
        otherwise
            nll  = nan;
    end
    
    bic = bml.stat.bic(nll, size(X, 1), size(X, 2) + 1);
end

S = packStruct(b, dev, stats, p, se, nll, bic); % , X, y, distr);