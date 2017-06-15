function varargout = logistic_w_miss(op, X, y, varargin)
% [b, dev, stat] = logistic_w_miss('fit', X, y, ...)
% v = logistic_w_miss('pred', X, b, ...)
% cost = logistic_w_miss('cost', X, y, 'b', ....)
%
% b : [bias, slope, miss, miss_bias]
%
% OPTIONS
% -------
% 'miss', false
% 'miss_bias', false
%
% 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.

S = varargin2S(varargin, {
    'bias', 0
    'bias_min', -1
    'bias_max', 1
    'slope', 0
    'slope_min', 0
    'slope_max', 50
    'miss', 0.01
    'miss_min', eps
    'miss_max', 1 - eps
    'miss_bias', 0.5
    'miss_bias_min', 0
    'miss_bias_max', 1
    'b', []
    });

switch op
    case 'fit'
        if ~isnan(S.miss)
            if ~isnan(S.miss_bias)
                error('Not implemented yet!');
            else
                C  = S2C(rmfield(S, 'b'));
%                 res = fminconMult(@(b) logistic_w_miss('cost', X, y, ...
%                     'b', b, C{:}), {
%                     'bias', S.bias, S.bias_min, S.bias_max
%                     'slope', 
                    });
            end
        else
            [varargout{1:nargout}] = glmfit(X, y, 'binomial');
        end
        
    case 'pred'
        pred = invLogit(S.bias + S.slope * X);
        pred = (1 - S.miss) + S.miss * S.miss_bias;
        pred = [1-pred(:), pred(:)];
        n    = length(pred);
        ix   = sub2ind([n, 2], (1:n)', y(:)+1);
        cost = -sum(log(pred(ix)));
        
    case 'cost'
end