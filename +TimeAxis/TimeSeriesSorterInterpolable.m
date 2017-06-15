classdef TimeSeriesSorterInterpolable < TimeAxis.TimeInheritable
properties % (Access = protected)
    y_src = {};
    Time_src % Contains dt_src
    
    y_interpolant = {}; % n_tr x 1
    interpolant_method = 'linear';
    interpolant_extrapolation_method = 'none';    
end
properties (Dependent)
    dur_src
end
properties
    dur_src_ = []; % If empty, duration is inferred from y_src
end
% properties
%     to_truncate_first_sec = 0;
%     to_truncate_last_sec = 0;
% end
% % Caching - not implemented yet
% properties (Access = private, Transient)
%     t_dst_prev
%     y_dst_prev
% end
methods
    function Ts = TimeSeriesSorterInterpolable(Time_dst, y_src, dt_src)
        Ts.add_deep_copy({'Time_src'});
        
        if exist('Time_dst', 'var') && ~isempty(Time_dst)
            Ts.set_Time(Time_dst);
        end
        Ts.set_Time_src;
        if exist('y_src', 'var') && ~isempty(y_src)
            Ts.set_y_src(y_src);
        end
        if exist('dt_src', 'var') && ~isempty(dt_src)
            Ts.set_dt_src(dt_src);
        else
            Ts.set_dt_src(1/75); % Default
        end
    end
end
%% Interface - y_dst
methods
    function [c, S] = get_ts_cell(Ts, varargin)
        % [c, S] = get_ts_cell(Ts, varargin)
        %
        % 't_dst', []
        % 'rows', []
        % 't0', []
        % 'truncate_first_sec', 0
        % 'truncate_last_sec', 0
        % 't_res', []
        S = varargin2S(varargin, {
            't_dst', []
            'to_flip_time', false
            'rows', []
            't0', []
            'truncate_first_sec', -inf
            'truncate_last_sec', -inf
%             't_min', []
%             't_max', []
%             't_res', []
            });
        
        if isempty(S.t_dst) || (ischar(S.t_dst) && isequal(S.t_dst, ':'))
            S.t_dst = Ts.get_t_dst;
        else
            assert(isvector(S.t_dst) && isnumeric(S.t_dst));
        end
        
        if isempty(S.rows) || (ischar(S.rows) && isequal(S.rows, ':'))
            S.rows = 1:Ts.get_n_tr;
        else
            assert(isvector(S.rows) && isnumeric(S.rows));
        end
        n_row = numel(S.rows);
        
        if isempty(S.t0)
            S.t0 = zeros(n_row, 1);
        else
            assert(isvector(S.t0) && isnumeric(S.t0));
            assert(length(S.t0) == n_row);
        end
        
        c = cell(n_row, 1);
        dur_src = Ts.dur_src;
        
%         t_min = inf;
%         t_max = -inf;
        
        for i_row = 1:n_row
            row = S.rows(i_row);
            
            if isempty(Ts.y_interpolant{i_row})
                c{row} = [];
            else
                if S.to_flip_time
                    t_dst = S.t0(i_row) - S.t_dst;
                else
                    t_dst = S.t0(i_row) + S.t_dst;
                end

                % Truncate first and last
                t_incl = (t_dst >= S.truncate_first_sec) ...
                       & (t_dst <= dur_src(row) - S.truncate_last_sec);
%                 t_dst = t_dst(t_incl);

%                 if any(t_incl)
%                     t_min = min(min(S.t_dst(t_incl)), t_min);
%                     t_max = max(max(S.t_dst(t_incl)), t_max);
%                 end
                
                c{row} = Ts.y_interpolant{i_row}(t_dst);
                c{row}(~t_incl) = nan;
            end
        end
        
%         S.t_min = t_min;
%         S.t_max = t_max;
%         S.t_res = S.t_min:Ts.dt:S.t_max;
    end
    function [m, S] = get_ts_mat(Ts, varargin)
        % [m, S] = get_ts_mat(Ts, varargin)
        %
        % 't_dst', []
        % 'rows', []
        % 't0', []
        % 'truncate_first_sec', 0
        % 'truncate_last_sec', 0
        C = varargin2C(varargin);
        [m, S] = Ts.get_ts_cell(C{:});
        m = cell2mat2(m);
    end
    %% t_dst
    function t_dst = get_t_dst(Ts)
        t_dst = Ts.Time.get_t;
    end
    %% Interface - t0_end
    function t0 = get_t0_end(Ts)
        t = Ts.get_t_src;
        t0 = vVec(t(Ts.get_len_src));
    end
