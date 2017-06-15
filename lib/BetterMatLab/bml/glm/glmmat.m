function glmmat(x, y, sep, rowsep, colsep, varargin)
% glmmat(x, y, sep, rowsep, colsep, varargin)
%
% 'plot',     'y' % 'y', 'slope', 'bias', 'none'
% 'color',     @hsv2
% 'plot_args', {}
% 'tick_args', {}
% 'glmsepopt', {}
% 'seplegend', {}
% 'rows', []
% 'rowtitle', {}
% 'coltitle', {}
% 'h', []
%
% 2015 (c) Yul Kang. hk2699 at columbia dot edu.

S = varargin2S(varargin, {
    'plot',     'y' % 'y', 'slope', 'bias', 'none'
    'color',     @hsv2
    'plot_args', {}
    'tick_args', {}
    'glmsepopt', {}
    'seplegend', {}
    'rows', []
    'rowtitle', {}
    'coltitle', {}
    'h', []
    });

% Options
if strcmp(S.plot, 'y')
    S.glmsepopt = varargin2C({
        'plot', 'y'
        }, S.glmsepopt);
else
    S.glmsepopt = varargin2C({
        'plot', 'none'
        }, S.glmsepopt);
end

% Initialization
n = length(x);
if isempty(sep),    sep    = ones(n, 1); end
if isempty(rowsep), rowsep = ones(n, 1); end
if isempty(colsep), colsep = ones(n, 1); end

nrow = max(rowsep);
ncol = max(colsep);

if isempty(S.h)
    S.h = subplotRCs(nrow, ncol);
end

% Outputs
res_sep = dataset; % cell(nrow, ncol);
res_ixn = dataset; % cell(nrow, ncol);

% Rows
if isempty(S.rows)
    S.rows = 1:nrow;
end

% Repeat for each cell
crow_sep = 0;
crow_ixn = 0;
for icol = 1:ncol
    for irow = 1:nrow
        filt = (rowsep == irow) & (colsep == icol);
        
        if strcmp(S.plot, 'y')
            h = S.h(irow, icol);
        else
            h = [];
        end
        
        [cres_sep, cres_ixn, hpred] = ...
            glmsep(x(filt), y(filt), sep(filt), 'h', h, S.glmsepopt{:});
        
        nsep     = length(cres_sep);
        res_sep  = ds_set(res_sep, crow_sep + (1:nsep), cres_sep);
        res_sep  = ds_set(res_sep, crow_sep + (1:nsep), 'row', irow, 'col', icol);
        crow_sep = crow_sep + nsep;
        
        crow_ixn = crow_ixn + 1;
        res_ixn  = ds_set(res_ixn, crow_ixn, cres_ixn);
        res_ixn  = ds_set(res_ixn, crow_ixn, 'row', irow, 'col', icol);
        
        if strcmp(S.plot, 'y')
            if ~isempty(S.seplegend)
                legend(hpred, S.seplegend, 'Location', 'SouthEast');
            end
        end
        
        % set(S.h(irow, icol), 'NextPlot', 'add'); % Doesn't work. Seems to be MATLAB's bug.
    end

    if any(strcmp(S.plot, {'slope', 'bias'}))
        axes(S.h(1,icol)); %#ok<LAXES>
        
        nsep = max(res_sep.sep);
        colors = S.color(nsep);

        f_jit = @(vs, ii) iif( ...
            length(vs) > 1, ...
                min(diff(vs)) * 0.1 * (ii - (length(vs)-1)/2), ...
            true, ...
                0);
        
        for isep = 1:nsep
            filt = res_sep.sep == isep;
            
            if ~any(filt), continue; end
            
            b    = cell2mat(res_sep.b(filt));
            se   = cell2mat(res_sep.se(filt));
            
            switch S.plot
                case 'slope'
                    b  = b(:,2);
                    se = se(:,2);
                    
                case 'bias'
                    b  = b(:,1);
                    se = se(:,1);
            end
            
            plot_args = varargin2C(S.plot_args, {
                'Color',     colors(isep,:)
                'Marker',    'o'
                'MarkerFaceColor', colors(isep,:)
                'MarkerEdgeColor', 'w'
                'MarkerSize', 8
                'LineStyle', '-'
                'LineWidth', 2
                });
            tick_args = varargin2C(S.tick_args, {
                'Color',     colors(isep,:);
                'Marker',    'none'
                'LineStyle', '-'
                'LineWidth', 2
                });
            
            if length(S.rows) > 1
                jit = f_jit(S.rows, isep);
            else
                jit = f_jit(1:nsep, isep);
            end
            
            errorbar_wo_tick(S.rows + jit, b, -se, se, plot_args, tick_args);
%             if ~isempty(S.seplegend)
%                 set(gca, 'XTickLabel', S.seplegend);
%             end
        end
    end
end
set(S.h, 'NextPlot', 'replace');

% Titles
if ~isempty(S.rowtitle), gltitle(h, 'row', S.rowtitle); end
if ~isempty(S.coltitle), gltitle(h, 'col', S.coltitle); end