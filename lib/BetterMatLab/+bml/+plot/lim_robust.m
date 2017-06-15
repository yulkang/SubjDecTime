function lim_robust(varargin)
S = varargin2S(varargin, {
    'ax', gca
    'xy', 'y'
    'prop', 0.025
    'margin', 0.1
    'data', []
    });

lim_ix = find(upper(S.xy) == 'XY');
lim_name = [upper(S.xy), 'Lim'];
if isempty(S.data)
    data = bml.plot.get_all_xy(S.ax);
    data = data(:,lim_ix);
else
    data = S.data;
end

data_lim = [min(data), max(data)];
data_most = prctile(data, [S.prop * 100, (1 - S.prop) * 100]);
if data_most(2) - data_most(1) <= 0
    data_most(2) = data_most(1) + eps;
end
data_range = diff(data_most);

lim(1) = max(data_most(2) - data_range * (1 + S.margin), data_lim(1));
lim(2) = min(data_most(1) + data_range * (1 + S.margin), data_lim(2));

set(S.ax, lim_name, lim);
end