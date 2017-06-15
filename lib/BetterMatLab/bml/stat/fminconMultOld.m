function S  = fminconMult(fun, data, opt, initVar, iterVar)
% S  = fminconWrap(fun, data, opt, paramName1, paramGuess1, paramMin1, paramMax1, ...)
%
% Try multiple guesses

if ~exist('opt', 'var') || isempty(opt)
    opt = {'display', 'iter', 'outputfcn', @outfun}; 
end
sOpt = optimset(opt{:});

S = struct;
S.paramName   = initVar(1:4:end);
S.paramGuess  = cell2mat(initVar(2:4:end));
S.paramMin    = cell2mat(initVar(3:4:end));
S.paramMax    = cell2mat(initVar(4:4:end));

cFun    = @(a1) fun(a1, data);

cNLL   = inf;
cParam = S.paramGuess(1,:);

for iIter = 1:length(iterVar)
    cIter = iterVar{iIter};
    
    for cVar = cIter'
        S.
    end
        
    
    cParamGuess = cParam; % S.paramGuess(1, :);
    cParamMin   = S.paramMin(1, :);
    cParamMax   = S.paramMax(iGuess, :);
    
%     toUsePrev   = isnan(cParamGuess);
%     cParamGuess(toUsePrev) = cParam(toUsePrev);
    
    p = length(S.paramName);
    
    [param, fVal, exitFlag, output, lambda, grad, hess] = ...
        fminconWrap(cFun, cParamGuess, cParamMin, cParamMax,sOpt);
    
    if fVal < cNLL
        cNLL        = fVal;
        cParam      = param;
        
        S.fVal      = fVal;
        S.exitFlag  = exitFlag;
        S.output    = output;
        S.lambda    = lambda;
        S.grad      = grad;
        S.hess      = hess;
    end
end

S.param = cell2struct(hVec(num2cell(cParam)), hVec(S.paramName), 2);
S.paramSE = cell2struct(hVec(num2cell(diag(inv(S.hess)))), ...
                        hVec(S.paramName), 2);
[~, S.pred] = fun(param, data);
                    
    function stop = outfun(x, ~, state)
        persistent predY hPred

        stop = false;

        switch state
            case 'init'
                cla;
                plotData; hold on;
                [~, predY] = fun(x, data);
                predY = sort(predY);
                
                hPred = plot(sort(data(:,1)), predY, '-');
                set(hPred, 'YDataSource', 'predY');
                
            case 'iter'
                [~, predY] = fun(x, data);
                predY = sort(predY);
                refreshdata(hPred, 'caller');
                
                disp(hVec(x));

            case 'done'
                hold off

            otherwise
        end

        function plotData
            winSize = (max(data(:,1)) - min(data(:,1)))/10;
            
            [yMean ySEM xSort] = runningMean(data(:,1), data(:,3), ...
                [-winSize, winSize], 5);
            
            errorbarShade(xSort, yMean, ySEM);
        end
    end
end