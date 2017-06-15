classdef AxisSize
    methods (Static)
        function ax_min(ax, xy, v)
            % ax_min(ax, xy, v)
            curr_axlim = axlim(xy, ax);
            axlim(xy, ax, [v, curr_axlim(2)]);
        end
        function ax_max(ax, xy, v)
            % ax_max(ax, xy, v)
            curr_axlim = axlim(xy, ax);
            axlim(xy, ax, [curr_axlim(1), v]);
        end
        function ax_margin_robust(ax, xy, varargin)
            S = varargin2S(varargin, {
                'margin', 0.1
                'prctile', 100
                });
            assert(S.prctile > 50);
            assert(ischar(xy) && isscalar(xy) && (xy == 'x' || xy == 'y'));
            lines = findobj(ax, 'Type', 'line');
            v = [lines.([upper(xy) 'Data'])];
            max_v = prctile(v(:), S.prctile);
            min_v = prctile(v(:), 100 - S.prctile);
            range_v = max_v - min_v;
            margin_v = range_v * S.margin;
            axlim(xy, ax, [min_v - margin_v, max_v + margin_v]);
        end
        function ax_max_robust(ax, xy, varargin)
            S = varargin2S(varargin, {
                'margin', 0.1
                'prctile', 100
                });
            assert(ischar(xy) && isscalar(xy) && (xy == 'x' || xy == 'y'));
            lines = findobj(ax, 'Type', 'line');
            v = [lines.([upper(xy) 'Data'])];
            max_v = prctile(v(:), S.prctile);
            AxisSize.ax_max(ax, xy, max_v * (1 + S.margin));
        end
        function equalize_aspect_ratio(axs, xy)
            n = numel(axs);
            ratios = ones(1,n);
            
            for ii = 1:n
                ax = axs(ii);
                xsiz = diff(xlim(ax));
                ysiz = diff(ylim(ax));
                ratios(ii) = ysiz / xsiz;
            end
            
            for ii = 1:n
                ax = axs(ii);
                xLim = xlim(ax);
                yLim = ylim(ax);
                xsiz = diff(xLim);
                ysiz = diff(yLim);
                
                switch xy
                    case 'x'
                        targ_ratio = min(ratios);
                        xlim(ax, [xLim(1), xLim(1) + ysiz / targ_ratio]);
                    case 'y'
                        targ_ratio = max(ratios);
                        ylim(ax, [yLim(1), yLim(1) + xsiz * targ_ratio]);
                end
            end
        end
    end
end