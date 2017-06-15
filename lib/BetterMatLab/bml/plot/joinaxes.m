function [h_out, pos] = joinaxes(h, varargin)
% Put subplots closer together.
%
% [h, pos, h_gl] = joinaxes(h, ['option1', option1, ...])
%
% h     : Array of handles. h(r,c) is in the r-th row, c-th column.
%
% OPTIONS:
% 'sameAxes',   'xy' % 'x', 'y', 'xy', or 'off'
% 'linkAxes',   'xy' % 'x', 'y', 'xy', or 'off'
% 'XLabelMode', 'corner' % 'corner' | 'edge' | 'all' | 'none'
% 'YLabelMode', 'corner' % 'corner' | 'edge' | 'all' | 'none'
% xgap, ygap : Gap relative to the size of the whole subplot array. 
%              Defaults to 0.05. 
%              If specified in a vector, xgap(k) is the gap between columns k and k+1.
% xsiz, ysiz : Vectors. All numbers are relative to each other. They can sum to any positive number.
% xpos, ypos : Position of the subplot array relative to the parent figure.
% xsizall, ysizall : Size of the subplot array relative to the parent figure's size.
%
% 2014 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'sameAxes',   'xy'
    'linkAxes',   'xy'
    'joinAxes',   'xy'
    'XLabelMode', 'corner' % 'corner' | 'edge' | 'all' | 'none'
    'YLabelMode', 'corner' % 'corner' | 'edge' | 'all' | 'none'
    'xgap',     0.05
    'ygap',     0.05
    'xsiz',     []
    'ysiz',     []
    'xpos',     []
    'ypos',     []
    'xsizall',  []
    'ysizall',  []
    'opt_common',   {}
    'opt_in',       {}
    'opt_xmargin',  {}
    'opt_ymargin',  {}
    'opt_corner',   {}
    });

R = size(h, 1);
C = size(h, 2);

if isempty(S.xsiz), S.xsiz = ones(1,C) / C; end
if isempty(S.ysiz), S.ysiz = ones(1,R) / R; end

if isscalar(S.xgap), S.xgap = zeros(1,C-1) + S.xgap; end
if isscalar(S.ygap), S.ygap = zeros(1,R-1) + S.ygap; end

%% Determine span
if isempty(S.xpos) || isempty(S.ypos) || isempty(S.xsizall) || isempty(S.ysizall)
    pos_11 = get(h(1,1),     'Position');
    pos_1e = get(h(1,end),   'Position');
    pos_e1 = get(h(end,1),   'Position');
    pos_ee = get(h(end,end), 'Position');
    
    xspan  = [min(pos_11(1), pos_e1(1)), max(pos_1e(1)+pos_1e(3), pos_ee(1) + pos_ee(3))];
    yspan  = [min(pos_e1(2), pos_ee(2)), max(pos_11(2)+pos_11(4), pos_1e(2) + pos_1e(4))];
   
    if isempty(S.xpos),     S.xpos = xspan(1); end
    if isempty(S.ypos),     S.ypos = yspan(1); end
    if isempty(S.xsizall),  S.xsizall = xspan(2) - xspan(1); end
    if isempty(S.ysizall),  S.ysizall = yspan(2) - yspan(1); end
end

%% Scale gap and siz relative to sizall.
S.xgap = S.xgap * S.xsizall;
S.ygap = S.ygap * S.ysizall;
S.xsiz = S.xsiz / sum(S.xsiz);
S.ysiz = S.ysiz / sum(S.ysiz);
S.xsiz = S.xsiz * (S.xsizall - sum(S.xgap));
S.ysiz = S.ysiz * (S.ysizall - sum(S.ygap));

%% Use span to determine size and position relative to the figure
xpos = [0, cumsum(S.xsiz(1:(end-1))) + cumsum(S.xgap)] + S.xpos;
ypos = fliplr([0, cumsum(S.ysiz(end:-1:2))  + cumsum(S.ygap)]) + S.ypos;

%% Position plots
S.opt_common = varargin2C(S.opt_common, {
    'Box',          'off'
    'TickDir',      'out'
    });
S.opt_in     = varargin2C(S.opt_in, varargin2C({
    }, S.opt_common));
S.opt_corner = varargin2C(S.opt_corner, varargin2C({
    }, S.opt_common));
S.opt_xmargin = varargin2C(S.opt_xmargin, varargin2C({
    }, S.opt_common));
S.opt_ymargin = varargin2C(S.opt_ymargin, varargin2C({
    }, S.opt_common));

f_pos = @(r,c) [xpos(c), ypos(r), S.xsiz(c), S.ysiz(r)];

for r = 1:R
    for c = 1:C
        if (c > 1) && (r < R)
            % inner plots
            opt = S.opt_in;
            if ~strcmp(S.XLabelMode, 'all')
                xlabel(h(r,c), '');
                set(h(r,c), 'XTickLabel', []);
                try
                    h(r,c).XRuler.Visible = 'off';
                catch
                end
            end
            if ~strcmp(S.YLabelMode, 'all')
                ylabel(h(r,c), '');
                set(h(r,c), 'YTickLabel', []);
                try
                    h(r,c).YRuler.Visible = 'off';
                catch
                end
            end
        elseif (c == 1) && (r < R)
            % x margin plots
            opt = S.opt_xmargin;
            if ~strcmp(S.XLabelMode, 'all')
                xlabel(h(r,c), '');
                set(h(r,c), 'XTickLabel', []);
                try
                    h(r,c).XRuler.Visible = 'off';
                catch
                end
            end
            if any(strcmp(S.YLabelMode, {'corner', 'none'}))
                if any(S.joinAxes == 'y')
                    set(h(r,c), 'YTickLabel', []);
                    ylabel(h(r,c), '');
                end
            end
        elseif (r == R) && (c > 1)
            % y margin plots
            opt = S.opt_ymargin;
            if any(strcmp(S.XLabelMode, {'corner', 'none'}))
                if any(S.joinAxes == 'x')
                    set(h(r,c), 'XTickLabel', []);
                    xlabel(h(r,c), '');
                end
            end
            if ~strcmp(S.YLabelMode, 'all')
                ylabel(h(r,c), '');
                set(h(r,c), 'YTickLabel', []);
                try
                    h(r,c).YRuler.Visible = 'off';
                catch
                end
            end
        else
            % corner plot
            opt = S.opt_corner;
            if strcmp(S.XLabelMode, 'none')
                xlabel(h(r,c), '');
                set(h(r,c), 'XTickLabel', []);
                try
                    h(r,c).XRuler.Visible = 'off';
                catch
                end
            end
            if strcmp(S.YLabelMode, 'none')
                ylabel(h(r,c), '');
                set(h(r,c), 'XTickLabel', []);
                try
                    h(r,c).YRuler.Visible = 'off';
                catch
                end
            end
        end
        
        set(h(r,c), 'Position', f_pos(r,c), opt{:});
    end
end

%% Link axes
sameAxes(h, [], [], S.sameAxes);
linkaxes(h, S.linkAxes);

%% Output
if nargout >= 1, h_out = h; end
if nargout >= 2, pos = [S.xpos(:), S.xsiz(:), S.ypos(:), S.ysiz(:)]; end
