function ts = alignTS(ts, alignTo, dt)
% ALIGNTS Zero and resample using regular interval.
%
% ts = alignTS(ts, alignTo, dt)

if ~exist('alignTo', 'var')
    alignTo = [];
end

if isempty(alignTo)
    t = ts.Time(1):dt:ts.Time(end);
    
elseif alignTo == -inf
    ts.Time = ts.Time - ts.Time(1);
    t = 0:dt:ts.Time(end);
    
else
    ts.Time = ts.Time - alignTo;
    
    stIx = round(ts.Time(1)/dt);
    enIx = round(ts.Time(end)/dt);
    
    t = (stIx:enIx)*dt;
end
ts = resample(cTS, t);