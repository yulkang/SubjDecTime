function ts = smoothTS(ts, varargin)
% smoothTS  smooth timeseries.

% ts = idealfilter(ts, varargin{:});

for ii = 1:size(ts.Data, 2)
    ts.Data(:,ii) = smooth(ts.Data(:,ii), varargin{:});
end