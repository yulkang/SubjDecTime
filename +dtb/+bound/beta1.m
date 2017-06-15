function y = beta1(t, t_collap_begin, y_bef_collap, t_collap_end, y_aft_collap, curvature)
% y = beta1(t, t_collap_begin, y_bef_collap, t_collap_end, y_aft_collap, curvature)
%
% Takes only 3 parameters, allows both convex and concave curves. No singular points (takes all finite b).
% curvature in [-2, 0.4] should work for collapsing bounds.

tt = min(max((t - t_collap_begin) / (t_collap_end - t_collap_begin), 0), 1);

if curvature >= 0
    b1 = 10^curvature;
    b2 = 1;
else
    b1 = 1;
    b2 = 10^-curvature;
end

y = 1 - betacdf(tt, b1, b2);
y = y * (y_bef_collap - y_aft_collap) + y_aft_collap;