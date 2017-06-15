function v = bic(nll, n_dat, n_param)
% v = bic(nll, n_dat, n_param)

v = nll * 2 + n_param * log(n_dat);