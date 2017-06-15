classdef LogitWithMiss < FitWorkspace
properties
    X
    y
    Fl
end
methods
    function W = LogitWithMiss
        
    end
    %% Mimic glmfit
    function [b, dev, stats] = fit(W, X, y)
        [X, y] = LogitWithMiss.parse_Xy(X, y);
        W.X = X;
        W.y = y;
    end
    function [X, y] = parse_Xy(X, y)
        assert(size(X, 1) == size(y, 1));
        assert(ismatrix(X) && isnumeric(X));
        assert(ismatrix(y));
        if islogical(y)
            assert(iscolumn(y));
            
            % collect for each unique X
            X0 = X;
            y0 = double(y);
            
            [X, ~, ix] = unique(X0, 'rows');
            n_ix = max(ix);
            y = zeros(n_ix, 2);
            
            for ii = 1:n_ix
                matching_rows = ix == ii;
                y(ii,1) = mean(y0(matching_rows));
                y(ii,2) = nnz(matching_rows);
            end
        else
            assert(isnumeric(y) && size(y, 2) == 2);
            assert((all(y(:)) >= 0) && all(y(:,1) <= 1));
            % That is it.
        end
    end
    function dev = get_dev(W)
    end
    function stats = get_stats(W)
    end
    %% FitFlow interface
    function pred(W)
        
    end
    function cost = calc_cost(W)
        
    end
end
end