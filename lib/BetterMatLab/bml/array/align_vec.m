function v = align_vec(v, t, align_to, from_t, to_t, varargin)
% v = align_vec(v, t, align_to, from_t, to_t, varargin)

t2 = t - align_to;
v = v((t2 >= from_t) & (t2 < to_t));