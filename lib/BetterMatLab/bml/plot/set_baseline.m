function h = set_baseline(xy, varargin)
if verLessThan('matlab', '8.4')
    warning('set_baseline is not supported for MATLAB version < 8.4! Skipping.');
    return;
end

h = get(gca, [upper(xy) 'BaseLine']);
set(h, varargin{:});
