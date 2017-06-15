function subplot_above_image(varargin)
% Match the width of a plot to that of an image with a colorbar.
%
% subplot_above_image(varargin)
%
% Required named arguments:
% -------------------------
% 'ax_plt', [] % axes containing the plot
% 'ax_img', [] % axes containing the image
% 'h_col', [] % handle of the colorbar
% 'fac_gap', 0.6 % Use 0.6 for small figures and 0.75 for big ones.
%
% 2016 (c) Yul Kang. hk2699 at columbia dot edu.

    S = varargin2S(varargin, {
        'ax_plt', []
        'ax_img', []
        'h_col', []
        });

    fig = get(S.ax_img, 'Parent');
    
    match_size(fig, [], varargin{:});
    
    set(fig, 'SizeChangedFcn', ...
        @(h,d) match_size(h,d, varargin{:}));
end

function match_size(fig, ~, varargin)
    S = varargin2S(varargin, {
        'ax_plt', []
        'ax_img', []
        'h_col', []
        'fac_gap', 0.75 % Use 0.6 for small figures and 0.75 for big ones.
        });

%     fig = gcbo; % get(S.ax_img, 'Parent');
    
    ax_img = S.ax_img;
    ax_plt = S.ax_plt;
    h_col = S.h_col;

    h_pos = {ax_img, ax_plt, fig, h_col};

    for h = h_pos
        set(h{1}, 'Units', 'points');
    end

    %%
    pos_fig = get(fig, 'Position');
    pos_img = get(ax_img, 'Position');
    pos_plt = get(ax_plt, 'Position');
    pos_col = get(h_col, 'Position');
    daspect = get(ax_img, 'DataAspectRatio');

    %%
    ht_img = pos_img(4);
    wt_img = ht_img ...
           / (diff(ylim(ax_img)) / daspect(2)) ...
           * (diff(xlim(ax_img)) / daspect(1));
    wt_col = pos_col(3);
    dis_col = pos_col(1) - pos_fig(3) / 2;

    gap_img_col = (2 * dis_col + wt_col - wt_img) * S.fac_gap;
    %         gap_img_col = ht_img * 0.03;

    pos_plt(1) = pos_col(1) - gap_img_col - wt_img;
%     pos_plt(1) = (pos_fig(3) - wt_img - wt_col - gap_img_col) / 2;
    pos_plt(3) = wt_img;

    %         pos_img(1) = (pos_fig(3) - ht_img - wt_col - gap_img_col) / 2;
    %         pos_col(1) = pos_img(1) + ht_img + gap_img_col - wt_col / 2;

    % box(ax_img, 'on'); % TEST
    
    pos_img(1) = pos_plt(1);
    pos_img(3) = wt_img;
    
    pos_col(1) = pos_img(1) + wt_img + gap_img_col;

    %%
    set(ax_plt, 'Position', pos_plt);
    set(ax_img, 'Position', pos_img);
    set(h_col, 'Position', pos_col);
    set(ax_plt, 'XLim', get(ax_img, 'XLim'));

    %%
%     for h = h_pos
%         set(h{1}, 'Units', 'normalized');
%     end
end