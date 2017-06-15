function ts = diffTS(ts, ord)
% DIFFTS diff() for timeseries objects.
%
% ts = diffTS(ts, ord)

if ~exist('ord', 'var'), ord = 1; end

t       = ts.Time(1:(end-1));
if ts.IsTimeFirst
    d       = diff(ts.Data, ord, 1);
else
    d       = diff(ts.Data, ord, ndims(ts.Data));
end

ts      = delsample(ts, 'Index', 1);
ts.Time = t;
ts.Data = d;
return;