function [ix, t_out, v_out] = cell_closest(t_C, t, v_C)
% CELL_CLOSEST  Find the closest entry.
%
% [ix, t_out, v_out] = cell_closest(t_C, t, v_C)

ix = arrayfun(@(CC,tt) out(@() min(abs(CC{1} - tt)), 2), t_C, t);

if nargout >= 2
    t_out = arrayfun(@(CC,ii) CC{1}(ii), t_C, ix);
end

if nargout >= 3
    v_out = arrayfun(@(CC,ii) CC{1}(ii), v_C, ix);
end