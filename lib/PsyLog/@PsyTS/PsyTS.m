classdef PsyTS
    properties
        tOrig % matrix of time.
        dOrig % cell array of data.
        
        n % number of timeseries.
        
        t % unified time vector.
        d % interpolated data. A double array with (x,y,t,timeseries) dimensions.
        
        dt % time step size.
    end 
    
    properties (Dependent)
        tSt
        tEn
        nonEmpty % whether a given time series is empty or not.
        
        nT % Number of trials available for each time point.
    end
    
    methods
        function me = PsyTS(tOrig, dOrig)
            if ~iscell(tOrig), error('tOrig should be a cell array!'); end
            if ~iscell(dOrig), error('dOrig should be a cell array!'); end
            if length(tOrig)~=length(dOrig), error('tOrig and dOrig should have the same length!'); end
                
            me.tOrig = tOrig;
            me.dOrig = dOrig;
            
            me.n = length(tOrig);
        end
        
        function me = unifyT(me, dt, atLeast, minMin, maxMax)
            if ~exist('atLeast', 'var'), atLeast = 1; end
            if atLeast > me.n, error('We have less than %d trials!', atLeast); end
            
            if ~exist('minMin', 'var'), minMin = -inf; end
            if ~exist('maxMax', 'var'), maxMax = inf; end
            
            tSt = me.tSt(:)';
            tEn = me.tEn(:)';
            
            tSt = tSt(~isnan(tSt));
            tEn = tEn(~isnan(tEn));
            
            tMins = sort(tSt);
            tMaxs = sort(tEn, 2, 'descend');
            
            tMin = max(tMins(atLeast), minMin);
            tMax = min(tMaxs(atLeast), maxMax);
            
            if tMin > tMax, error('We have less than %d trials per time point!', atLeast); end
            
            me.dt = dt;
            me.t  = tMin:dt:tMax;
        end
        
        
        function me = resample(me)
            parfor ii = 1:me.n
                ts(ii) = timeseries(me.dOrig{ii}, me.tOrig{ii});
                ts(ii) = resample(ts(ii), me.t);
            end
            
            me.d  = PsyTS.catData(ts);
        end
        
        function res = get.tSt(me)
            res     = nan(me.n, 1);
            ne      = me.nonEmpty;
            res(ne) = cellfun(@(v) v(1), me.tOrig(ne));
        end
        
        function res = get.tEn(me)
            res     = nan(me.n, 1);
            ne      = me.nonEmpty;
            res(ne) = cellfun(@(v) v(end), me.tOrig(ne));
        end
        
        function res = get.nT(me)
            
        end
        
        function res = get.nonEmpty(me)
            res = ~cellfun(@isempty, me.tOrig);
        end
    end
    
    methods (Static)
        function dMat = catData(tsVec, dim)
            if ~exist('dim', 'var'), dim = 4; end
            
            dCell = reshape2vec({tsVec.d}, dim);
            
            dMat = cell2mat(dCell);
        end
    end
end