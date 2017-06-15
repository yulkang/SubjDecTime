function tf = is_cmat(cmat)
% tf = is_cmat(cmat)

tf = iscell(cmat) && ismatrix(cmat);