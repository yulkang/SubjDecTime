function D = uplo2ix(D)
% D = uplo2ix(D)

fs = fieldnames(D.lo)';

for ccf = fs
    cf = ccf{1};
    
    D.(cf){1} = D.lo.(cf);
    D.(cf){2} = D.up.(cf);
end

if isfield(D, 'notabs')
    D.unabs{1} = D.notabs.neg_t;
    D.unabs{2} = D.notabs.pos_t;
end
    