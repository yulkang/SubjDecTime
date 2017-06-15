function colormap_nan(varargin)
% Sets palette such that NaNs are white
%
% 'h_img', []
% 'h_col', []
% 'bkg', [1 1 1] % Background color

%%
S = varargin2S(varargin, {
    'h_img', []
    'h_col', []
    'bkg', [1 1 1] % Background color
    });

%%
if isempty(S.h_img)
    h_img = findobj(gcf, 'Type', 'image');
else
    h_img = S.h_img;
end

if strcmp(get(h_img, 'Type'), 'axes')
    h_img = findobj(h_img, 'Type', 'Image');
end
assert(strcmpi(get(h_img, 'Type') ,'Image'));
h_ax = get(h_img, 'Parent');

if isempty(S.h_col)
    h_col = findobj(h_ax, 'Type', 'colorbar');
else
    h_col = S.h_col;
end

%% Convert CDataMapping to direct
cmap0 = colormap(h_ax);
n_cmap0 = size(cmap0, 1);

y_tick = get(h_col, 'YTick');
y_ticklabel = get(h_col, 'YTickLabel');

CData = get(h_img, 'CData');
if strcmp(get(h_img, 'CDataMapping'), 'scaled')
    c_lim = get(h_ax, 'CLim');
    
    f = @(v) round((v - c_lim(1)) / diff(c_lim) * (n_cmap0 - 1) + 1);
    
    CData = f(CData);
    y_tick = f(y_tick);
end

CData = CData + 1;
CData(isnan(CData)) = 1;

cmap = [S.bkg; cmap0];

colormap(h_ax, cmap);
set(h_img, 'CData', CData);
set(h_img, 'CDataMapping', 'direct');

%% Recover colorbar's YLim
y_lim = [2, n_cmap0 + 1];
set(h_col, ...
    'YLim', y_lim, ...
    'YTick', y_tick, ...
    'YTickLabel', y_ticklabel);