end
%% Interface - y_src
methods
    function set_y_src(Ts, y_src)
        Ts.y_src = row2cell2(y_src);
        Ts.set_nt_src;
        Ts.set_y_interpolant;
    end
    function y_src = get_y_src(Ts)
        y_src = Ts.y_src;
    end
    function n_tr = get_n_tr(Ts)
        if ~isempty(Ts.y_src)
            n_tr = numel(Ts.y_src);
        else
            n_tr = numel(Ts.y_interpolant);
        end
    end
    function len_src = get_len_src(Ts)
        if ~isempty(Ts.y_src)
            len_src = cellfun(@length, Ts.y_src);
        else
            len_src = cellfun(@length, Ts.y_interpolant);
        end
    end
    %% dt_src
    function set_dt_src(Ts, dt_src)
        Ts.Time_src.set_dt(dt_src);
        Ts.set_nt_src;
        Ts.set_y_interpolant;
    end
    function dt_src = get_dt_src(Ts)
        dt_src = Ts.Time_src.get_dt;
    end
    function set_nt_src(Ts)
        Ts.Time_src.set_nt(Ts.get_max_len_src);
    end
    function max_len_src = get_max_len_src(Ts)
        max_len_src = max(Ts.get_len_src);
        if isempty(max_len_src)
            max_len_src = 0; % FIXIT: should be 0 but results in error.
        end
    end
    %% dur_src
    function v = get.dur_src(Ts)
        if isempty(Ts.dur_src_)
            v = cellfun(@length, Ts.get_y_src);
            v = v * Ts.Time_src.get_dt;
        else
            v = Ts.dur_src_;
        end
    end    
    function set.dur_src(Ts, v)
        Ts.dur_src_ = v;
    end
    %% t_src
    function t_src = get_t_src(Ts)
        t_src = Ts.Time_src.get_t;
    end
    %% Time_src
    function set_Time_src(Ts, Time_src)
        if exist('Time_src', 'var')
            assert(isa(Time_src, 'TimeAxis.TimeRegularPositive'));
        else
            Time_src = TimeAxis.TimeRegularPositive;
        end
        Ts.Time_src = Time_src;
    end
    function Time_src = get_Time_src(Ts)
        Time_src = Ts.Time_src;
    end
end
%% Internal - Interpolant
methods (Hidden)
    function set_y_interpolant(Ts, y_interpolant)
        % Set or (if not given) reconstruct interpolant based on y_src and Time_src
        
        n_tr = Ts.get_n_tr;
        
        if exist('y_interpolant', 'var') && ~isempty(y_interpolant)
            assert(iscell(y_interpolant));
            assert(isequal(size(y_interpolant), [n_tr, 1]));
            assert(all(cellfun(@(c) isa(c, 'griddedInterpolant'), y_interpolant)));
            
            Ts.y_interpolant = y_interpolant;
        else
            y_src = Ts.get_y_src;
            y_interpolant = cell(n_tr, 1);
            t_src_all = Ts.get_t_src;
            len_src = Ts.get_len_src;

            for i_tr = 1:n_tr
                t_src = t_src_all(1:len_src(i_tr));
                if ~isempty(t_src)
                    y_interpolant{i_tr} = griddedInterpolant( ...
                        t_src, y_src{i_tr}, ...
                        Ts.get_interpolant_method, ...
                        Ts.get_interpolant_extrapolation_method);
                else
                    y_interpolant{i_tr} = [];
                end
            end
            Ts.y_interpolant = y_interpolant;
        end
    end
    function set_interpolant_method(Ts, interpolant_method)
        assert(ischar(interpolant_method));
        prev_interpolant_method = Ts.interpolant_method;
        Ts.interpolant_method = interpolant_method;
        
        if ~strcmp(prev_interpolant_method, interpolant_method) ...
                && ~isempty(Ts.y_interpolant)
            % Update interpolant property
            for ii = 1:Ts.get_n_tr
                Ts.y_interpolant{i_tr}.Method = interpolant_method;
            end
        end
    end
    function interpolant_method = get_interpolant_method(Ts)
        interpolant_method = Ts.interpolant_method;
    end
    function set_interpolant_extrapolation_method(Ts, extrapolation_method)
        assert(ischar(extrapolation_method));
        prev = Ts.interpolant_extrapolation_method;
        Ts.interpolant_extrapolation_method = extrapolation_method;
        
        if ~strcmp(prev, extrapolation_method) ...
                && ~isempty(Ts.y_interpolant)
            % Update interpolant property
            for ii = 1:Ts.get_n_tr
                Ts.y_interpolant{i_tr}.ExtrapolationMethod = extrapolation_method;
            end
        end
    end
    function interpolant_extrapolation_method = get_interpolant_extrapolation_method(Ts)
        interpolant_extrapolation_method = Ts.interpolant_extrapolation_method;
    end
end
%% Demo
methods (Static)
    function Ts = demo
        %% Toy example
        % t_dst = [0, 0.5]
        Time_dst = TimeAxis.TimeRegularPositive('dt', 0.5, 'max_t', 3);
        y_src = {
            [5, 6]
            [10, 12, 13]
            };
        len = cellfun(@length, y_src) - 1;
        dt_src = 1;
        
        Ts = TimeAxis.TimeSeriesSorterInterpolable(Time_dst, y_src, dt_src);
        
        ts_st = Ts.get_ts_mat;
        disp(ts_st);
        assert(bml.matrix.isequal_within_nan( ...
            ts_st, [5 5.5 6 nan nan nan nan; 10 11 12 12.5 13 nan nan]));
        
        ts_en = Ts.get_ts_mat('t0', len, 'to_flip_time', true);
        disp(ts_en);
        assert(bml.matrix.isequal_within_nan( ...
            ts_en, [6 5.5 5 nan nan nan nan; 13 12.5 12 11 10 nan nan]));
    end
end
end