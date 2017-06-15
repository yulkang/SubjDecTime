classdef TimeSeriesSorterInterpolableCahced < TimeAxis.TimeSeriesSorterInterpolable
properties (Access = private)
    % Caching and acceleration
    y_src_updated = false;
    y_dst_prev = {};
    t_src_prev = [];
    t_dst_prev = [];    
    
    args_get_ts_cell = {};
end
methods
    %% Inherited - get cached
    function c = get_ts_cell(Ts, varargin)
        % caching should be done for multiple t0's to be useful. 
        % Perhaps better to cache upstream?
    end
    
    %% Inherited - set update status
    function set_y_interpolant(Ts, varargin)
        Ts.set_y_interpolant@TimeAxis.TimeSeriesSorterInterpolable( ...
            varargin{:});
        Ts.set_y_src_updated(true);
    end
    function set_interpolant_method(Ts, varargin)
        Ts.set_interpolant_method@TimeAxis.TimeSeriesSorterInterpolable( ...
            varargin{:});
        Ts.set_y_src_updated(true);
    end
    function set_interpolant_extrapolation_method(Ts, varargin)
        Ts.set_interpolant_extrapolation_method@TimeAxis.TimeSeriesSorterInterpolable( ...
            varargin{:});
        Ts.set_y_src_updated(true);
    end
    %% Set/Get
    function set_y_src_updated(Ts, tf)
        assert(islogical(tf) && isscalar(tf));
        Ts.y_src_updated = tf;
    end
    function tf = get_y_src_updated(Ts)
        tf = Ts.y_src_updated;
    end
    function set_y_dst_prev(Ts, y_dst_prev)
        Ts.y_dst_prev = y_dst_prev;
    end
    function y_dst_prev = get_y_dst_prev(Ts)
        y_dst_prev = Ts.y_dst_prev;
    end
    function set_t_src_prev(Ts, t_src_prev)
        Ts.t_src_prev = t_src_prev;
    end
    function t_src_prev = get_t_src_prev(Ts)
        t_src_prev = Ts.t_src_prev;
    end
    function set_t_dst_prev(Ts, t_dst_prev)
        Ts.t_dst_prev = t_dst_prev;
    end
    function t_dst_prev = get_t_dst_prev(Ts)
        t_dst_prev = Ts.t_dst_prev;
    end    
end
end