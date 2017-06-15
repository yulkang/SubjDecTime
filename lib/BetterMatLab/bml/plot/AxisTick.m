classdef AxisTick
    methods (Static)
        function tick_max_n(ax, xy, max_n)
            % tick_max_n(ax, xy, max_n)
            tick_name = [upper(xy), 'Tick'];
            ticks = get(ax, tick_name);
            curr_n = length(ticks);
            if curr_n > max_n
                fac = ceil(curr_n / max_n);
                set(ax, tick_name, ticks(1:fac:end));
            end
        end
    end
end