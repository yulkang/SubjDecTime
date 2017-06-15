function [h_ax, h_line] = plot(h_ax, h_line, x, y, opt_plot, opt_wtl)
% WTL.PLOT Wrapper for Waterloo line() and scatter().
%
% When h_ax and h_line are nonempty, all inputs other than x and y are
% ignored for speed.
%
% [h_ax, h_line] = plot(h_ax, h_line, x, y, opt_plot, opt_wtl)
%
% h_line
% : Cell array of plot handles.
% opt_plot
% : Cell array of plot options. Always name-value pair.
%
% opt_wtl
% 'add_listener'
% : Defaults to true.
%
% [h_ax, h_line] = plot(h_ax, h_line, x, y, opt_plot, ix)
%
% ix
% : Numerical indices of the entries to update.
%   If given, uses setEntry(ix, x) instead of setDataBufferData(x).

% Check size
assert(isequal(size(x), size(y)), 'x and y should match in size!');

if isvector(x)
    n_line = 1;
    
    if size(x,2)~=1
        x = x';
        y = y';
    end
    
elseif ismatrix(x)
    n_line = size(x,2);
end

% Construct lines only when the size of h_line is inconsistent with 
% n_line inferred from size(x,2)
if length(h_line) == n_line
    if nargin < 6
        for ii = n_line:-1:1
            h_line{ii}.getXData.setDataBufferData(x(:,ii));
            h_line{ii}.getYData.setDataBufferData(y(:,ii));
        end
    else
        for ii = n_line:-1:1
            h_line{ii}.getXData.setEntry(opt_wtl, x(:,ii));
            h_line{ii}.getYData.setEntry(opt_wtl, y(:,ii));
        end
    end

else
    h_line = {};
    
    if isempty(h_ax)
        h_ax = gxgca;
    end
    
    % Parse plot options
    if ~exist('opt_plot', 'var')
        opt_plot = {};
        S = varargin2S(opt_plot);
        
    elseif iscell(opt_plot) && iscell(opt_plot{1})
        assert(length(opt_plot) == n_line, 'length(opt_plot) must match n_line!');
        for ii = 1:n_line
            S{ii} = varargin2S(opt_plot{ii});
        end
    else
        S = varargin2S(opt_plot);
    end
    
    % Parse Waterloo options
    if ~exist('opt_wtl', 'var'), opt_wtl = {}; end
    opt = varargin2S(opt_wtl, {
        'add_listener_x', false
        'add_listener_y', true
        });
    
    % Determine plot type
    if isstruct(S)
        if isfield(S, 'LineSpec')
            [S.LineSpec, m, c] = parse_linespec(S.LineSpec);

            if ~isempty(m), cS.Marker = m; end
            if ~isempty(c), cS.Color  = c; end
        end
        C = S2C(S);
        
        if ~isfield(S, 'LineSpec') || isempty(S.LineSpec)
            for ii = n_line:-1:1
                h = scatter( h_ax, x(:,ii), y(:,ii), C{:});
                h_line{ii} = h.getObject();
            end
        elseif ~isfield(S, 'Marker') || isempty(S.Marker)
            for ii = n_line:-1:1
                h = fastline(h_ax, x(:,ii), y(:,ii), C{:});
                h_line{ii} = h.getObject();
            end
        else
            for ii = n_line:-1:1
                h = line(    h_ax, x(:,ii), y(:,ii), C{:});
                h_line{ii} = h.getObject();
            end
        end
    else
        S_all = S;
        
        for ii = n_line:-1:1
            S = S_all{ii};
            if isfield(S, 'LineSpec')
                [S.LineSpec, m, c] = parse_linespec(S.LineSpec);

                if ~isempty(m), S.Marker = m; end
                if ~isempty(c), S.Color  = c; end
            end

            C = S2C(S);
            
            if ~isfield(S, 'LineSpec') || isempty(S.LineSpec)
                h = scatter( h_ax, x(:,ii), y(:,ii), C{:});
                h_line{ii} = h.getObject();
            elseif ~isfield(S, 'Marker') || isempty(S.Marker)
                h = fastline(h_ax, x(:,ii), y(:,ii), C{:});
                h_line{ii} = h.getObject();
            else
                h = line(    h_ax, x(:,ii), y(:,ii), C{:});
                h_line{ii} = h.getObject();
            end
        end
    end
    
    % Add listener
    h_gr = h_line{ii}.getParentGraph();
        
    for ii = 1:n_line
        if opt.add_listener_x
            h_line{ii}.getXData.addPropertyChangeListener(h_gr);
        end
        if opt.add_listener_y
            h_line{ii}.getYData.addPropertyChangeListener(h_gr);
        end
    end
end
end