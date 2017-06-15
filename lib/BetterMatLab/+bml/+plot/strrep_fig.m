function strrep_fig(src, dst, varargin)
    % strrep_fig(src, dst, varargin)
    % strrep_fig({src1, src2, ...}, {dst1, dst2, ...}, varargin)
    % strrep_fig({src1, dst1; src2, dst2; ...}, [], varargin)
    %
    % OPTIONS:
    % 'h', [] % figure, axes, text, or array or cell array of them.
    % 'types', {
    %     'Title', 'XLabel', 'YLabel', ...
    %     'XTickLabel', 'YTickLabel', ...
    %     'Text'
    %     }
    % });
    
    % 2017 (c) Yul Kang. hk2699 at columbia dot edu.
    
    S = varargin2S(varargin, {
        'h', [] % figure, axes, or texts
        'types', {
            'Title', 'XLabel', 'YLabel', ...
            'XTickLabel', 'YTickLabel', ...
            'Text'
            }
        });
    
    if iscell(src)
        if exist('dst', 'var') && iscell(dst)
            assert(isequal(size(src), size(dst)));
            for ii = 1:numel(src)
                bml.plot.strrep_fig(src{ii}, dst{ii}, varargin{:});
            end
        else
            assert(size(src, 2) == 2);
            for ii = 1:size(src, 1)
                bml.plot.strrep_fig(src{ii,1}, src{ii,2}, varargin{:});
            end
        end
        return;
    end
    
    %%
    if isempty(S.h), 
        S.h = gcf;
    end
    
    %%
    if iscell(S.h)
        for i_h = 1:numel(S.h)
            C = varargin2C({
                'h', S.h{i_h}
                }, S);
            bml.plot.strrep_fig(src, dst, C{:});
        end

    elseif ~isscalar(S.h)
        for i_h = 1:numel(S.h)
            C = varargin2C({
                'h', S.h(i_h)
                }, S);
            bml.plot.strrep_fig(src, dst, C{:});
        end
        
    elseif strcmp(get(S.h, 'Type'), 'figure')
        axs = findobj(gcf, 'Type', 'axes');
        C = varargin2C({
            'h', axs
            }, S);
        bml.plot.strrep_fig(src, dst, C{:});
        
    elseif strcmp(get(S.h, 'Type'), 'axes')
        strrep_axes(S.h);

    elseif strcmp(get(S.h, 'Type'), 'text')
        strrep_text(S.h);
    end

    function strrep_axes(ax)
        n_ax = numel(S.h);
        n_type = numel(S.types);

        for i_ax = 1:n_ax
            ax1 = S.h(i_ax);

            for i_type = 1:n_type
                type = S.types{i_type};
                switch type
                    case 'Text'
                        h_txt1 = findobj(ax1, 'Type', type);
                        strrep_text(h_txt1);

                    case {'Title', 'XLabel', 'YLabel'}
                        h_txt1 = get(ax1, type);
                        strrep_text(h_txt1);

                    case {'XTickLabel', 'YTickLabel'}
                        strrep_axes_prop(ax1, type);
                end
            end
        end
    end
    function strrep_axes_prop(ax, prop)
        set(ax, prop, strrep(get(ax, prop), src, dst));    
    end
    function strrep_text(h_text)
        for i_txt = 1:numel(h_text)
            obj1 = h_text(i_txt);
            set(obj1, 'String', strrep(get(obj1, 'String'), src, dst));
        end
    end
end