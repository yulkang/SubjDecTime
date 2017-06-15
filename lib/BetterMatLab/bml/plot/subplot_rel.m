function subplot_rel(vec, r, c)
% SUBPLOT_REL Subplots relative to a certain row and column position.
%
% subplot_rel([nR, nC, R_st, C_st], r, c)

nR   = vec(1);
nC   = vec(2);
R_st = vec(3);
C_st = vec(4);

subplotRC(nR, nC, R_st + r - 1, C_st + c - 1);