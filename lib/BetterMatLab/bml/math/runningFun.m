function [yRes ySE xSort nInRes ySort] = runningFun(fun, xDat, yDat, xRange, ...
                                                     nThres, xVec)
    % RUNNINGFUN   Function evaluated within the given x range.
    %           
    % Will be slower than more specific functions, e.g., runningMean. Use
    % more specific functions if available.
    % 
    % [yRes ySE xSort nInRes] = runningFun(fun, xDat, yDat, xRange, ...
    %                                      nThres, xSt, xStep)
    %
    % yDat   : P x N matrix. P: number of parameters, N: number of time points.
    % fun    : should get an x and a y vector in each window of x
    %          and return [estimate, SE] as the first two outputs.
    %          each of estimate and SE can be a vertical vector, to provide
    %          multiple estimates per window location.
    % xRange : [xRangeLeft xRangeRight]
    %
    % See also: VEC4RUNNINGMEAN

    [xSort ixSort] = sort(xDat);
    ySort  = yDat(:,ixSort);

    if ~exist('xVec', 'var')
        xVec = xSort; % Run at every point.
    else
        xVec = sort(xVec); 
    end 
    
    N       = length(xVec);
    
    cLoc    = 1;
    cHead   = 1; cHead = nextHead;
    cTail   = 1;
    
    cTail   = nextTail;
    
    [res1]  = fun(xSort(cHead:cTail), ySort(cHead:cTail,:));
    
    nResPerLoc = length(res1);
    
    yRes    = zeros(nResPerLoc, size(yDat));
    ySE    = zeros(nResPerLoc, size(yDat));
    
    nInRes  = zeros(1,N);
    
    for cLoc = 1:N
        cHead = nextHead;
        cTail = nextTail;
        cN    = cHead - cTail + 1;
                            
        [yRes(:,cLoc) ySE(:,cLoc)] = fun(xSort(cTail:cHead), ySort(:,cTail:cHead));
        
        nInRes(cLoc) = cN;
    end
    
    if exist('nThres', 'var')
        filt    = nInRes >= nThres;
        
        yRes    = yRes(:,filt);
        ySE    = ySE(:,filt);
        xSort   = xSort(filt);
        ySort   = ySort(:,filt);
    end
    
    function nHead = nextHead
        nHead   = cHead - 1 + find(xSort(cHead:end) <= xVec(cLoc)+xRange(2), ...
                                   1, 'last');
    end
    
    function nTail = nextTail
        nTail   = cTail - 1 + find(xSort(cTail:cHead) >= xVec(cLoc)+xRange(1), ...
                                   1, 'first');
    end
end
