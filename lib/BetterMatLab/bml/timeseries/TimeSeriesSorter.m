classdef TimeSeriesSorter < matlab.mixin.Copyable
    % USAGE:
    % Ts = TimeSeriesSorter(y, dt)
    % matrix = get_mat(Ts, t=':', rows=':', rev=false)
    %
    % 2015 (c) Yul Kang. hk2699 at cumc dot columbia dot edu.
properties (Access = private)
    y = {};
    dt = 1;
end
methods
    function Ts = TimeSeriesSorter(y, dt)
        % Ts = TimeSeriesSorter(y, dt)
        if nargin >= 1
            Ts.set_y(y);
        end
        if nargin >= 2
            Ts.dt = dt;
        end
    end
    function m = get_mat(Ts, t, rows, rev)
        % m = get_mat(Ts, t, rows, rev)
        if nargin < 4
            rev = false;
        end
        m = Ts.get_mat_all(rev);
        
        if nargin < 2
            t = ':';
        end
        ix = Ts.t2ix(t, size(m, 2));
        
        if nargin < 3
            rows = ':';
        end
        rows = Ts.parse_rows(rows);
        
        m = m(rows, ix);
    end
    function m = get_mat_all(Ts, rev)
        % m = get_mat_all(Ts, rev)
        assert(islogical(rev));
        if rev
            m = cell2mat2(cellfun(@fliplr, Ts.y, 'UniformOutput', false));
        else
            m = cell2mat2(Ts.y);
        end
    end
    function c = get_cell(Ts, rows)
        if nargin < 2
            c = Ts.y;
        else
            rows = Ts.parse_rows(rows);
            c = Ts.y{rows};
        end
    end
    function trim(Ts, side, amount)
        % trim('st'|'en', amount)        
        n_amount = Ts.t2ix(amount);
        switch side
            case 'st'
                Ts.y = cellfun(@(v) v((n_amount+1):end), Ts.y, ...
                    'UniformOutput', false);
            case 'en'
                Ts.y = cellfun(@(v) v(1:(end - n_amount)), Ts.y, ...
                    'UniformOutput', false);
            otherwise
                error('Unsupported side!');
        end
    end
    function l = get_len(Ts)
        l = cellfun(@length, Ts.y);
    end
    function n = get_n_tr(Ts)
        n = numel(Ts.y);
    end
    
    %% Internal
    function rows = parse_rows(Ts, rows)
        rows = ix2py(rows, Ts.get_n_tr);
    end
    function nt = get_nt(Ts)
        % nt = get_nt(Ts)
        nt = max(cellfun(@length, Ts.y));
    end
    function ix = t2ix(Ts, t, nt)
        % ix = t2ix(Ts, t, nt)
        % t: starts from 0.
        if nargin < 3
            nt = Ts.get_nt;
        end
        if ischar(t) && isequal(t, ':')
            ix = 1:nt;
        else
            dt = Ts.dt;
            ix = min(max(round((t + dt) / dt), 1), nt);
        end
    end
    
    %% Get/Set
    function set_y(Ts, y)
        % set_y(Ts, y)
        Ts.y = row2cell2(y);
    end
    function y = get_y(Ts)
        y = Ts.y;
    end
    function set_dt(Ts, dt)
        assert(isnumeric(dt) && isscalar(dt));
        Ts.dt = dt;
    end
    function dt = get_dt(Ts)
        dt = Ts.dt;
    end
end
end