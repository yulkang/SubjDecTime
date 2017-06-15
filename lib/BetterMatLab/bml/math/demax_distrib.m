function fb = demax_distrib(fmin, fa)
% fb = demax_distrib(fmin, fa)

fb = flipud(demin_distrib(flipud(fmin), flipud(fa)));
end