%% Setup
dt_dst = 0.5;
max_t_dst = 2.5;
Time_dst = TimeAxis.TimeRegularPositive('dt', dt_dst, 'max_t', max_t_dst);
t_dst = 0:dt_dst:max_t_dst;

y_src = {
    [5, 6]
    [10, 12, 13]
    };
dt_src = 1;
max_len = max(cellfun(@length, y_src));
t_src = dt_src * (0:(max_len - 1));

Ts = TimeAxis.TimeSeriesSorterInterpolable(Time_dst, y_src, dt_src);

res = [5, 5.5, 6, nan, nan, nan; 10, 11, 12, 12.5, 13, nan];

%% ts_mat - align at the beginning
assert(isequaln(Ts.get_ts_mat, res));

%% ts_mat - align at the end
assert(isequal(Ts.get_ts_mat( ...
    't_dst', [-0.5, 0], ...
    'rows', ':', ...
    't0', Ts.get_t0_end), ...
    [5.5, 6; 12.5, 13]));
