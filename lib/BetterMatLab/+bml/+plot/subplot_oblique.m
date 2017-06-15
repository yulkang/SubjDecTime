function [obl, ax] = subplot_oblique(varargin)
% Oblique axes that scales correctly on printing or resizing.
%
% obl = subplot_oblique(varargin)
%
% OPTIONS:
% 'ax', gca % The original axes
% 'prop', 0.5 % How to scale the original axes
% ...
% ... % width and margin are 
% ... % relative to the diagonal of the original axes.
% 'margin', 0.1 % margin from the top right corner of the original axes
% 'width', 1 % width of the oblique axes
% ...
% 'height', 0.5 % height of the oblique axes relative to its width
% 
% EXAMPLE:
% clf; [obl, ax] = bml.plot.subplot_oblique('width', 0.5, 'margin', -0.3)
% axes(ax);
% crossLine('NE');
% axes(obl);
% crossLine('v', 0)
% savefigs('test');
%
% Inspired by the oblique histogram of Roozbeh Kiani (2009).
% 2016 implemented by Yul Kang. hk2699 at columbia dot edu

S = varargin2S(varargin, {
    'ax', []
    });

if isempty(S.ax)
    ax = gca;
else
    ax = S.ax;
end
daspect(ax, [1 1 1]);
pbaspect(ax, [1 1 1]);

[obl, ax] = match_size([], [], ax, [], 'init', true, varargin{:});

siz_fig_orig = get_fig_size(ax);

set(ax, 'Units', 'points');
pos_orig = get(ax, 'Position');
pos_orig_rel = pos_orig ./ siz_fig_orig;
set(ax, 'Units', 'points');

C = varargin2C(varargin, {
    'pos_orig_rel', pos_orig_rel
    });

fig = get(ax, 'Parent');
set(fig, 'SizeChangedFcn', ...
    @(h,d) match_size(h,d,ax,obl,C{:}));
end

function siz = get_fig_size(ax)
    fig = get(ax, 'Parent');
    units_fig0 = get(fig, 'Units');
    set(fig, 'Units', 'points');
    pos_fig_orig = get(fig, 'Position');
    siz = min(pos_fig_orig([3 4]));
    set(fig, 'Units', units_fig0);
end

function [obl, ax] = match_size(~, ~, ax, obl, varargin)
    S = varargin2S(varargin, {
        'prop', 0.5 % How to scale the original axes
        ...
        ... % width and margin are 
        ... % relative to the diagonal of the original axes.
        'width', 1 % width of the oblique axes
        'height', 0.5 % height of the oblique axes relative to its width
        ...
        ... % Internal
        ...
        'init', false
        'pos_orig_rel', []
        });
    
    if ~isvalidhandle(ax)
        obl = ghandles;
        ax = ghandles;
        return;
    end
    
    set(ax, 'Units', 'points');
    
    if S.init || isempty(obl)
        pos_orig = get(ax, 'Position');
        pos_ax = [pos_orig(1:2), min(pos_orig([3 4])) .* [S.prop, S.prop]];
        set(ax, 'Position', pos_ax);

        pos_nonoverlap = [pos_ax(1:2) + pos_ax(3:4) * 1.1, 5, 5];
        obl = subplot('Position', pos_nonoverlap);
        set(obl, 'Units', 'points');
        set(obl, 'Position', pos_nonoverlap);
        
    elseif ~isempty(S.pos_orig_rel)
        siz = get_fig_size(ax);
        set(ax, 'Position', siz .* S.pos_orig_rel);
    end
    
    % Also set xlim to the difference in ax's x and y by default.
    ylim_ax = ylim(ax);
    xlim_ax = xlim(ax);
    xlim_obl = xlim_ax([1 2]) - ylim_ax([2 1]);
    xlim(obl, xlim_obl);

%     ylim_obl = ylim(obl);
    
    % Set position
    ang = atan(S.height) / pi * 180;
    view(obl, [ang, 90]);
    pbaspect(obl, [1, S.height, 1]);
    [~, pos] = calc_obl_pos(ax, varargin{:});
    
    set(obl, 'Units', 'points');
    set(obl, 'Position', pos);

%     axis(obl, 'manual');
%     ylim(obl, ylim_obl);
end

function [pos1, pos2] = calc_obl_pos(ax, varargin)
    S = varargin2S(varargin, {
        'margin', 0.1 % margin from the top right corner of the original axes
        'width', 1
        'height', 0.5 % height of the oblique axes relative to its width
        });
    
    set(ax, 'Units', 'points');
    pos0 = get(ax, 'Position');
    
    left0 = pos0(1);
    bottom0 = pos0(2);
    w0 = pos0(3);
    h0 = pos0(4);

    wh0 = max(w0, h0);
    l0 = wh0 * sqrt(2);
    w = l0 * S.width;
    h = w * S.height;
    m = l0 * S.margin;
    
    left = left0 + wh0 - (w / 2 - m) / sqrt(2);
    bottom = bottom0 + wh0 - (w / 2 - m) / sqrt(2);
    width1 = (w + w) / sqrt(2);
    height1 = (w + w) / sqrt(2);
    
    width2 = (w + h) / sqrt(2);
    height2 = (w + h) / sqrt(2);
    
    pos1 = [left, bottom, width1, height1];
    pos2 = [left, bottom, width2, height2];
end